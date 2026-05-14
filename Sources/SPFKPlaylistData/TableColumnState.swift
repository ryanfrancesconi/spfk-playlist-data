// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-playlist-data

import Foundation

/// Persisted state for a single table column: display title, stable identifier, width, and visibility.
/// Used to save and restore the full column layout independently of AppKit's autosave mechanism.
///
/// `identifier` is the stable lookup key (`NSTableColumn.identifier.rawValue`) and is always used
/// for column matching. `title` is the localized display name shown in the column header.
/// Old saves that predate the title/identifier split only contain a single `title` field which
/// stored the identifier; decoding falls back to using `title` as `identifier` in that case.
public struct TableColumnState: Sendable, Hashable, Equatable, Codable {
    public var title: String
    public var identifier: String
    public var width: CGFloat
    public var isHidden: Bool

    public init(title: String, identifier: String, width: CGFloat, isHidden: Bool = false) {
        self.title = title
        self.identifier = identifier
        self.width = width
        self.isHidden = isHidden
    }

    /// Convenience initializer for call sites where the identifier equals the title.
    /// Retained for backward compatibility with tests and legacy construction sites.
    public init(title: String, width: CGFloat, isHidden: Bool = false) {
        self.init(title: title, identifier: title, width: width, isHidden: isHidden)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case title, identifier, width, isHidden
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        // Old saves have no `identifier` key — the `title` field stored the identifier value.
        identifier = try container.decodeIfPresent(String.self, forKey: .identifier) ?? title
        width = try container.decode(CGFloat.self, forKey: .width)
        isHidden = try container.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
    }
}
