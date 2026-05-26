import AppKit
import Foundation
import SPFKAudioBase
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

    public var hexColor: HexColor?

    public var mafDescription: MetaAudioFileDescription {
        didSet {
            invalidateSearch()
        }
    }

    public var sortIndex: Int?

    public var dirtyFlags: Set<MetadataDirtyFlag> = []

    /// Pending non-destructive audio edits. Non-nil means the file has queued
    /// audio changes that have not yet been rendered to disk.
    public var audioEditDescription: AudioEditDescription?

    /// Whether any unsaved changes exist — metadata or audio edits.
    public var isDirty: Bool { hasPendingMetadataEdit || hasPendingAudioEdit }

    /// Whether there is a pending metadata edit queued for this file.
    public var hasPendingMetadataEdit: Bool { !dirtyFlags.isEmpty }

    /// Whether there is a pending audio edit queued for this file.
    public var hasPendingAudioEdit: Bool { audioEditDescription != nil }

    // MARK: - Transients - not included in codable

    // Searchable
    public private(set) var searchableValue: SearchableValue = []

    /// Whether the file was externally modified while this element has unsaved changes.
    /// This is a transient flag — not persisted, defaults to `false`.
    /// Set by `FileModificationObserver` when a disk change is detected on a dirty element.
    /// Cleared when the element is saved or reparsed from disk.
    public var isExternallyModified: Bool = false

    /// True when the file does not exist at its stored path (e.g. on a disconnected volume).
    public var isMissing: Bool { !url.exists }

    /// True when the file has been moved to the Trash (boot volume ~/.Trash/ or external /.Trashes/).
    public var isInTrash: Bool { url.pathComponents.contains(".Trash") || url.pathComponents.contains(".Trashes") }

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
    ) {
        self.mafDescription = mafDescription
        self.sortIndex = sortIndex
        hexColor = mafDescription.urlProperties.finderTags.hexColorTag
        invalidateSearch()
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
