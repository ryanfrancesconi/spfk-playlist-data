// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation
import SPFKBase

public struct PlaylistGroup: Sendable, Hashable, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uuid == rhs.uuid
    }

    public let uuid: UUID
    public var title: String
    public var isEditable: Bool
    public var collectionType: CollectionType
    public var hexColor: HexColor?
    public var playlists: [Playlist]
    public var sortIndex: Int?

    public var titleAndID: String {
        "\(title) (\(uuid.uuidString))"
    }

    public var isEmpty: Bool {
        playlists.allSatisfy(\.elements.isEmpty)
    }

    public var isNotEmpty: Bool { !isEmpty }

    public init(
        uuid: UUID,
        title: String,
        isEditable: Bool = true,
        collectionType: CollectionType,
        hexColor: HexColor? = nil,
        playlists: [Playlist] = [],
        sortIndex: Int? = nil
    ) {
        self.uuid = uuid
        self.title = title
        self.isEditable = isEditable
        self.collectionType = collectionType
        self.hexColor = hexColor
        self.playlists = playlists
        self.sortIndex = sortIndex
    }

    public mutating func sortPlaylists() {
        playlists = playlists.sorted(by: { lhs, rhs in
            lhs.title.standardCompare(with: rhs.title)
        })
    }
}

extension PlaylistGroup: Codable {}

extension PlaylistGroup {
    public static func createGroup(named title: String? = nil) -> PlaylistGroup {
        .init(uuid: UUID(), title: title ?? "New Group", isEditable: true, collectionType: .user)
    }
}
