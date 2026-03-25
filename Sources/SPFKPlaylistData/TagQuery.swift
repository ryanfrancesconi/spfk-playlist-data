// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import Foundation
import SPFKMetadataBase
import SPFKSearch

/// A parsed search query that combines structured tag-field matching with general fuzzy search.
///
/// Recognizes two syntaxes for targeting specific ``TagKey`` fields:
///
/// **Colon syntax** (explicit field targeting, works for any key):
/// ```
/// bpm:120       → search tags[.bpm] for "120"
/// artist:arca   → search tags[.artist] for "arca"
/// key:Cm        → search tags[.initialKey] for "Cm"
/// ```
///
/// **Unit inference** (implicit matching for numeric fields with natural unit suffixes):
/// ```
/// 120 bpm       → search tags[.bpm] for "120"
/// -14 lufs      → search tags[.loudnessIntegrated] for "-14"
/// ```
///
/// Terms that don't resolve to a tag field are collected into ``fuzzyQuery``
/// for standard fuzzy matching via ``Searchable/similarity(to:matchConfig:)``.
///
/// Colon tokens and unit-inferred key/value pairs are consumed; all remaining tokens
/// fall through to ``fuzzyQuery``.
///
/// ```swift
/// let q = TagQuery(string: "kick 120 bpm")
/// q.tagClauses   // [(.bpm, "120")]
/// q.fuzzyQuery   // DelimitedQuery("kick")
/// ```
public struct TagQuery: Sendable {
    /// Structured tag-field clauses extracted from the query.
    public let tagClauses: [(key: TagKey, value: String)]

    /// Remaining query terms that did not resolve to a tag field, for fuzzy matching.
    public let fuzzyQuery: DelimitedQuery

    /// `true` when the query contains at least one structured tag clause.
    public var hasStructuredClauses: Bool { !tagClauses.isEmpty }

    /// Creates a `TagQuery` by parsing the given string for tag-field patterns.
    public init(string: String) {
        guard string.isNotEmpty else {
            tagClauses = []
            fuzzyQuery = DelimitedQuery(string: "")
            return
        }

        var clauses: [(TagKey, String)] = []
        let tokens = string.components(separatedBy: " ").filter(\.isNotEmpty)
        var consumed = Set<Int>()

        // Pass 1: colon syntax — "bpm:120", "artist:arca", "key:Cm"
        for (i, token) in tokens.enumerated() {
            guard token.contains(":") else { continue }
            let parts = token.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { continue }

            let keyStr = String(parts[0])
            let valueStr = String(parts[1])

            guard valueStr.isNotEmpty else { continue }

            if let key = TagKey(string: keyStr) ?? Self.aliases[keyStr.lowercased()] {
                clauses.append((key, valueStr))
                consumed.insert(i)
            }
        }

        // Pass 2: unit inference for numeric keys — "120 bpm", "-14 lufs"
        // Only applies to the predefined set of numeric unit keys (see numericUnitKeys).
        // The adjacent value token must parse as Double to avoid false positives
        // (e.g. "piano bpm" does not produce a clause).
        for (i, token) in tokens.enumerated() {
            guard !consumed.contains(i) else { continue }
            guard let key = Self.numericUnitKeys[token.lowercased()] else { continue }

            // Prefer the left-neighbor ("120 bpm"); fall back to right-neighbor ("bpm 120").
            let adjacentIndex: Int? = if i > 0, !consumed.contains(i - 1), Double(tokens[i - 1]) != nil {
                i - 1
            } else if i + 1 < tokens.count, !consumed.contains(i + 1), Double(tokens[i + 1]) != nil {
                i + 1
            } else {
                nil
            }

            if let vi = adjacentIndex {
                clauses.append((key, tokens[vi]))
                consumed.insert(i)
                consumed.insert(vi)
            }
        }

        // Remaining tokens go to the fuzzy query
        let fuzzyTokens = tokens.enumerated()
            .filter { !consumed.contains($0.offset) }
            .map(\.element)

        tagClauses = clauses
        fuzzyQuery = DelimitedQuery(string: fuzzyTokens.joined(separator: " "))
    }
}

// MARK: - Key resolution

// swiftformat:disable consecutiveSpaces

extension TagQuery {
    /// Aliases mapping common abbreviations and display-name fragments to ``TagKey`` cases.
    /// Used for colon-syntax resolution only; does not affect unit inference.
    static let aliases: [String: TagKey] = [
        "tempo":    .bpm,
        "beats":    .bpm,
        "key":      .initialKey,
        "lufs":     .loudnessIntegrated,
        "loudness": .loudnessIntegrated,
        "lra":      .loudnessRange,
        "dbtp":     .loudnessTruePeak,
        "tp":       .loudnessTruePeak,
    ]

    /// Numeric-field keys eligible for unit-inference matching.
    /// An adjacent token must parse as `Double` for a clause to be produced.
    static let numericUnitKeys: [String: TagKey] = [
        "bpm":   .bpm,
        "tempo": .bpm,
        "lufs":  .loudnessIntegrated,
        "lra":   .loudnessRange,
        "dbtp":  .loudnessTruePeak,
    ]
}

// swiftformat:enable consecutiveSpaces
