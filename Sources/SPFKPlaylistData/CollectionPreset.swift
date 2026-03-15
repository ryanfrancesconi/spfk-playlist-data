import Foundation
import SPFKUtils

public enum CollectionPreset: UInt8 {
    // system playists groups
    case systemGroup = 0

    case searchResults
    case favorites

    /// user default playlists group that is auto-created by the system
    case playlists = 100

    case newPlaylist

    private static let system: Range<UInt8> = systemGroup.rawValue ..< playlists.rawValue
    private static let user: Range<UInt8> = playlists.rawValue ..< 200

    public var uuid: UUID {
        UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, rawValue))
    }

    public var collectionType: CollectionType {
        switch rawValue {
        case Self.system:
            .system

        case Self.user:
            .user

        default:
            .user
        }
    }

    public var title: String {
        switch self {
        case .systemGroup:
            "System"

        case .searchResults:
            "Search Results"

        case .favorites:
            "Favorites"

        case .playlists:
            "Playlists"

        case .newPlaylist:
            "New Playlist"
        }
    }

    public static let searchResultsIdentifier: NodeIdentifier = .init(
        parentId: CollectionPreset.systemGroup.uuid,
        id: CollectionPreset.searchResults.uuid
    )

    public static func playlist(
        preset: CollectionPreset,
        elements: [PlaylistElement]
    ) -> Playlist {
        Playlist(
            uuid: preset.uuid,
            title: preset.title,
            isEditable: false,
            collectionType: .system,
            imageData: nil,
            selectedRowIndexes: elements.isNotEmpty ? [0] : nil,
            elements: elements,
            tableColumns: nil, // TODO: calculate from results
            sortIndex: nil
        )
    }
}
