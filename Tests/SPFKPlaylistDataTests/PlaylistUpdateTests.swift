// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKMetadataBase
import SPFKTesting
import SPFKUtils
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class PlaylistUpdateTests: TestCaseModel {
    // MARK: - Helpers

    private func makePlaylist(urls: [URL]) throws -> Playlist {
        let elements = try urls.map { try PlaylistElement(mafDescription: .init(url: $0)) }
        return Playlist(uuid: UUID(), title: "Test", collectionType: .user, elements: elements)
    }

    private func makeElements(urls: [URL]) throws -> [PlaylistElement] {
        try urls.map { try PlaylistElement(mafDescription: .init(url: $0)) }
    }

    // MARK: - update(all:)

    @Test func updateAllReplacesElements() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        let newURLs = Array(TestBundleResources.shared.formats.suffix(2))
        let newElements = try makeElements(urls: newURLs)

        playlist.update(all: newElements)

        #expect(playlist.count() == 2)
        #expect(playlist.elements[0].url == newURLs[0])
        #expect(playlist.elements[1].url == newURLs[1])
    }

    @Test func updateAllUpdatesSortIndexes() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        let newElements = try makeElements(urls: Array(urls.reversed()))
        playlist.update(all: newElements)

        for (i, element) in playlist.elements.enumerated() {
            #expect(element.sortIndex == i)
        }
    }

    // MARK: - update(element:isDirty:) — by URL

    @Test func updateByURLFindsAndUpdates() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        var element = playlist.elements[1]
        element.mafDescription.set(tag: .title, value: "Changed")

        let index = try playlist.update(element: element, isDirty: true)

        #expect(index == 1)
        #expect(playlist.elements[1].isDirty == true)
    }

    @Test func updateByURLThrowsWhenNotFound() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        let missingElement = try PlaylistElement(mafDescription: .init(url: TestBundleResources.shared.cowbell_wav))

        #expect(throws: Error.self) {
            try playlist.update(element: missingElement, isDirty: false)
        }
    }

    // MARK: - update(element:at:isDirty:) — by index

    @Test func updateAtIndexSetsIsDirtyAndSortIndex() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        var element = playlist.elements[2]
        element.mafDescription.set(tag: .title, value: "Changed")

        try playlist.update(element: element, at: 2, isDirty: true)

        #expect(playlist.elements[2].isDirty == true)
        #expect(playlist.elements[2].sortIndex == 2)
    }

    @Test func updateAtInvalidIndexThrows() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        let element = playlist.elements[0]

        #expect(throws: Error.self) {
            try playlist.update(element: element, at: 5, isDirty: false)
        }
    }

    // MARK: - isDirty comparison

    @Test func updateUnchangedElementStaysClean() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        // Same element, no content changes — isDirty should remain false
        let element = playlist.elements[1]
        try playlist.update(element: element, at: 1, isDirty: true)

        #expect(playlist.elements[1].isDirty == false)
    }

    @Test func updateChangedElementBecomesDirty() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        var element = playlist.elements[1]
        element.mafDescription.set(tag: .artist, value: "New Artist")

        try playlist.update(element: element, at: 1, isDirty: true)

        #expect(playlist.elements[1].isDirty == true)
    }

    @Test func updateClearsDirtyRegardlessOfContent() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        // First, make the element dirty by changing content
        var element = playlist.elements[1]
        element.mafDescription.set(tag: .title, value: "Modified")
        try playlist.update(element: element, at: 1, isDirty: true)
        #expect(playlist.elements[1].isDirty == true)

        // Now clear dirty with isDirty: false (simulates save)
        let saved = playlist.elements[1]
        try playlist.update(element: saved, at: 1, isDirty: false)
        #expect(playlist.elements[1].isDirty == false)
    }

    @Test func updateImageDescriptionDriftDoesNotMarkDirty() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        // Simulate non-deterministic thumbnail re-encode: imageDescription differs
        // but isImageDirty is NOT set (no actual image change occurred)
        var element = playlist.elements[1]
        element.mafDescription.imageDescription.description = "Front Cover"

        try playlist.update(element: element, at: 1, isDirty: true)

        #expect(playlist.elements[1].isDirty == false)
    }

    @Test func updateWithIsImageDirtyMarksDirty() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        // Simulate a real image change: isImageDirty is set by the coordinator
        var element = playlist.elements[1]
        element.isImageDirty = true

        try playlist.update(element: element, at: 1, isDirty: true)

        #expect(playlist.elements[1].isDirty == true)
        #expect(playlist.elements[1].isImageDirty == true)
    }

    @Test func updateColorChangeMarksAsDirty() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        var element = playlist.elements[0]
        element.hexColor = HexColor(red: 1, green: 0, blue: 0)

        try playlist.update(element: element, at: 0, isDirty: true)

        #expect(playlist.elements[0].isDirty == true)
    }

    // MARK: - insert(elements:at:)

    @Test func insertAtBeginning() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        let newURL = TestBundleResources.shared.cowbell_wav
        let newElements = try makeElements(urls: [newURL])

        let indexes = try playlist.insert(elements: newElements, at: 0)

        #expect(playlist.count() == 3)
        #expect(playlist.elements[0].url == newURL)
        #expect(indexes == IndexSet(integer: 0))
    }

    @Test func insertAtEnd() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        let newURL = TestBundleResources.shared.cowbell_wav
        let newElements = try makeElements(urls: [newURL])

        let indexes = try playlist.insert(elements: newElements, at: playlist.count())

        #expect(playlist.count() == 3)
        #expect(playlist.elements[2].url == newURL)
        #expect(indexes == IndexSet(integer: 2))
    }

    @Test func insertMultipleElements() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(1))
        var playlist = try makePlaylist(urls: urls)

        let newURLs = Array(TestBundleResources.shared.formats.suffix(3))
        let newElements = try makeElements(urls: newURLs)

        let indexes = try playlist.insert(elements: newElements, at: 0)

        #expect(playlist.count() == 4)
        #expect(indexes == IndexSet(integersIn: 0 ... 2))
    }

    @Test func insertEmptyThrows() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        #expect(throws: Error.self) {
            try playlist.insert(elements: [], at: 0)
        }
    }

    @Test func insertWithRemoveDuplicatesFiltersExisting() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        let newURL = TestBundleResources.shared.cowbell_wav
        let mixed = try makeElements(urls: [urls[0], newURL])

        let indexes = try playlist.insert(elements: mixed, at: 0, removeDuplicates: true)

        // Only the new URL should be inserted
        #expect(playlist.count() == 3)
        #expect(indexes.count == 1)
    }

    @Test func insertWithRemoveDuplicatesAllDuplicatesThrows() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        let duplicates = try makeElements(urls: urls)

        #expect(throws: Error.self) {
            try playlist.insert(elements: duplicates, at: 0, removeDuplicates: true)
        }
    }

    @Test func insertUpdatesSortIndexes() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        let newElements = try makeElements(urls: [TestBundleResources.shared.cowbell_wav])
        _ = try playlist.insert(elements: newElements, at: 0)

        for (i, element) in playlist.elements.enumerated() {
            #expect(element.sortIndex == i)
        }
    }

    // MARK: - move(indexes:to:)

    @Test func moveForward() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        let result = playlist.move(indexes: IndexSet(integer: 0), to: 3)

        #expect(result != nil)
        #expect(playlist.count() == 3)
        #expect(playlist.elements[2].url == urls[0])
    }

    @Test func moveBackward() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        let result = playlist.move(indexes: IndexSet(integer: 2), to: 0)

        #expect(result != nil)
        #expect(playlist.elements[0].url == urls[2])
        #expect(result == IndexSet(integer: 0))
    }

    @Test func moveMultiple() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        var playlist = try makePlaylist(urls: urls)

        let result = playlist.move(indexes: IndexSet([0, 1]), to: 4)

        #expect(result != nil)
        #expect(result?.count == 2)
        #expect(playlist.count() == 4)
    }

    @Test func moveEmptyReturnsNil() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        var playlist = try makePlaylist(urls: urls)

        let result = playlist.move(indexes: IndexSet(), to: 0)

        #expect(result == nil)
    }

    @Test func moveUpdatesSortIndexes() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        _ = playlist.move(indexes: IndexSet(integer: 0), to: 3)

        for (i, element) in playlist.elements.enumerated() {
            #expect(element.sortIndex == i)
        }
    }

    @Test func moveClampsToEnd() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        // Move to beyond bounds should clamp
        let result = playlist.move(indexes: IndexSet(integer: 0), to: 999)

        #expect(result != nil)
        // Element should end up at the end
        #expect(playlist.elements.last?.url == urls[0])
    }

    // MARK: - remove(indexes:)

    @Test func removeSingleIndex() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        playlist.remove(indexes: IndexSet(integer: 1))

        #expect(playlist.count() == 2)
        #expect(playlist.elements[0].url == urls[0])
        #expect(playlist.elements[1].url == urls[2])
    }

    @Test func removeMultipleIndexes() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        var playlist = try makePlaylist(urls: urls)

        playlist.remove(indexes: IndexSet([0, 2]))

        #expect(playlist.count() == 2)
        #expect(playlist.elements[0].url == urls[1])
        #expect(playlist.elements[1].url == urls[3])
    }

    @Test func removeAllCallsRemoveAll() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        playlist.remove(indexes: IndexSet(integersIn: 0 ..< 3))

        #expect(playlist.count() == 0)
        #expect(playlist.elements.isEmpty)
    }

    @Test func removeUpdatesSortIndexes() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(4))
        var playlist = try makePlaylist(urls: urls)

        playlist.remove(indexes: IndexSet(integer: 1))

        for (i, element) in playlist.elements.enumerated() {
            #expect(element.sortIndex == i)
        }
    }

    // MARK: - removeAll

    @Test func removeAllEmptiesPlaylist() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        var playlist = try makePlaylist(urls: urls)

        playlist.removeAll()

        #expect(playlist.count() == 0)
        #expect(playlist.elements.isEmpty)
    }
}
