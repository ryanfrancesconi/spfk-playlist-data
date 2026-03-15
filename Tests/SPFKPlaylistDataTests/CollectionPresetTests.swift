// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation
import SPFKBase
import SPFKTesting
import SPFKUtils
import Testing

@testable import SPFKPlaylistData

final class CollectionPresetTests: TestCaseModel {
    // MARK: - Raw Values

    @Test func systemGroupRawValue() {
        #expect(CollectionPreset.systemGroup.rawValue == 0)
    }

    @Test func searchResultsRawValue() {
        #expect(CollectionPreset.searchResults.rawValue == 1)
    }

    @Test func favoritesRawValue() {
        #expect(CollectionPreset.favorites.rawValue == 2)
    }

    @Test func playlistsRawValue() {
        #expect(CollectionPreset.playlists.rawValue == 100)
    }

    @Test func newPlaylistRawValue() {
        #expect(CollectionPreset.newPlaylist.rawValue == 101)
    }

    // MARK: - Collection Types

    @Test func systemGroupIsSystemType() {
        #expect(CollectionPreset.systemGroup.collectionType == .system)
    }

    @Test func searchResultsIsSystemType() {
        #expect(CollectionPreset.searchResults.collectionType == .system)
    }

    @Test func favoritesIsSystemType() {
        #expect(CollectionPreset.favorites.collectionType == .system)
    }

    @Test func playlistsIsUserType() {
        #expect(CollectionPreset.playlists.collectionType == .user)
    }

    @Test func newPlaylistIsUserType() {
        #expect(CollectionPreset.newPlaylist.collectionType == .user)
    }

    // MARK: - Titles

    @Test func titles() {
        #expect(CollectionPreset.systemGroup.title == "System")
        #expect(CollectionPreset.searchResults.title == "Search Results")
        #expect(CollectionPreset.favorites.title == "Favorites")
        #expect(CollectionPreset.playlists.title == "Playlists")
        #expect(CollectionPreset.newPlaylist.title == "New Playlist")
    }

    // MARK: - UUID

    @Test func uuidEncodesRawValue() {
        let uuid = CollectionPreset.systemGroup.uuid
        // rawValue 0 should produce a UUID with all zeros
        #expect(uuid == UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)))
    }

    @Test func uuidUniquePerPreset() {
        let uuids = [
            CollectionPreset.systemGroup.uuid,
            CollectionPreset.searchResults.uuid,
            CollectionPreset.favorites.uuid,
            CollectionPreset.playlists.uuid,
            CollectionPreset.newPlaylist.uuid,
        ]

        let uniqueUUIDs = Set(uuids)
        #expect(uniqueUUIDs.count == uuids.count)
    }
}
