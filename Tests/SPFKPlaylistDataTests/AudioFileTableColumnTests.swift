// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import AppKit
import Foundation
import SPFKBase
import SPFKTesting
import SPFKUtils
import Testing

@testable import SPFKPlaylistData

final class AudioFileTableColumnTests: TestCaseModel {
    private var defaultOrder: [String] { AudioFileTableColumn.allCases.map(\.displayName) }

    // MARK: - Init

    @Test func initFromValidDisplayName() {
        #expect(AudioFileTableColumn(displayName: AudioFileTableColumn.file.rawValue) == .file)
    }

    @Test func initFromInvalidDisplayName() {
        #expect(AudioFileTableColumn(displayName: "Nonexistent") == nil)
    }

    @Test func initRoundTripsAllCases() {
        for column in AudioFileTableColumn.allCases {
            #expect(AudioFileTableColumn(displayName: column.displayName) == column)
        }
    }

    // MARK: - Tag Insertion Index

    @Test func tagInsertionIndexEmptyReturnsNil() {
        #expect(AudioFileTableColumn.tagInsertionIndex(in: []) == nil)
    }

    @Test func tagInsertionAfterRequiredCount() {
        let titles = AudioFileTableColumn.allCases.map(\.displayName)
        #expect(AudioFileTableColumn.tagInsertionIndex(in: titles) == AudioFileTableColumn.allCases.filter(\.isRequired).count)
    }

    @Test func tagInsertionIndexFindsFirstNonStandard() {
        let titles = [AudioFileTableColumn.number.rawValue, AudioFileTableColumn.file.rawValue, "Title", "Artist"]
        #expect(AudioFileTableColumn.tagInsertionIndex(in: titles) == 2)
    }

    @Test func tagInsertionIndexFirstColumnIsNonStandard() {
        let titles = ["Artist", "Title"]
        #expect(AudioFileTableColumn.tagInsertionIndex(in: titles) == 0)
    }

    @Test func tagInsertionIndexMixedOrder() {
        let titles = [
            AudioFileTableColumn.number.rawValue, AudioFileTableColumn.file.rawValue, // after File
            AudioFileTableColumn.fileType.rawValue, AudioFileTableColumn.format.rawValue, AudioFileTableColumn.duration.rawValue, "Title", AudioFileTableColumn.fileSize.rawValue
        ]
        #expect(AudioFileTableColumn.tagInsertionIndex(in: titles) == 2)
    }

    // MARK: - Cell Style

    @Test func cellStyleNumberColumn() {
        let style = AudioFileTableColumn.number.cellStyle()
        #expect(style.kind == .number)
        #expect(style.showsImage == false)
        #expect(style.isItalic == false)
    }

    @Test func cellStyleColorsColumn() {
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

    @Test func cellStyleNumberIgnoresDirty() {
        #expect(AudioFileTableColumn.number.cellStyle(isDirty: true).isItalic == false)
    }

    @Test func cellStyleColorsIgnoresDirty() {
        #expect(AudioFileTableColumn.colors.cellStyle(isDirty: true).isItalic == false)
    }

    @Test func cellStyleForKnownColumnTitle() {
        let style = AudioFileTableColumn.cellStyle(forColumnTitled: AudioFileTableColumn.file.rawValue)
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
        #expect(AudioFileTableColumn.cellStyle(forColumnTitled: "Artist", isDirty: true).isItalic == true)
    }

    @Test func cellStyleForUnknownColumnTitle() {
        let style = AudioFileTableColumn.cellStyle(forColumnTitled: "UnknownColumn")
        #expect(style.kind == .standard)
        #expect(style.showsImage == false)
        #expect(style.textColorRole == .secondary)
        #expect(style.isItalic == false)
    }

    // MARK: - reorderStandardColumns

    @Test func reorderStandardColumnsNoOpWhenAlreadyInOrder() {
        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: defaultOrder)
        #expect(result == defaultOrder)
    }

    @Test func reorderStandardColumnsEmptySavedOrderLeavesUntouched() {
        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: [])
        #expect(result == defaultOrder)
    }

    @Test func reorderStandardColumnsMoveOneForward() {
        // Move "Format" (index 4) to before "Type" (index 3)
        var saved = defaultOrder
        let removed = saved.remove(at: 4)
        saved.insert(removed, at: 3)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsMoveOneBackward() {
        // Move "File" to just before Colors and Markers
        var saved = defaultOrder
        let removed = saved.remove(at: 2)
        saved.insert(removed, at: saved.count - 2)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsMoveFirstToLast() {
        var saved = defaultOrder
        saved.append(saved.remove(at: 0))

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsMoveLastToFirst() {
        var saved = defaultOrder
        saved.insert(saved.removeLast(), at: 0)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsMultipleMoves() {
        // Move last two columns to the front
        var saved = defaultOrder
        let last = saved.removeLast()
        let secondLast = saved.removeLast()
        saved.insert(last, at: 0)
        saved.insert(secondLast, at: 1)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: saved)
        #expect(result == saved)
    }

    @Test func reorderStandardColumnsIgnoresTagColumnsInSaved() {
        // Standard columns in original order with tag columns interleaved — result unchanged
        var savedWithTags = defaultOrder
        savedWithTags.insert("BPM", at: 2)
        savedWithTags.insert("Key", at: 5)

        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: savedWithTags)
        #expect(result == defaultOrder)
    }

    @Test func reorderStandardColumnsTagColumnsInCurrentPreservedAfterStandard() {
        // Tag columns appended to the live table should remain at the end after reorder
        let withTags = defaultOrder + ["BPM", "Key"]
        var saved = withTags

        let fileTitle = AudioFileTableColumn.file.displayName
        let typeTitle = AudioFileTableColumn.fileType.displayName
        saved.swapAt(saved.firstIndex(of: fileTitle)!, saved.firstIndex(of: typeTitle)!)

        let result = AudioFileTableColumn.reorderStandardColumns(current: withTags, toMatch: saved)

        let resultStandard = result.filter { AudioFileTableColumn(displayName: $0) != nil }
        let savedStandard = saved.filter { AudioFileTableColumn(displayName: $0) != nil }
        #expect(resultStandard == savedStandard)
        #expect(result.last == "Key")
        #expect(result[result.count - 2] == "BPM")
    }

    @Test func reorderStandardColumnsRoundTrip() {
        // Reversed order is a fully-specified permutation that must restore exactly
        let shuffled = Array(defaultOrder.reversed())
        let result = AudioFileTableColumn.reorderStandardColumns(current: defaultOrder, toMatch: shuffled)
        #expect(result == shuffled)
    }
}
