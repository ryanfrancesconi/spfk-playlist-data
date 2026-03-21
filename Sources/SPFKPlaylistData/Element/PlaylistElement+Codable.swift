// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation
import SPFKBase
import SPFKMetadataBase
import SPFKUtils

extension PlaylistElement: Codable, Serializable {
    enum CodingKeys: String, CodingKey {
        case bookmarkData
        case mafDescription
        case hexColor
        case imageDescription
        case sortIndex
        case dirtyFlags
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        mafDescription = try container.decode(MetaAudioFileDescription.self, forKey: .mafDescription)

        bookmarkData = try container.decodeIfPresent(Data.self, forKey: .bookmarkData)
        hexColor = try? container.decodeIfPresent(HexColor.self, forKey: .hexColor)
        sortIndex = try container.decodeIfPresent(Int.self, forKey: .sortIndex)

        // Decode dirtyFlags from raw strings — SwiftData KVC materializes enum
        // Set elements as dictionaries instead of using the enum's Codable, so we
        // must encode/decode as [String] and reconstruct manually.
        if let rawFlags = try? container.decodeIfPresent([String].self, forKey: .dirtyFlags) {
            dirtyFlags = Set(rawFlags.compactMap { MetadataDirtyFlag(rawValue: $0) })
        }

        invalidateSearch()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // required
        try container.encode(mafDescription, forKey: .mafDescription)

        // optionals
        try container.encodeIfPresent(bookmarkData, forKey: .bookmarkData)
        try container.encodeIfPresent(hexColor, forKey: .hexColor)
        try container.encodeIfPresent(sortIndex, forKey: .sortIndex)

        if !dirtyFlags.isEmpty {
            try container.encode(dirtyFlags.map(\.rawValue), forKey: .dirtyFlags)
        }
    }
}
