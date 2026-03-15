// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import AppKit
import Foundation
import SPFKBase
import SPFKTesting
import SPFKUtils
import Testing

@testable import SPFKPlaylistData

final class AudioFileTableColumnTests: TestCaseModel {
    // MARK: - Display Names

    @Test func displayNameMatchesRawValue() {
        for column in AudioFileTableColumn.allCases {
            #expect(column.displayName == column.rawValue)
        }
    }

    // MARK: - Init from Display Name

    @Test func initFromValidDisplayName() {
        let column = AudioFileTableColumn(displayName: "File")
        #expect(column == .file)
    }

    @Test func initFromInvalidDisplayName() {
        let column = AudioFileTableColumn(displayName: "Nonexistent")
        #expect(column == nil)
    }

    @Test func initRoundTripsAllCases() {
        for column in AudioFileTableColumn.allCases {
            let roundTripped = AudioFileTableColumn(displayName: column.displayName)
            #expect(roundTripped == column)
        }
    }

    // MARK: - Show Image

    @Test func onlyFileShowsImage() {
        #expect(AudioFileTableColumn.file.showImage == true)

        for column in AudioFileTableColumn.allCases where column != .file {
            #expect(column.showImage == false)
        }
    }

    // MARK: - Default Width

    @Test func defaultWidths() {
        #expect(AudioFileTableColumn.number.defaultWidth == 40)
        #expect(AudioFileTableColumn.type.defaultWidth == 60)
        #expect(AudioFileTableColumn.fileSize.defaultWidth == 60)
        #expect(AudioFileTableColumn.finderTags.defaultWidth == 80)
        #expect(AudioFileTableColumn.file.defaultWidth == 200)

        // These should be nil (use default)
        #expect(AudioFileTableColumn.duration.defaultWidth == nil)
        #expect(AudioFileTableColumn.format.defaultWidth == nil)
        #expect(AudioFileTableColumn.markers.defaultWidth == nil)
    }

    // MARK: - Min / Max Width

    @Test func minWidthIsUniform() {
        for column in AudioFileTableColumn.allCases {
            #expect(column.minWidth == 50)
        }
    }

    @Test func maxWidths() {
        #expect(AudioFileTableColumn.number.maxWidth == 60)
        #expect(AudioFileTableColumn.type.maxWidth == 60)
        #expect(AudioFileTableColumn.file.maxWidth == nil)
        #expect(AudioFileTableColumn.duration.maxWidth == nil)
    }

    // MARK: - Identifier

    @Test func identifierMatchesDisplayName() {
        for column in AudioFileTableColumn.allCases {
            #expect(column.identifier.rawValue == column.displayName)
        }
    }

    // MARK: - All Cases Count

    @Test func allCasesCount() {
        #expect(AudioFileTableColumn.allCases.count == 10)
    }
}
