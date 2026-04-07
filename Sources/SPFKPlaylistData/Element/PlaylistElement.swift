import AppKit
import Foundation
import SPFKBase
import SPFKMetadataBase
import SPFKSearch
import SPFKUtils

public struct PlaylistElement: Sendable, Hashable, Equatable {
    /// Identity is URL-only. Two elements referencing the same file are equal
    /// regardless of metadata or color differences.
    public static func == (lhs: PlaylistElement, rhs: PlaylistElement) -> Bool {
        lhs.url == rhs.url
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

    // MARK: - Codable properties

    public var url: URL {
        mafDescription.url
    }

    public var bookmarkData: Data?
    public var hexColor: HexColor?

    public var mafDescription: MetaAudioFileDescription {
        didSet {
            invalidateSearch()
        }
    }

    public var sortIndex: Int?

    public var dirtyFlags: Set<MetadataDirtyFlag> = []

    /// Whether any unsaved changes exist.
    public var isDirty: Bool { !dirtyFlags.isEmpty }

    // MARK: - Transients - not included in codable

    // Searchable
    public private(set) var searchableValue: SearchableValue = []

    /// Whether the file was externally modified while this element has unsaved changes.
    /// This is a transient flag — not persisted, defaults to `false`.
    /// Set by `FileModificationObserver` when a disk change is detected on a dirty element.
    /// Cleared when the element is saved or reparsed from disk.
    public var isExternallyModified: Bool = false

    public var isModified: Bool {
        mafDescription.urlProperties.isModified
    }

    public var filename: String {
        mafDescription.url.lastPathComponent
    }

    public var filenameNoExtension: String {
        url.deletingPathExtension().lastPathComponent
    }

    public var markerDescriptions: [AudioMarkerDescription] {
        get { mafDescription.markerCollection.markerDescriptions }
        set { mafDescription.markerCollection.update(markerDescriptions: newValue) }
    }

    public var cgColor: CGColor? {
        hexColor?.cgColor
    }

    /// The resolved display color using 3-tier precedence:
    /// 1. Custom hexColor (explicit hex text tag or user-assigned)
    /// 2. Finder label color (first by rawValue order)
    /// 3. nil (caller falls back to default)
    public var resolvedDisplayColor: HexColor? {
        hexColor ?? mafDescription.urlProperties.finderTags.hexColorFromLabel
    }

    public init(
        mafDescription: MetaAudioFileDescription,
        sortIndex: Int? = nil
    ) throws {
        self.mafDescription = mafDescription
        self.sortIndex = sortIndex
        hexColor = mafDescription.urlProperties.finderTags.hexColorTag

        do {
            try updateBookmark()
        } catch {
            Log.error("updateBookmark()", error)

            throw error
        }

        invalidateSearch()
    }

    public mutating func updateBookmark() throws {
        bookmarkData = try url.bookmarkData(options: [.withSecurityScope])
    }
}

extension PlaylistElement: Searchable {}

extension PlaylistElement {
    private func createSearchString() -> SearchableValue {
        var out: [String] = [filenameNoExtension]

        out += mafDescription.tagProperties.tags.values
        out += mafDescription.tagProperties.customTags.values
        out += mafDescription.urlProperties.finderTags.labels()

        if let hexColor {
            out.append(hexColor.colorName.rawValue)
        }

        if let bext = mafDescription.bextDescription {
            let values = bext.dictionary.values.compactMap(\.self?.trimmed)
            out += values
        }

        out = out.map(\.normalized)
        out = out.filter(\.isNotEmpty)

        return out
    }

    mutating func invalidateSearch() {
        searchableValue = createSearchString()
    }
}
