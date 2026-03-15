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
}
