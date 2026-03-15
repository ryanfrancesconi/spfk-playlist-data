// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation
import SPFKBase
import SPFKMetadataBase
import SPFKUtils

extension PlaylistElementDTO: Codable, Serializable {
    enum CodingKeys: String, CodingKey {
        case bookmarkData
        case mafDescription
        case hexColor
        case imageDescription
        case sortIndex
        case needsSave
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        mafDescription = try container.decode(MetaAudioFileDescription.self, forKey: .mafDescription)

        bookmarkData = try container.decodeIfPresent(Data.self, forKey: .bookmarkData)
        hexColor = try? container.decodeIfPresent(HexColor.self, forKey: .hexColor)
        sortIndex = try container.decodeIfPresent(Int.self, forKey: .sortIndex)

        needsSave = try (container.decodeIfPresent(Bool.self, forKey: .needsSave)) == true

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
        try container.encodeIfPresent(needsSave, forKey: .needsSave)
    }
}
