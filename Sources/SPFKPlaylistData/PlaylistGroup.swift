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

extension PlaylistGroup: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid, title, isEditable, collectionType, hexColor, playlists, sortIndex
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        isEditable = try container.decodeIfPresent(Bool.self, forKey: .isEditable) ?? true
        collectionType = try container.decodeIfPresent(CollectionType.self, forKey: .collectionType) ?? .user
        hexColor = try container.decodeIfPresent(HexColor.self, forKey: .hexColor)
        playlists = try container.decodeIfPresent([Playlist].self, forKey: .playlists) ?? []
        sortIndex = try container.decodeIfPresent(Int.self, forKey: .sortIndex)
    }

    // playlists is omitted from encoding — v2 stores each playlist as a separate file.
    // Decoding is unchanged: playlists defaults to [] when the key is absent, so v1
    // files (which include playlists) still decode correctly.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(title, forKey: .title)
        try container.encode(isEditable, forKey: .isEditable)
        try container.encode(collectionType, forKey: .collectionType)
        try container.encodeIfPresent(hexColor, forKey: .hexColor)
        try container.encodeIfPresent(sortIndex, forKey: .sortIndex)
    }
}

extension PlaylistGroup {
    public static func createGroup(named title: String? = nil) -> PlaylistGroup {
        .init(uuid: UUID(), title: title ?? "New Group", isEditable: true, collectionType: .user)
    }
}
