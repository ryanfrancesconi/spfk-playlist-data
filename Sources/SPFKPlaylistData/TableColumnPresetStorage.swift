// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-playlist-data

import Foundation
import SPFKBase

/// File-based storage for `TableColumnPreset` values.
///
/// Presets are stored as JSON files under `{baseDirectory}/TablePresets/`:
/// ```
/// {baseDirectory}/TablePresets/{presetName}.tablepreset
/// ```
public enum TableColumnPresetStorage {
    public static let directoryName = "TablePresets"
    public static let pathExtension = "tablepreset"

    public static func save(name: String, preset: TableColumnPreset, baseDirectory: URL) throws {
        let directory = try presetsDirectory(baseDirectory: baseDirectory)
        let fileURL = directory.appendingPathComponent(sanatize(filename: name))
        let data = try JSONEncoder().encode(preset)
        try data.write(to: fileURL, options: .atomic)
    }

    public static func load(name: String, baseDirectory: URL) throws -> TableColumnPreset {
        let fileURL = baseDirectory
            .appendingPathComponent(Self.directoryName)
            .appendingPathComponent(sanatize(filename: name))
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(TableColumnPreset.self, from: data)
    }

    public static func delete(name: String, baseDirectory: URL) throws {
        let fileURL = baseDirectory
            .appendingPathComponent(Self.directoryName)
            .appendingPathComponent(sanatize(filename: name))

        Log.debug(fileURL.path)

        try FileManager.default.removeItem(at: fileURL)
    }

    /// Returns preset names sorted alphabetically, without the `.tablepreset` extension.
    public static func list(baseDirectory: URL) -> [String] {
        let directory = baseDirectory.appendingPathComponent(Self.directoryName)
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else { return [] }
        return contents
            .filter { $0.pathExtension == Self.pathExtension }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    /// Returns the presets directory, creating it if necessary.
    public static func presetsDirectory(baseDirectory: URL) throws -> URL {
        let directory = baseDirectory.appendingPathComponent(Self.directoryName)

        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private static func sanatize(filename: String) -> String {
        filename
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            + ".\(pathExtension)"
    }
}
