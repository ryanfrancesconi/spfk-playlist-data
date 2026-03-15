// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class PlaylistTests: TestCaseModel {
    // MARK: - Helpers

    private func makePlaylist(urls: [URL]) throws -> Playlist {
        let elements = try urls.map { try PlaylistElement(mafDescription: .init(url: $0)) }
        return Playlist(uuid: UUID(), title: "Test", collectionType: .user, elements: elements)
    }

    // MARK: - Equality

    @Test func equalitySameUUIDAndElements() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let elements = try urls.map { try PlaylistElement(mafDescription: .init(url: $0)) }
        let uuid = UUID()

        let a = Playlist(uuid: uuid, title: "A", collectionType: .user, elements: elements)
        let b = Playlist(uuid: uuid, title: "B", collectionType: .user, elements: elements)

        // Title differs but equality ignores title
        #expect(a == b)
    }

    @Test func equalityDifferentUUID() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let elements = try urls.map { try PlaylistElement(mafDescription: .init(url: $0)) }

        let a = Playlist(uuid: UUID(), title: "A", collectionType: .user, elements: elements)
        let b = Playlist(uuid: UUID(), title: "A", collectionType: .user, elements: elements)

        #expect(a != b)
    }

    @Test func equalityIgnoresImageData() throws {
        let uuid = UUID()
        let a = Playlist(uuid: uuid, title: "A", collectionType: .user, imageData: Data([1, 2, 3]))
        let b = Playlist(uuid: uuid, title: "A", collectionType: .user, imageData: nil)

        #expect(a == b)
    }

    @Test func equalityIgnoresTitle() throws {
        let uuid = UUID()
        let a = Playlist(uuid: uuid, title: "Alpha", collectionType: .user)
        let b = Playlist(uuid: uuid, title: "Beta", collectionType: .user)

        #expect(a == b)
    }

    @Test func equalityChecksSelectedRowIndexes() throws {
        let uuid = UUID()
        let a = Playlist(uuid: uuid, title: "A", collectionType: .user, selectedRowIndexes: [0, 1])
        let b = Playlist(uuid: uuid, title: "A", collectionType: .user, selectedRowIndexes: [2])

        #expect(a != b)
    }

    @Test func equalityChecksTableColumns() throws {
        let uuid = UUID()
        let a = Playlist(uuid: uuid, title: "A", collectionType: .user, tableColumns: ["Title"])
        let b = Playlist(uuid: uuid, title: "A", collectionType: .user, tableColumns: ["Artist"])

        #expect(a != b)
    }

    // MARK: - Codable Round-Trip

    @Test func codableRoundTrip() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(2))
        let original = try makePlaylist(urls: urls)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Playlist.self, from: data)

        #expect(decoded == original)
        #expect(decoded.title == original.title)
        #expect(decoded.isEditable == original.isEditable)
        #expect(decoded.collectionType == original.collectionType)
        #expect(decoded.count() == original.count())
    }

    @Test func codablePreservesOptionals() throws {
        let original = Playlist(
            uuid: UUID(),
            title: "Test",
            collectionType: .user,
            imageData: Data([1, 2, 3]),
            selectedRowIndexes: [0, 2],
            tableColumns: ["Title", "Artist"],
            sortIndex: 5
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Playlist.self, from: data)

        #expect(decoded.imageData == original.imageData)
        #expect(decoded.selectedRowIndexes == original.selectedRowIndexes)
        #expect(decoded.tableColumns == original.tableColumns)
        #expect(decoded.sortIndex == original.sortIndex)
    }

    @Test func codableNilOptionals() throws {
        let original = Playlist(uuid: UUID(), title: "Test", collectionType: .user)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Playlist.self, from: data)

        #expect(decoded.imageData == nil)
        #expect(decoded.selectedRowIndexes == nil)
        #expect(decoded.tableColumns == nil)
        #expect(decoded.sortIndex == nil)
    }

    @Test func decodingCallsUpdateSortIndexes() throws {
        let urls = Array(TestBundleResources.shared.formats.prefix(3))
        let original = try makePlaylist(urls: urls)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Playlist.self, from: data)

        for (i, element) in decoded.elements.enumerated() {
            #expect(element.sortIndex == i)
        }
    }
}
