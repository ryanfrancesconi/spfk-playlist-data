import Foundation

public struct PlaylistElementUpdate: Sendable {
    public let index: Int
    public var element: PlaylistElementDTO
    public var error: Error?

    public init(index: Int, element: PlaylistElementDTO, error: Error? = nil) {
        self.index = index
        self.element = element
        self.error = error
    }
}
