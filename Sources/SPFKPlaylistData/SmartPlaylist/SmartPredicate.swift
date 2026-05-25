// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation
import SPFKMetadataBase

/// A serializable, composable predicate for filtering playlist elements.
///
/// Used to define the matching rule for a ``SmartPlaylistDefinition``. The built-in v1 cases
/// cover the three initial system smart playlists. Future user-defined smart playlists can
/// use `.tagPresent`, `.tagEquals`, and the combinators `.and`/`.or` without changing this type.
public indirect enum SmartPredicate: Sendable, Hashable {
    /// Matches elements where ``PlaylistElement/isDirty`` is `true` (pending metadata or audio edit).
    case isDirty
    /// Matches elements whose rating tag parses to an integer `>= min`.
    case ratingAtLeast(Int)
    /// Matches elements that have a non-nil resolved display color (custom hex or Finder label).
    case hasColor
    /// Matches elements that have any non-empty value for the given tag key.
    case tagPresent(TagKey)
    /// Matches elements whose value for the given tag key equals `value` (case-sensitive).
    case tagEquals(TagKey, String)
    /// Matches elements where all sub-predicates match.
    case and([SmartPredicate])
    /// Matches elements where at least one sub-predicate matches.
    case or([SmartPredicate])

    public func matches(_ element: PlaylistElement) -> Bool {
        switch self {
        case .isDirty:
            return element.isDirty

        case .ratingAtLeast(let min):
            guard let str = element.mafDescription.tagProperties.tags[.rating],
                  let rating = Int(str) else { return false }
            return rating >= min

        case .hasColor:
            return element.resolvedDisplayColor != nil

        case .tagPresent(let key):
            return !(element.mafDescription.tagProperties.tags[key] ?? "").isEmpty

        case .tagEquals(let key, let value):
            return element.mafDescription.tagProperties.tags[key] == value

        case .and(let predicates):
            return predicates.allSatisfy { $0.matches(element) }

        case .or(let predicates):
            return predicates.contains { $0.matches(element) }
        }
    }
}

// MARK: - Codable

extension SmartPredicate: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, value, key, values
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "isDirty":
            self = .isDirty
        case "ratingAtLeast":
            self = .ratingAtLeast(try container.decode(Int.self, forKey: .value))
        case "hasColor":
            self = .hasColor
        case "tagPresent":
            self = .tagPresent(try container.decode(TagKey.self, forKey: .key))
        case "tagEquals":
            self = .tagEquals(
                try container.decode(TagKey.self, forKey: .key),
                try container.decode(String.self, forKey: .value)
            )
        case "and":
            self = .and(try container.decode([SmartPredicate].self, forKey: .values))
        case "or":
            self = .or(try container.decode([SmartPredicate].self, forKey: .values))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown SmartPredicate type: \(type)"
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .isDirty:
            try container.encode("isDirty", forKey: .type)
        case .ratingAtLeast(let min):
            try container.encode("ratingAtLeast", forKey: .type)
            try container.encode(min, forKey: .value)
        case .hasColor:
            try container.encode("hasColor", forKey: .type)
        case .tagPresent(let key):
            try container.encode("tagPresent", forKey: .type)
            try container.encode(key, forKey: .key)
        case .tagEquals(let key, let value):
            try container.encode("tagEquals", forKey: .type)
            try container.encode(key, forKey: .key)
            try container.encode(value, forKey: .value)
        case .and(let predicates):
            try container.encode("and", forKey: .type)
            try container.encode(predicates, forKey: .values)
        case .or(let predicates):
            try container.encode("or", forKey: .type)
            try container.encode(predicates, forKey: .values)
        }
    }
}
