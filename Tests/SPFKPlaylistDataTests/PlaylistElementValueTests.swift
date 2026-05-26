// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKMetadataBase
import SPFKTesting
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class PlaylistElementValueTests: TestCaseModel {
    // MARK: - Helpers

    private func makeElement(url: URL = TestBundleResources.shared.tabla_wav) -> PlaylistElement {
        PlaylistElement(mafDescription: .init(url: url))
    }

    // MARK: - stringValue(column:)

    @Test func numberReturnsNil() throws {
        let element = makeElement()
        #expect(element.stringValue(column: .number) == nil)
    }

    @Test func fileReturnsFilename() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = makeElement(url: url)
        #expect(element.stringValue(column: .file) == url.lastPathComponent)
    }

    @Test func typeReturnsExtension() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.fileType = .wav
        let element = PlaylistElement(mafDescription: desc)

        #expect(element.stringValue(column: .fileType) == "wav")
    }

    @Test func markersWithNoMarkers() throws {
        let element = makeElement()
        let value = element.stringValue(column: .markers)
        #expect(value == nil)
    }

    @Test func markersWithMultipleMarkers() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.markerCollection.update(markerDescriptions: [
            AudioMarkerDescription(name: "A", startTime: 0),
            AudioMarkerDescription(name: "B", startTime: 1),
        ])
        let element = PlaylistElement(mafDescription: desc)

        let value = element.stringValue(column: .markers)
        #expect(value == "2 Markers")
    }

    @Test func markersWithOneMarker() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.markerCollection.update(markerDescriptions: [
            AudioMarkerDescription(name: "A", startTime: 0),
        ])
        let element = PlaylistElement(mafDescription: desc)

        let value = element.stringValue(column: .markers)
        #expect(value == "1 Marker")
    }

    // MARK: - stringValue(columnTitled:)

    @Test func stringValueByKnownColumnTitle() throws {
        let element = makeElement()
        // "File" is a known AudioFileTableColumn
        let value = element.stringValue(columnTitled: "File")
        #expect(value == element.filename)
    }

    @Test func stringValueByTagKeyDisplayName() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.tagProperties.set(tag: .title, value: "My Song")
        let element = PlaylistElement(mafDescription: desc)

        let value = element.stringValue(columnTitled: "Title")
        #expect(value == "My Song")
    }

    @Test func stringValueByUnrecognizedName() throws {
        let element = makeElement()
        let value = element.stringValue(columnTitled: "NonexistentColumn123")
        #expect(value == nil)
    }

    // MARK: - sortValue(columnTitled:)

    @Test func sortValueForFileFallsBackToStringValue() throws {
        let element = makeElement()
        let sortVal = element.sortValue(columnTitled: "File")
        let strVal = element.stringValue(columnTitled: "File")
        #expect(sortVal == strVal)
    }

    @Test func sortValueForMarkersReturnsNumericString() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.markerCollection.update(markerDescriptions: [
            AudioMarkerDescription(name: "A", startTime: 0),
            AudioMarkerDescription(name: "B", startTime: 1),
        ])
        let element = PlaylistElement(mafDescription: desc)

        let sortVal = element.sortValue(columnTitled: "Markers")
        // Sort value should be "2" (numeric), not "2 Markers" (display)
        #expect(sortVal == "2")
    }

    @Test func sortValueForTagKey() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.tagProperties.set(tag: .artist, value: "Test Artist")
        let element = PlaylistElement(mafDescription: desc)

        let value = element.sortValue(columnTitled: "Artist")
        #expect(value == "Test Artist")
    }

    @Test func sortValueForUnrecognizedReturnsNil() throws {
        let element = makeElement()
        let value = element.sortValue(columnTitled: "NonexistentColumn123")
        #expect(value == nil)
    }

    // MARK: - BEXT binary path

    @Test func stringValueBEXTOriginatorFromBinaryChunk() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        var bext = BEXTDescription()
        bext.originator = "Test Originator"
        desc.bextDescription = bext
        let element = PlaylistElement(mafDescription: desc)

        #expect(element.stringValue(columnTitled: "BEXT: Originator") == "Test Originator")
    }

    @Test func stringValueBEXTIdentifierReturnsNil() throws {
        // iXML stable identifiers (e.g. "bext.BWF_ORIGINATOR") are not handled by stringValue —
        // they go through ixmlValue at the table cell level.
        let element = makeElement()
        #expect(element.stringValue(columnTitled: "bext.BWF_ORIGINATOR") == nil)
    }

    @Test func sortValueBEXTIdentifierReturnsNil() throws {
        // Sort for descriptor columns routes through ixmlValue, not sortValue.
        let element = makeElement()
        #expect(element.sortValue(columnTitled: "bext.BWF_ORIGINATOR") == nil)
    }

    @Test func sortValueBEXTDisplayTitleReturnsNil() throws {
        // "BEXT: Originator" is not an AudioFileTableColumn or TagKey, so sortValue returns nil.
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        var bext = BEXTDescription()
        bext.originator = "Test Originator"
        desc.bextDescription = bext
        let element = PlaylistElement(mafDescription: desc)

        #expect(element.sortValue(columnTitled: "BEXT: Originator") == nil)
    }
}
