// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-playlist-data

import Foundation

public struct TableColumnPreset: Sendable, Hashable, Equatable, Codable {
    public var data: [TableColumnState]

    public init(data: [TableColumnState]) {
        self.data = data
    }
}
