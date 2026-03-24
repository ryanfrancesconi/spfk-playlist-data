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
    public func similarity(to query: TagQuery) -> UnitInterval? {
        guard query.hasStructuredClauses || query.fuzzyQuery.array.isNotEmpty else { return nil }

        // All structured clauses must match (case-insensitive substring)
        for (key, value) in query.tagClauses {
            guard let tagValue = mafDescription.tagProperties.tags[key],
                  tagValue.lowercased().contains(value.lowercased()) else { return nil }
        }

        // Delegate remaining terms to fuzzy matching
        if query.fuzzyQuery.array.isNotEmpty {
            return similarity(to: query.fuzzyQuery)
        }

        // Only structured clauses — all matched
        return 1.0
    }
}
