// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation
import SPFKBase
import SPFKUtils

public struct Playlist: Sendable, Hashable, Equatable {
    public static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.uuid == rhs.uuid &&
            lhs.elements == rhs.elements &&
            lhs.selectedRowIndexes == rhs.selectedRowIndexes &&
            lhs.tableColumns == rhs.tableColumns &&
            lhs.columnLayout == rhs.columnLayout &&
            lhs.hasMissingFiles == rhs.hasMissingFiles
    }

    public var uuid: UUID
    public var title: String
    public var isEditable: Bool
    public var collectionType: CollectionType

    /// A custom image for this playlist
    public var imageData: Data?
    public var hexColor: HexColor?
    public var elements: [PlaylistElement]
    public var selectedRowIndexes: [Int]?
    public var tableColumns: [String]?
    public var sortIndex: Int?

    /// Full column layout (order, width, visibility) for this playlist's table view.
    /// Nil means no layout has been saved yet; fall back to the workspace-level layout.
    public var columnLayout: [TableColumnState]?

    /// True when one or more elements could not be resolved at last load (e.g. files on a
    /// disconnected volume). Persisted so the warning icon survives relaunches without
    /// requiring the user to open the playlist again.
    public var hasMissingFiles: Bool

    public init(
        uuid: UUID,
        title: String,
        isEditable: Bool = true,
        collectionType: CollectionType,
        imageData: Data? = nil,
        hexColor: HexColor? = nil,
        selectedRowIndexes: [Int]? = nil,
        elements: [PlaylistElement] = [],
        tableColumns: [String]? = nil,
        sortIndex: Int? = nil,
        columnLayout: [TableColumnState]? = nil,
        hasMissingFiles: Bool = false
    ) {
        self.uuid = uuid
        self.title = title
        self.isEditable = isEditable
        self.collectionType = collectionType
        self.imageData = imageData
        self.hexColor = hexColor
        self.selectedRowIndexes = selectedRowIndexes
        self.elements = elements
        self.tableColumns = tableColumns
        self.sortIndex = sortIndex
        self.columnLayout = columnLayout
        self.hasMissingFiles = hasMissingFiles

        updateSortIndexes()
    }
}

extension Playlist: Codable, Serializable {
    enum CodingKeys: String, CodingKey {
        case uuid, title, isEditable, collectionType
        case imageData, hexColor, elements
        case selectedRowIndexes, tableColumns, sortIndex
        case columnLayout
        case hasMissingFiles
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        title = try container.decode(String.self, forKey: .title)
        isEditable = try container.decode(Bool.self, forKey: .isEditable)
        collectionType = try container.decode(CollectionType.self, forKey: .collectionType)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        hexColor = try container.decodeIfPresent(HexColor.self, forKey: .hexColor)
        elements = try container.decode([PlaylistElement].self, forKey: .elements)
        selectedRowIndexes = try container.decodeIfPresent([Int].self, forKey: .selectedRowIndexes)
        tableColumns = try container.decodeIfPresent([String].self, forKey: .tableColumns)
        sortIndex = try container.decodeIfPresent(Int.self, forKey: .sortIndex)
        columnLayout = try container.decodeIfPresent([TableColumnState].self, forKey: .columnLayout)
        hasMissingFiles = try container.decodeIfPresent(Bool.self, forKey: .hasMissingFiles) ?? false
        updateSortIndexes()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(title, forKey: .title)
        try container.encode(isEditable, forKey: .isEditable)
        try container.encode(collectionType, forKey: .collectionType)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encodeIfPresent(hexColor, forKey: .hexColor)
        try container.encode(elements, forKey: .elements)
        try container.encodeIfPresent(selectedRowIndexes, forKey: .selectedRowIndexes)
        try container.encodeIfPresent(tableColumns, forKey: .tableColumns)
        try container.encodeIfPresent(sortIndex, forKey: .sortIndex)
        try container.encodeIfPresent(columnLayout, forKey: .columnLayout)
        try container.encode(hasMissingFiles, forKey: .hasMissingFiles)
    }
}
