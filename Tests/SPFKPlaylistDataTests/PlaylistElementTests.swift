// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKMetadataBase
import SPFKTesting
import SPFKUtils
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class PlaylistElementTests: TestCaseModel {
    // MARK: - Equality

    @Test func equalityIsURLBased() throws {
        let url = TestBundleResources.shared.tabla_wav
        let a = try PlaylistElement(mafDescription: .init(url: url))
        let b = try PlaylistElement(mafDescription: .init(url: url))

        #expect(a == b)
    }

    @Test func equalityDifferentURLs() throws {
        let a = try PlaylistElement(mafDescription: .init(url: TestBundleResources.shared.tabla_wav))
        let b = try PlaylistElement(mafDescription: .init(url: TestBundleResources.shared.tabla_mp3))

        #expect(a != b)
    }

    @Test func equalitySameURLDifferentMetadata() throws {
        let url = TestBundleResources.shared.tabla_wav
        var descA = MetaAudioFileDescription(url: url)
        descA.tagProperties.set(tag: .title, value: "Title A")

        var descB = MetaAudioFileDescription(url: url)
        descB.tagProperties.set(tag: .title, value: "Title B")

        let a = try PlaylistElement(mafDescription: descA)
        let b = try PlaylistElement(mafDescription: descB)

        // Same URL = equal, regardless of metadata
        #expect(a == b)
    }

    // MARK: - Hash

    @Test func hashMatchesForSameURL() throws {
        let url = TestBundleResources.shared.tabla_wav
        let a = try PlaylistElement(mafDescription: .init(url: url))
        let b = try PlaylistElement(mafDescription: .init(url: url))

        #expect(a.hashValue == b.hashValue)
    }

    // MARK: - Computed Properties

    @Test func urlComputedProperty() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: .init(url: url))

        #expect(element.url == url)
    }

    @Test func filename() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: .init(url: url))

        #expect(element.filename == url.lastPathComponent)
    }

    @Test func filenameNoExtension() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: .init(url: url))

        #expect(element.filenameNoExtension == url.deletingPathExtension().lastPathComponent)
    }

    // MARK: - needsSave

    @Test func needsSaveDefaultsFalse() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: .init(url: url))

        #expect(element.needsSave == false)
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        let url = TestBundleResources.shared.tabla_wav
        let original = try PlaylistElement(mafDescription: .init(url: url), sortIndex: 5)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PlaylistElement.self, from: data)

        #expect(decoded.url == original.url)
        #expect(decoded.sortIndex == original.sortIndex)
    }

    @Test func codablePreservesHexColor() throws {
        let url = TestBundleResources.shared.tabla_wav
        let hexColor = HexColor(string: "FF0000FF")
        let original = try PlaylistElement(mafDescription: .init(url: url), hexColor: hexColor)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PlaylistElement.self, from: data)

        #expect(decoded.hexColor == hexColor)
    }

    @Test func codableNeedsSaveDecodesAsFalseWhenMissing() throws {
        let url = TestBundleResources.shared.tabla_wav
        var original = try PlaylistElement(mafDescription: .init(url: url))
        original.needsSave = false

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PlaylistElement.self, from: data)

        #expect(decoded.needsSave == false)
    }

    @Test func codableNeedsSavePreservesTrue() throws {
        let url = TestBundleResources.shared.tabla_wav
        var original = try PlaylistElement(mafDescription: .init(url: url))
        original.needsSave = true

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PlaylistElement.self, from: data)

        #expect(decoded.needsSave == true)
    }

    // MARK: - Search

    @Test func searchableValuePopulatedOnInit() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: .init(url: url))

        // Should contain at least the filename
        #expect(element.searchableValue.isNotEmpty)
    }

    @Test func searchableValueUpdatesOnMafDescriptionChange() throws {
        let url = TestBundleResources.shared.tabla_wav
        var element = try PlaylistElement(mafDescription: .init(url: url))
        let initialSearch = element.searchableValue

        element.mafDescription.tagProperties.set(tag: .title, value: "New Title XYZ")
        let updatedSearch = element.searchableValue

        // After setting a tag, search value should change
        #expect(initialSearch != updatedSearch)
    }
}
