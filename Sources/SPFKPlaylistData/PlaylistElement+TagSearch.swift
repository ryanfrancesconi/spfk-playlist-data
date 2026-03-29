// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import Foundation
import SPFKBase
import SPFKMetadataBase
import SPFKSearch

extension PlaylistElement {
    /// Returns a similarity score for the given ``TagQuery``, or `nil` if the element does not match.
    ///
    /// Structured tag clauses act as hard filters — all must pass for any score to be returned.
    /// When the query also contains fuzzy terms, scoring is delegated to the standard fuzzy matcher.
    /// A query with only structured clauses that all match returns `1.0`.
    ///
    /// - Parameter query: A parsed query potentially containing both structured tag clauses
    ///   and a general fuzzy search component.
    /// - Returns: A similarity score in `0...1`, or `nil` if any clause does not match.
    /// - Parameter substringPrecheck: When `true` (default), calls ``Searchable/hasNearMatch(terms:)``
    ///   before the full fuzzy scorer. Prunes ~80–90% of elements in typical searches (measured),
    ///   at a modest false-negative rate for very unusual fuzzy matches. Pass `false` to run the
    ///   full fuzzy scorer on every element.
    public func similarity(to query: TagQuery, substringPrecheck: Bool = true) -> UnitInterval? {
        guard query.hasStructuredClauses || query.fuzzyQuery.array.isNotEmpty else { return nil }

        // All structured clauses must match (case-insensitive substring)
        for (key, value) in query.tagClauses {
            guard let tagValue = mafDescription.tagProperties.tags[key],
                  tagValue.lowercased().contains(value.lowercased()) else { return nil }
        }

        // Delegate remaining terms to fuzzy matching
        if query.fuzzyQuery.array.isNotEmpty {
            if substringPrecheck {
                guard hasNearMatch(terms: query.fuzzyQuery.array) else { return nil }
            }

            return similarity(to: query.fuzzyQuery)
        }

        // Only structured clauses — all matched
        return 1.0
    }
}
