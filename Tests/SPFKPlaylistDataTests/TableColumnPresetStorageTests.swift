// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKTesting
import Testing

@testable import SPFKPlaylistData

final class TableColumnPresetStorageTests: TestCaseModel {
    private func makeTempDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("TableColumnPresetStorageTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func cleanup(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    private var sampleLayout: [TableColumnState] {
        [
            TableColumnState(title: "File", width: 200),
            TableColumnState(title: "Duration", width: 80),
            TableColumnState(title: "Sample Rate", width: 100),
        ]
    }

    // MARK: - Save / Load

    @Test func saveAndLoadRoundTrip() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let preset = TableColumnPreset(data: sampleLayout)
        try TableColumnPresetStorage.save(name: "My Layout", preset: preset, baseDirectory: dir)
        let loaded = try TableColumnPresetStorage.load(name: "My Layout", baseDirectory: dir)
        #expect(loaded == preset)
    }

    @Test func loadedDataMatchesAllFields() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let layout = [TableColumnState(title: "Path", width: 150, isHidden: true)]
        try TableColumnPresetStorage.save(name: "Hidden", preset: TableColumnPreset(data: layout), baseDirectory: dir)
        let loaded = try TableColumnPresetStorage.load(name: "Hidden", baseDirectory: dir)

        #expect(loaded.data.count == 1)
        #expect(loaded.data[0].title == "Path")
        #expect(loaded.data[0].width == 150)
        #expect(loaded.data[0].isHidden == true)
    }

    @Test func overwriteExistingPreset() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let v1 = TableColumnPreset(data: [TableColumnState(title: "File", width: 100)])
        let v2 = TableColumnPreset(data: [TableColumnState(title: "File", width: 999)])
        try TableColumnPresetStorage.save(name: "Layout", preset: v1, baseDirectory: dir)
        try TableColumnPresetStorage.save(name: "Layout", preset: v2, baseDirectory: dir)

        let loaded = try TableColumnPresetStorage.load(name: "Layout", baseDirectory: dir)
        #expect(loaded == v2)
        #expect(TableColumnPresetStorage.list(baseDirectory: dir).count == 1)
    }

    // MARK: - List

    @Test func listReturnsSortedNames() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let preset = TableColumnPreset(data: sampleLayout)
        for name in ["Zebra", "Alpha", "Middle"] {
            try TableColumnPresetStorage.save(name: name, preset: preset, baseDirectory: dir)
        }

        #expect(TableColumnPresetStorage.list(baseDirectory: dir) == ["Alpha", "Middle", "Zebra"])
    }

    @Test func listReturnsEmptyForMissingDirectory() {
        let missing = FileManager.default.temporaryDirectory
            .appendingPathComponent("nonexistent-\(UUID().uuidString)")
        #expect(TableColumnPresetStorage.list(baseDirectory: missing).isEmpty)
    }

    @Test func listExcludesNonPresetFiles() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let presetsDir = try TableColumnPresetStorage.presetsDirectory(baseDirectory: dir)
        let noise = presetsDir.appendingPathComponent("noise.json")
        try Data("{}".utf8).write(to: noise)

        let preset = TableColumnPreset(data: sampleLayout)
        try TableColumnPresetStorage.save(name: "Real", preset: preset, baseDirectory: dir)

        #expect(TableColumnPresetStorage.list(baseDirectory: dir) == ["Real"])
    }

    // MARK: - Delete

    @Test func deleteRemovesFromList() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let preset = TableColumnPreset(data: sampleLayout)
        try TableColumnPresetStorage.save(name: "ToDelete", preset: preset, baseDirectory: dir)
        #expect(TableColumnPresetStorage.list(baseDirectory: dir) == ["ToDelete"])

        try TableColumnPresetStorage.delete(name: "ToDelete", baseDirectory: dir)
        #expect(TableColumnPresetStorage.list(baseDirectory: dir).isEmpty)
    }

    // MARK: - Sanitization

    @Test func sanitizesSlashesInName() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let preset = TableColumnPreset(data: sampleLayout)
        try TableColumnPresetStorage.save(name: "My/Preset", preset: preset, baseDirectory: dir)
        let loaded = try TableColumnPresetStorage.load(name: "My/Preset", baseDirectory: dir)
        #expect(loaded == preset)
        #expect(TableColumnPresetStorage.list(baseDirectory: dir) == ["My_Preset"])
    }

    @Test func sanitizesColonsInName() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let preset = TableColumnPreset(data: sampleLayout)
        try TableColumnPresetStorage.save(name: "A:B", preset: preset, baseDirectory: dir)
        let loaded = try TableColumnPresetStorage.load(name: "A:B", baseDirectory: dir)
        #expect(loaded == preset)
        #expect(TableColumnPresetStorage.list(baseDirectory: dir) == ["A_B"])
    }

    // MARK: - presetsDirectory

    @Test func presetsDirectoryCreatesSubdirectory() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let presetsDir = try TableColumnPresetStorage.presetsDirectory(baseDirectory: dir)
        #expect(presetsDir.lastPathComponent == TableColumnPresetStorage.directoryName)

        var isDir: ObjCBool = false
        #expect(FileManager.default.fileExists(atPath: presetsDir.path, isDirectory: &isDir))
        #expect(isDir.boolValue)
    }

    @Test func presetsDirectoryIsIdempotent() throws {
        let dir = try makeTempDirectory()
        defer { cleanup(dir) }

        let first = try TableColumnPresetStorage.presetsDirectory(baseDirectory: dir)
        let second = try TableColumnPresetStorage.presetsDirectory(baseDirectory: dir)
        #expect(first == second)
    }
}
