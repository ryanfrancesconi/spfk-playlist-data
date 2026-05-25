// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation

/// Defines a smart playlist's identity and matching rule.
///
/// Smart playlists have stable deterministic UUIDs and filter the global element cache using
/// a ``SmartPredicate``. The built-in system kinds live as static constants; future user-defined
/// smart playlists can be created as values of this type and persisted without changing the API.
///
/// UUIDs use the byte pattern `(0,0,...,0,1,rawByte)` to guarantee no collision with
/// ``CollectionPreset`` UUIDs which use the pattern `(0,0,...,0,0,rawByte)`.
public struct SmartPlaylistDefinition: Sendable, Codable, Hashable {
    public let uuid: UUID
    public let title: String
    public let predicate: SmartPredicate

    /// Column identifiers that must be visible when this smart playlist loads.
    /// Uses `AudioFileTableColumn.rawValue` for standard columns and `TagKey.displayName`
    /// for metadata columns. Nil means no required columns beyond the table defaults.
    public let requiredColumns: [String]?

    public init(uuid: UUID, title: String, predicate: SmartPredicate, requiredColumns: [String]? = nil) {
        self.uuid = uuid
        self.title = title
        self.predicate = predicate
        self.requiredColumns = requiredColumns
    }
}

// MARK: - Built-in definitions

extension SmartPlaylistDefinition {
    /// Files with pending metadata or audio edits (`isDirty == true`).
    public static let edited = SmartPlaylistDefinition(
        uuid: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0)),
        title: "Edited",
        predicate: .isDirty
    )

    /// Files with a star rating of 1 or higher.
    public static let rated = SmartPlaylistDefinition(
        uuid: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1)),
        title: "Rated",
        predicate: .ratingAtLeast(1),
        requiredColumns: ["Rating"]
    )

    /// Files with a custom hex color or a Finder label color.
    public static let colored = SmartPlaylistDefinition(
        uuid: UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2)),
        title: "Colored",
        predicate: .hasColor,
        requiredColumns: ["Colors"]
    )

    /// All built-in system smart playlists in display order.
    public static let builtins: [SmartPlaylistDefinition] = [edited, rated, colored]

    private static let lookup: [UUID: SmartPlaylistDefinition] =
        Dictionary(uniqueKeysWithValues: builtins.map { ($0.uuid, $0) })

    /// Returns the built-in definition for the given UUID, or `nil` if not a smart playlist.
    public static func definition(for uuid: UUID) -> SmartPlaylistDefinition? {
        lookup[uuid]
    }
}

// MARK: - Playlist convenience

extension Playlist {
    /// Whether this playlist is a system smart playlist whose elements are computed on fetch.
    public var isSmart: Bool {
        SmartPlaylistDefinition.definition(for: uuid) != nil
    }
}
