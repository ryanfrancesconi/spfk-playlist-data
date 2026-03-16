import AppKit
import Foundation

public enum AudioFileTableColumn: String, CaseIterable, Sendable {
    case number = "#"
    case file = "File"
    case type = "Type"
    case format = "Format"
    case duration = "Duration"
    case fileSize = "Size"
    case creationDate = "Created"
    case modificationDate = "Modified"
    case finderTags = "Finder Tags"
    case markers = "Markers"

    public var showImage: Bool { self == .file }

    public var displayName: String {
        rawValue
    }

    public var defaultWidth: CGFloat? {
        switch self {
        case .number: 40
        case .type, .fileSize: 60
        case .finderTags: 80
        case .file: 200
        default: nil
        }
    }

    public var minWidth: CGFloat { 50 }

    public var maxWidth: CGFloat? {
        switch self {
        case .number: 60
        case .type: 60
        default: nil
        }
    }

    public var identifier: NSUserInterfaceItemIdentifier {
        NSUserInterfaceItemIdentifier(displayName)
    }

    public init?(displayName: String) {
        for item in Self.allCases where item.displayName == displayName {
            self = item
            return
        }

        return nil
    }

    // MARK: - Cell Style

    /// Describes the visual presentation of a table cell, independent of AppKit types.
    public struct CellStyle: Sendable, Equatable {
        public enum Kind: Sendable, Equatable {
            /// Row number cell — plain text, no element lookup needed.
            case number
            /// Finder tag dots cell — custom rendering.
            case finderTags
            /// Standard image+text cell.
            case standard
        }

        public enum TextColorRole: Sendable, Equatable {
            case primary
            case secondary
        }

        public let kind: Kind
        public let showsImage: Bool
        public let textColorRole: TextColorRole
        public let isItalic: Bool
    }

    /// Returns the cell style for a column given the element's dirty state.
    /// - Parameter isDirty: whether the element has unsaved changes (used for italic font).
    public func cellStyle(isDirty: Bool = false) -> CellStyle {
        switch self {
        case .number:
            CellStyle(kind: .number, showsImage: false, textColorRole: .secondary, isItalic: false)
        case .finderTags:
            CellStyle(kind: .finderTags, showsImage: false, textColorRole: .secondary, isItalic: false)
        case .file:
            CellStyle(kind: .standard, showsImage: true, textColorRole: .primary, isItalic: isDirty)
        default:
            CellStyle(kind: .standard, showsImage: false, textColorRole: .secondary, isItalic: isDirty)
        }
    }

    /// Returns the cell style for an arbitrary column title, falling back to a standard secondary style.
    /// - Parameters:
    ///   - columnTitle: the column's display name.
    ///   - isDirty: whether the element has unsaved changes.
    public static func cellStyle(forColumnTitled columnTitle: String, isDirty: Bool = false) -> CellStyle {
        if let column = AudioFileTableColumn(displayName: columnTitle) {
            return column.cellStyle(isDirty: isDirty)
        }

        // Tag/metadata columns — standard text, no image
        return CellStyle(kind: .standard, showsImage: false, textColorRole: .secondary, isItalic: isDirty)
    }

    /// Returns the index of the first column title that is not a standard `AudioFileTableColumn`,
    /// indicating where tag/metadata columns begin. Returns `columnTitles.count` if all titles
    /// are standard columns, or `nil` if the array is empty.
    public static func tagInsertionIndex(in columnTitles: [String]) -> Int? {
        guard !columnTitles.isEmpty else { return nil }

        for i in 0 ..< columnTitles.count {
            if AudioFileTableColumn(displayName: columnTitles[i]) == nil {
                return i
            }
        }

        return columnTitles.count
    }
}
