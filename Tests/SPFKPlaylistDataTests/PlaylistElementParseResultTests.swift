// Copyright Ryan Francesconi. All Rights Reserved.

import AudioToolbox
import Foundation
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class PlaylistElementParseResultTests: TestCaseModel {
    // MARK: - Helpers

    private func makeResult(url: URL, element: PlaylistElement?, errorCode: Int? = nil) -> PlaylistElementParseResult {
        let error: Error? = errorCode.map {
            NSError(domain: "test", code: $0)
        }
        return PlaylistElementParseResult(url: url, element: element, error: error)
    }

    // MARK: - thumbnailImage

    @Test func thumbnailImageNilWhenElementNil() {
        let url = TestBundleResources.shared.tabla_wav
        let result = PlaylistElementParseResult(url: url, element: nil, error: nil)

        #expect(result.thumbnailImage == nil)
    }

    // MARK: - [PlaylistElementParseResult].elements

    @Test func elementsFiltersOutNils() throws {
        let url1 = TestBundleResources.shared.tabla_wav
        let url2 = TestBundleResources.shared.tabla_mp3

        let element1 = try PlaylistElement(mafDescription: .init(url: url1))

        let results: [PlaylistElementParseResult] = [
            PlaylistElementParseResult(url: url1, element: element1, error: nil),
            PlaylistElementParseResult(url: url2, element: nil, error: NSError(domain: "test", code: 1)),
        ]

        let elements = results.elements
        #expect(elements.count == 1)
        #expect(elements[0].url == url1)
    }

    @Test func elementsAllValid() throws {
        let url1 = TestBundleResources.shared.tabla_wav
        let url2 = TestBundleResources.shared.tabla_mp3

        let element1 = try PlaylistElement(mafDescription: .init(url: url1))
        let element2 = try PlaylistElement(mafDescription: .init(url: url2))

        let results: [PlaylistElementParseResult] = [
            PlaylistElementParseResult(url: url1, element: element1, error: nil),
            PlaylistElementParseResult(url: url2, element: element2, error: nil),
        ]

        #expect(results.elements.count == 2)
    }

    // MARK: - [PlaylistElementParseResult].unsupportedFiles

    @Test func unsupportedFilesReturnsOnlyUnsupportedErrorCode() throws {
        let url1 = TestBundleResources.shared.tabla_wav
        let url2 = TestBundleResources.shared.tabla_mp3
        let url3 = TestBundleResources.shared.cowbell_wav

        let results: [PlaylistElementParseResult] = [
            // nil element + unsupported file type error → should be in unsupportedFiles
            makeResult(
                url: url1,
                element: nil,
                errorCode: Int(kAudioFileStreamError_UnsupportedFileType)
            ),
            // nil element + different error code → should NOT be in unsupportedFiles
            makeResult(url: url2, element: nil, errorCode: 42),
            // valid element → should NOT be in unsupportedFiles
            PlaylistElementParseResult(
                url: url3,
                element: try PlaylistElement(mafDescription: .init(url: url3)),
                error: nil
            ),
        ]

        let unsupported = results.unsupportedFiles
        #expect(unsupported.count == 1)
        #expect(unsupported[0] == url1)
    }

    @Test func unsupportedFilesEmptyWhenAllValid() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: .init(url: url))

        let results: [PlaylistElementParseResult] = [
            PlaylistElementParseResult(url: url, element: element, error: nil),
        ]

        #expect(results.unsupportedFiles.isEmpty)
    }

    @Test func unsupportedFilesSkipsResultsWithElement() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: .init(url: url))

        // Even with unsupported error code, if element is non-nil, it's not unsupported
        let results: [PlaylistElementParseResult] = [
            PlaylistElementParseResult(
                url: url,
                element: element,
                error: NSError(domain: "test", code: Int(kAudioFileStreamError_UnsupportedFileType))
            ),
        ]

        #expect(results.unsupportedFiles.isEmpty)
    }
}
