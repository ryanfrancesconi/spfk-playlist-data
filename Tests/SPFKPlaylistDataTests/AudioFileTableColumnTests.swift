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
        #expect(AudioFileTableColumn.colors.defaultWidth == 80)
        #expect(AudioFileTableColumn.file.defaultWidth == 200)

        // These should be nil (use default)
        #expect(AudioFileTableColumn.duration.defaultWidth == nil)
        #expect(AudioFileTableColumn.format.defaultWidth == nil)
        #expect(AudioFileTableColumn.markers.defaultWidth == nil)
    }

    // MARK: - Min / Max Width

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
        #expect(AudioFileTableColumn.allCases.count == 11)
    }

    // MARK: - Tag Insertion Index

    @Test func tagInsertionIndexEmptyReturnsNil() {
        #expect(AudioFileTableColumn.tagInsertionIndex(in: []) == nil)
    }

    @Test func tagInsertionIndexAllStandardReturnsCount() {
        let titles = AudioFileTableColumn.allCases.map(\.displayName)
        #expect(AudioFileTableColumn.tagInsertionIndex(in: titles) == titles.count)
    }

    @Test func tagInsertionIndexFindsFirstNonStandard() {
        let titles = ["#", "File", "Title", "Artist"]
        #expect(AudioFileTableColumn.tagInsertionIndex(in: titles) == 2)
    }

    @Test func tagInsertionIndexFirstColumnIsNonStandard() {
        let titles = ["Artist", "Title"]
        #expect(AudioFileTableColumn.tagInsertionIndex(in: titles) == 0)
    }

    @Test func tagInsertionIndexMixedOrder() {
        let titles = ["#", "File", "Type", "Format", "Duration", "Title", "Size"]
        #expect(AudioFileTableColumn.tagInsertionIndex(in: titles) == 5)
    }

    // MARK: - Cell Style

    @Test func cellStyleNumberColumn() {
        let style = AudioFileTableColumn.number.cellStyle()
        #expect(style.kind == .number)
        #expect(style.showsImage == false)
        #expect(style.isItalic == false)
    }

    @Test func cellStyleFinderTagsColumn() {
        let style = AudioFileTableColumn.colors.cellStyle()
        #expect(style.kind == .color)
        #expect(style.showsImage == false)
        #expect(style.isItalic == false)
    }

    @Test func cellStyleFileColumn() {
        let style = AudioFileTableColumn.file.cellStyle()
        #expect(style.kind == .standard)
        #expect(style.showsImage == true)
        #expect(style.textColorRole == .primary)
        #expect(style.isItalic == false)
    }

    @Test func cellStyleFileColumnDirty() {
        let style = AudioFileTableColumn.file.cellStyle(isDirty: true)
        #expect(style.showsImage == true)
        #expect(style.textColorRole == .primary)
        #expect(style.isItalic == true)
    }

    @Test func cellStyleStandardColumns() {
        let standardColumns: [AudioFileTableColumn] = [.type, .format, .duration, .fileSize, .creationDate, .modificationDate, .markers]

        for column in standardColumns {
            let style = column.cellStyle()
            #expect(style.kind == .standard)
            #expect(style.showsImage == false)
            #expect(style.textColorRole == .secondary)
            #expect(style.isItalic == false)
        }
    }

    @Test func cellStyleStandardColumnsDirty() {
        let style = AudioFileTableColumn.type.cellStyle(isDirty: true)
        #expect(style.isItalic == true)
        #expect(style.textColorRole == .secondary)
    }

    @Test func cellStyleNumberIgnoresNeedsSave() {
        let style = AudioFileTableColumn.number.cellStyle(isDirty: true)
        #expect(style.isItalic == false)
    }

    @Test func cellStyleFinderTagsIgnoresNeedsSave() {
        let style = AudioFileTableColumn.colors.cellStyle(isDirty: true)
        #expect(style.isItalic == false)
    }

    // MARK: - Cell Style by Column Title

    @Test func cellStyleForKnownColumnTitle() {
        let style = AudioFileTableColumn.cellStyle(forColumnTitled: "File")
        #expect(style.kind == .standard)
        #expect(style.showsImage == true)
        #expect(style.textColorRole == .primary)
    }

    @Test func cellStyleForTagColumnTitle() {
        let style = AudioFileTableColumn.cellStyle(forColumnTitled: "Artist")
        #expect(style.kind == .standard)
        #expect(style.showsImage == false)
        #expect(style.textColorRole == .secondary)
    }

    @Test func cellStyleForTagColumnTitleDirty() {
        let style = AudioFileTableColumn.cellStyle(forColumnTitled: "Artist", isDirty: true)
        #expect(style.isItalic == true)
    }

    @Test func cellStyleForUnknownColumnTitle() {
        let style = AudioFileTableColumn.cellStyle(forColumnTitled: "UnknownColumn")
        #expect(style.kind == .standard)
        #expect(style.showsImage == false)
        #expect(style.textColorRole == .secondary)
        #expect(style.isItalic == false)
    }

    // MARK: - reorderStandardColumns

    // Helper: default column order as display names
    private var defaultOrder: [String] { AudioFileTableColumn.allCases.map(\.displayName) }

    @Test func reorderStandardColumnsNoOpWhenAlreadyInOrder() {
        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: defaultOrder)
        #expect(result == defaultOrder)
    }

    @Test func reorderStandardColumnsEmptySavedOrderLeavesUntouched() {
        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: [])
        #expect(result == defaultOrder)
    }

    @Test func reorderStandardColumnsMoveOneForward() {
        // User moved "Format" (index 4) to index 2, before "Type"
        // Saved: #, ●, File, Format, Type, Duration, Size, Created, Modified, Colors, Markers
        var saved = defaultOrder
        let removed = saved.remove(at: 4) // Format
        saved.insert(removed, at: 3)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsMoveOneBackward() {
        // User moved "File" (index 2) to the end, before Colors/Markers
        var saved = defaultOrder
        let removed = saved.remove(at: 2) // File
        saved.insert(removed, at: saved.count - 2)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsMoveFirstToLast() {
        // User moved "#" to the end
        var saved = defaultOrder
        let removed = saved.remove(at: 0)
        saved.append(removed)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsMoveLastToFirst() {
        // User moved "Markers" to the front
        var saved = defaultOrder
        let removed = saved.remove(at: saved.count - 1)
        saved.insert(removed, at: 0)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsMultipleMoves() {
        // User moved Markers (#10) and Colors (#9) to the front
        var saved = defaultOrder
        let markers = saved.remove(at: saved.count - 1)
        let colors = saved.remove(at: saved.count - 1)
        saved.insert(colors, at: 0)
        saved.insert(markers, at: 0)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsIgnoresTagColumnsInSaved() {
        // Saved layout contains interleaved tag columns — only standard columns are reordered
        let savedWithTags = ["#", "●", "BPM", "File", "Type", "Key", "Format", "Duration", "Size", "Created", "Modified", "Colors", "Markers"]
        let expected = defaultOrder // tag columns are not in current table; standard order unchanged

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: savedWithTags)
        #expect(result == expected)
    }

    @Test func reorderStandardColumnsTagColumnsInCurrentPreservedAfterStandard() {
        // Table has tag columns appended at the end; they should not be displaced
        let withTags = defaultOrder + ["BPM", "Key"]
        var saved = defaultOrder + ["BPM", "Key"]
        // Swap File and Type in saved order
        let fileIdx = saved.firstIndex(of: "File")!
        let typeIdx = saved.firstIndex(of: "Type")!
        saved.swapAt(fileIdx, typeIdx)

        let result = AudioFileTableColumn.reorderStandardColumns(current: withTags, toMatch: saved)

        // Standard columns should be in saved order; tag columns remain at end
        let resultStandard = result.filter { AudioFileTableColumn(displayName: $0) != nil }
        let savedStandard = saved.filter { AudioFileTableColumn(displayName: $0) != nil }
        #expect(resultStandard == savedStandard)
        #expect(result.last == "Key")
        #expect(result[result.count - 2] == "BPM")
    }

    @Test func reorderStandardColumnsRoundTrip() {
        // Whatever order is captured should be fully restorable
        let shuffled = ["Markers", "Colors", "#", "●", "Format", "File", "Type", "Duration", "Size", "Created", "Modified"]
        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: shuffled)
        #expect(result == shuffled)
    }
}
