import AudioToolbox
import CoreImage
import Foundation
import SPFKBase

/// (result: progress)
public typealias PlaylistElementParseResultEventHandler = @Sendable (PlaylistElementParseResult, UnitInterval) async throws -> Void

public struct PlaylistElementParseResult: Sendable {
    public let url: URL
    public let element: PlaylistElementDTO?
    public let error: Error?

    public var thumbnailImage: CGImage? {
        element?.mafDescription.imageDescription.thumbnailImage
    }

    public init(url: URL, element: PlaylistElementDTO?, error: Error?) {
        self.url = url
        self.element = element
        self.error = error
    }
}

extension [PlaylistElementParseResult] {
    public var elements: [PlaylistElementDTO] {
        compactMap(\.element)
    }

    public var unsupportedFiles: [URL] {
        compactMap {
            guard let error = $0.error,
                  $0.element == nil else { return nil }

            let url = $0.url

            let code = (error as NSError).code

            // Handle specific errors
            switch code {
            case Int(kAudioFileStreamError_UnsupportedFileType):
                // Log.error("kAudioFileStreamError_UnsupportedFileType \(url.lastPathComponent)) -> \(error)")
                return url

            default:
                break
            }

            return nil
        }
    }
}
