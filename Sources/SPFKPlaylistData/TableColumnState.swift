// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-playlist-data

import Foundation

/// Persisted state for a single table column: title, width, and visibility.
/// Used to save and restore the full column layout independently of AppKit's autosave mechanism.
public struct TableColumnState: Sendable, Hashable, Equatable, Codable {
    public var title: String
    public var width: CGFloat
    public var isHidden: Bool

    public init(title: String, width: CGFloat, isHidden: Bool = false) {
        self.title = title
        self.width = width
        self.isHidden = isHidden
    }
}
