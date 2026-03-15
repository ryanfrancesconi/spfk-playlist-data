// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class PlaylistSortTests: TestCaseModel {
    // MARK: - Helpers

    private func makePlaylist(urls: [URL]) throws -> Playlist {
        let elements = try urls.map { try PlaylistElement(mafDescription: .init(url: $0)) }
        return Playlist(uuid: UUID(), title: "Test", collectionType: .user, elements: elements)
    }

    // MARK: - updateSortIndexes

    @Test func updateSortIndexesAssignsSequentialValues() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        var playlist = try makePlaylist(urls: urls)

        playlist.updateSortIndexes()

        for (i, element) in playlist.elements.enumerated() {
            #expect(element.sortIndex == i)
        }
    }

    @Test func updateSortIndexesEmptyPlaylist() {
        var playlist = Playlist(uuid: UUID(), title: "Empty", collectionType: .user)

        // Should not crash
        playlist.updateSortIndexes()

        #expect(playlist.elements.isEmpty)
    }

    // MARK: - sort

    @Test func sortByFileAscending() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        var playlist = try makePlaylist(urls: urls)

        playlist.sort(key: "File", direction: true)

        // Verify elements are in ascending filename order
        let filenames = playlist.elements.map(\.filename)
        let sorted = filenames.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        #expect(filenames == sorted)
    }

    @Test func sortByFileDescending() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        var playlist = try makePlaylist(urls: urls)

        playlist.sort(key: "File", direction: false)

        // Verify elements are in descending filename order
        let filenames = playlist.elements.map(\.filename)
        let sorted = filenames.sorted { $0.localizedStandardCompare($1) == .orderedDescending }
        #expect(filenames == sorted)
    }

    @Test func sortUpdatesSortIndexes() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        var playlist = try makePlaylist(urls: urls)

        playlist.sort(key: "File", direction: true)

        for (i, element) in playlist.elements.enumerated() {
            #expect(element.sortIndex == i)
        }
    }

    @Test func sortPreservesElements() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        var playlist = try makePlaylist(urls: urls)
        let originalURLs = Set(playlist.elements.map(\.url))

        playlist.sort(key: "File", direction: true)

        let sortedURLs = Set(playlist.elements.map(\.url))
        #expect(originalURLs == sortedURLs)
    }

    // MARK: - Init calls updateSortIndexes

    @Test func initSetsCorrectSortIndexes() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        let playlist = try makePlaylist(urls: urls)

        for (i, element) in playlist.elements.enumerated() {
            #expect(element.sortIndex == i)
        }
    }
}
