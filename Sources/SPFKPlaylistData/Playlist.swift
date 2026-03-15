// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation
import SPFKBase

public struct Playlist: Sendable, Hashable, Equatable {
    public static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.uuid == rhs.uuid &&
            lhs.elements == rhs.elements &&
            lhs.selectedRowIndexes == rhs.selectedRowIndexes &&
            lhs.tableColumns == rhs.tableColumns
    }

    public var uuid: UUID
    public var title: String
    public var isEditable: Bool
    public var collectionType: CollectionType

    /// A custom image for this playlist
    public var imageData: Data?
    public var elements: [PlaylistElement]
    public var selectedRowIndexes: [Int]?
    public var tableColumns: [String]?
    public var sortIndex: Int?

    public init(
        uuid: UUID,
        title: String,
        isEditable: Bool = true,
        collectionType: CollectionType,
        imageData: Data? = nil,
        selectedRowIndexes: [Int]? = nil,
        elements: [PlaylistElement] = [],
        tableColumns: [String]? = nil,
        sortIndex: Int? = nil,
    ) {
        self.uuid = uuid
        self.title = title
        self.isEditable = isEditable
        self.collectionType = collectionType
        self.imageData = imageData
        self.selectedRowIndexes = selectedRowIndexes
        self.elements = elements
        self.tableColumns = tableColumns
        self.sortIndex = sortIndex

        updateSortIndexes()
    }
}

extension Playlist: Codable, Serializable {
    enum CodingKeys: String, CodingKey {
        case uuid
        case version
        case title
        case isEditable
        case collectionType
        case imageData
        case selectedRowIndexes
        case elements
        case tableColumns
        case sortIndex
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        uuid = try container.decode(UUID.self, forKey: .uuid)
        elements = try container.decode([PlaylistElement].self, forKey: .elements)
        title = try container.decode(String.self, forKey: .title)
        isEditable = try container.decode(Bool.self, forKey: .isEditable)
        collectionType = try container.decode(CollectionType.self, forKey: .collectionType)

        // optionals
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        selectedRowIndexes = try container.decodeIfPresent([Int].self, forKey: .selectedRowIndexes)
        tableColumns = try container.decodeIfPresent([String].self, forKey: .tableColumns)
        sortIndex = try container.decodeIfPresent(Int.self, forKey: .sortIndex)

        updateSortIndexes()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(uuid, forKey: .uuid)
        try container.encode(elements, forKey: .elements)
        try container.encode(title, forKey: .title)
        try container.encode(isEditable, forKey: .isEditable)
        try container.encode(collectionType, forKey: .collectionType)

        // optionals
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encodeIfPresent(selectedRowIndexes, forKey: .selectedRowIndexes)
        try container.encodeIfPresent(tableColumns, forKey: .tableColumns)
        try container.encodeIfPresent(sortIndex, forKey: .sortIndex)
    }
}
