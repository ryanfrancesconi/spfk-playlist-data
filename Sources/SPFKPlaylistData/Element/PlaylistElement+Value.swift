// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-data

import Foundation
import SPFKMetadataBase

extension PlaylistElement {
    public func stringValue(columnTitled displayName: String) -> String? {
        if let column = AudioFileTableColumn(displayName: displayName) {
            return stringValue(column: column)

        } else if let tagKey = TagKey(displayName: displayName) {
            return mafDescription.tagProperties[tagKey]
        }

        return nil
    }

    public func stringValue(column: AudioFileTableColumn) -> String? {
        switch column {
        case .number:
            return nil

        case .file:
            return filename

        case .creationDate:
            return mafDescription.urlProperties.creationDate?.mediumString

        case .modificationDate:
            return mafDescription.urlProperties.modificationDate?.mediumString

        case .fileSize:
            return mafDescription.urlProperties.fileSizeString

        case .type:
            return mafDescription.fileType?.pathExtension

        case .duration:
            return mafDescription.audioFormat?.durationDescription

        case .format:
            guard let audioFormat = mafDescription.audioFormat else { return nil }

            var value = audioFormat.formatDescription

            if let fileType = mafDescription.fileType {
                value += " \(fileType.stringValue)"
            }

            return value

        case .finderTags:
            return mafDescription.urlProperties.finderTags.stringValue

        case .markers:
            let count = mafDescription.markerCollection.markerDescriptions.count
            guard count > 0 else { return nil }

            return "\(count) Marker\(mafDescription.markerCollection.markerDescriptions.pluralString)"
        }
    }

    public func sortValue(columnTitled displayName: String) -> String? {
        guard let column = AudioFileTableColumn(displayName: displayName) else {
            if let tagKey = TagKey(displayName: displayName) {
                return mafDescription.tagProperties[tagKey]
            }

            return nil
        }

        // numerical items
        switch column {
        case .creationDate:
            return mafDescription.urlProperties.creationDate?.timeIntervalSince1970.string

        case .modificationDate:
            return mafDescription.urlProperties.modificationDate?.timeIntervalSince1970.string

        case .fileSize:
            return mafDescription.urlProperties.fileSize?.string

        case .duration:
            return mafDescription.audioFormat?.duration.string

        case .markers:
            return mafDescription.markerCollection.markerDescriptions.count.string

        default:
            return stringValue(column: column)
        }
    }
}
