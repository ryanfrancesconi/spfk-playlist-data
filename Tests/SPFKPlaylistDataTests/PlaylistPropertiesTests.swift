// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class PlaylistPropertiesTests: TestCaseModel {
    // MARK: - Helpers

    private func makePlaylist(urls: [URL]) throws -> Playlist {
        let elements = try urls.map { try PlaylistElement(mafDescription: .init(url: $0)) }
        return Playlist(uuid: UUID(), title: "Test", collectionType: .user, elements: elements)
    }

    // MARK: - createPlaylist

    @Test func createPlaylistDefaultTitle() {
        let playlist = Playlist.createPlaylist()
        #expect(playlist.title == "New Playlist")
        #expect(playlist.isEditable == true)
        #expect(playlist.collectionType == .user)
        #expect(playlist.elements.isEmpty)
    }

    @Test func createPlaylistCustomTitle() {
        let playlist = Playlist.createPlaylist(named: "My List")
        #expect(playlist.title == "My List")
    }

    // MARK: - count

    @Test func countMatchesElementCount() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        let playlist = try makePlaylist(urls: urls)
        #expect(playlist.count() == 3)
    }

    @Test func countEmptyPlaylist() {
        let playlist = Playlist(uuid: UUID(), title: "Empty", collectionType: .user)
        #expect(playlist.count() == 0)
    }

    // MARK: - contains(index:)

    @Test func containsValidIndex() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        #expect(playlist.contains(index: 0) == true)
        #expect(playlist.contains(index: 1) == true)
    }

    @Test func containsInvalidIndex() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        #expect(playlist.contains(index: -1) == false)
        #expect(playlist.contains(index: 2) == false)
        #expect(playlist.contains(index: 100) == false)
    }

    // MARK: - index(of:)

    @Test func indexOfPresentURL() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        let playlist = try makePlaylist(urls: urls)
        #expect(playlist.index(of: urls[0]) == 0)
        #expect(playlist.index(of: urls[2]) == 2)
    }

    @Test func indexOfAbsentURL() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        let absent = TestBundleResources.shared.cowbell_wav
        #expect(playlist.index(of: absent) == nil)
    }

    // MARK: - indexes(of:)

    @Test func indexesOfMultipleURLs() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        let playlist = try makePlaylist(urls: urls)
        let result = playlist.indexes(of: [urls[0], urls[2]])
        #expect(result == IndexSet([0, 2]))
    }

    @Test func indexesOfMixedPresentAndAbsent() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        let absent = TestBundleResources.shared.cowbell_wav
        let result = playlist.indexes(of: [urls[0], absent])
        #expect(result == IndexSet(integer: 0))
    }

    @Test func indexesOfEmptyInput() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        let result = playlist.indexes(of: [])
        #expect(result.isEmpty)
    }

    // MARK: - elements(for:)

    @Test func elementsForValidRows() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        let playlist = try makePlaylist(urls: urls)
        let result = playlist.elements(for: IndexSet([0, 2]))
        #expect(result.count == 2)
        #expect(result[0].url == urls[0])
        #expect(result[1].url == urls[2])
    }

    @Test func elementsForOutOfBoundsRows() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        let result = playlist.elements(for: IndexSet([0, 5, 10]))
        #expect(result.count == 1)
        #expect(result[0].url == urls[0])
    }

    // MARK: - element(at:)

    @Test func elementAtValidIndex() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        #expect(playlist.element(at: 0)?.url == urls[0])
        #expect(playlist.element(at: 1)?.url == urls[1])
    }

    @Test func elementAtInvalidIndex() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        #expect(playlist.element(at: -1) == nil)
        #expect(playlist.element(at: 2) == nil)
    }

    // MARK: - contains(url:)

    @Test func containsURL() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)
        #expect(playlist.contains(url: urls[0]) == true)
        #expect(playlist.contains(url: TestBundleResources.shared.cowbell_wav) == false)
    }

    // MARK: - filterContains

    @Test func filterContainsRemovesDuplicates() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)

        let newURL = TestBundleResources.shared.cowbell_wav
        let candidates = try [urls[0], newURL].map { try PlaylistElement(mafDescription: .init(url: $0)) }
        let result = playlist.filterContains(elements: candidates)

        #expect(result.count == 1)
        #expect(result[0].url == newURL)
    }

    @Test func filterContainsAllNew() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let playlist = try makePlaylist(urls: urls)

        let newURL = TestBundleResources.shared.cowbell_wav
        let candidates = try [newURL].map { try PlaylistElement(mafDescription: .init(url: $0)) }
        let result = playlist.filterContains(elements: candidates)

        #expect(result.count == 1)
    }

    // MARK: - nextIndex

    @Test func nextIndexMiddleElement() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        let playlist = try makePlaylist(urls: urls)
        let element = playlist.elements[1]
        #expect(playlist.nextIndex(after: element) == 2)
    }

    @Test func nextIndexLastElement() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        let playlist = try makePlaylist(urls: urls)
        let element = playlist.elements[2]
        #expect(playlist.nextIndex(after: element) == nil)
    }

    @Test func nextIndexFirstElement() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        let playlist = try makePlaylist(urls: urls)
        let element = playlist.elements[0]
        #expect(playlist.nextIndex(after: element) == 1)
    }
}
