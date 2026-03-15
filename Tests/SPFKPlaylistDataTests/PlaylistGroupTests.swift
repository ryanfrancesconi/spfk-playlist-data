// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class PlaylistGroupTests: TestCaseModel {
    // MARK: - Helpers

    private func makePlaylist(
        title: String = "Test",
        urls: [URL] = []
    ) throws -> Playlist {
        let elements = try urls.map { try PlaylistElement(mafDescription: .init(url: $0)) }
        return Playlist(uuid: UUID(), title: title, collectionType: .user, elements: elements)
    }

    // MARK: - Equality

    @Test func equalityIsUUIDBased() throws {
        let uuid = UUID()
        let a = PlaylistGroup(uuid: uuid, title: "A", collectionType: .user)
        let b = PlaylistGroup(uuid: uuid, title: "B", collectionType: .system)

        #expect(a == b)
    }

    @Test func equalityDifferentUUID() {
        let a = PlaylistGroup(uuid: UUID(), title: "Same", collectionType: .user)
        let b = PlaylistGroup(uuid: UUID(), title: "Same", collectionType: .user)

        #expect(a != b)
    }

    // MARK: - titleAndID

    @Test func titleAndIDFormat() {
        let uuid = UUID()
        let group = PlaylistGroup(uuid: uuid, title: "My Group", collectionType: .user)

        #expect(group.titleAndID == "My Group (\(uuid.uuidString))")
    }

    // MARK: - isEmpty / isNotEmpty

    @Test func isEmptyWithNoPlaylists() {
        let group = PlaylistGroup(uuid: UUID(), title: "G", collectionType: .user)

        #expect(group.isEmpty == true)
        #expect(group.isNotEmpty == false)
    }

    @Test func isEmptyWithEmptyPlaylists() {
        let emptyPlaylist = Playlist(uuid: UUID(), title: "P", collectionType: .user)
        let group = PlaylistGroup(uuid: UUID(), title: "G", collectionType: .user, playlists: [emptyPlaylist])

        #expect(group.isEmpty == true)
    }

    @Test func isNotEmptyWithPopulatedPlaylist() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(1))
        let playlist = try makePlaylist(urls: urls)
        let group = PlaylistGroup(uuid: UUID(), title: "G", collectionType: .user, playlists: [playlist])

        #expect(group.isEmpty == false)
        #expect(group.isNotEmpty == true)
    }

    @Test func isNotEmptyWithMixedPlaylists() throws {
        let emptyPlaylist = Playlist(uuid: UUID(), title: "Empty", collectionType: .user)
        let urls = Array(TestBundleResources.shared.formats.prefix(1))
        let populatedPlaylist = try makePlaylist(urls: urls)

        let group = PlaylistGroup(
            uuid: UUID(), title: "G", collectionType: .user,
            playlists: [emptyPlaylist, populatedPlaylist]
        )

        // One non-empty playlist means the group is not empty
        #expect(group.isNotEmpty == true)
    }

    // MARK: - sortPlaylists

    @Test func sortPlaylistsByTitle() throws {
        let c = Playlist(uuid: UUID(), title: "Zulu", collectionType: .user)
        let a = Playlist(uuid: UUID(), title: "Alpha", collectionType: .user)
        let b = Playlist(uuid: UUID(), title: "Mike", collectionType: .user)

        var group = PlaylistGroup(
            uuid: UUID(), title: "G", collectionType: .user,
            playlists: [c, a, b]
        )

        group.sortPlaylists()

        #expect(group.playlists[0].title == "Alpha")
        #expect(group.playlists[1].title == "Mike")
        #expect(group.playlists[2].title == "Zulu")
    }

    // MARK: - createGroup

    @Test func createGroupDefaultTitle() {
        let group = PlaylistGroup.createGroup()

        #expect(group.title == "New Group")
        #expect(group.isEditable == true)
        #expect(group.collectionType == .user)
        #expect(group.playlists.isEmpty)
    }

    @Test func createGroupCustomTitle() {
        let group = PlaylistGroup.createGroup(named: "Custom")

        #expect(group.title == "Custom")
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        let playlist = Playlist(uuid: UUID(), title: "P1", collectionType: .user)
        let original = PlaylistGroup(
            uuid: UUID(), title: "Group",
            isEditable: false,
            collectionType: .system,
            playlists: [playlist],
            sortIndex: 3
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PlaylistGroup.self, from: data)

        #expect(decoded == original)
        #expect(decoded.title == original.title)
        #expect(decoded.isEditable == original.isEditable)
        #expect(decoded.collectionType == original.collectionType)
        #expect(decoded.playlists.count == 1)
        #expect(decoded.sortIndex == original.sortIndex)
    }

    @Test func codableNilSortIndex() throws {
        let original = PlaylistGroup(uuid: UUID(), title: "G", collectionType: .user)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PlaylistGroup.self, from: data)

        #expect(decoded.sortIndex == nil)
    }
}
