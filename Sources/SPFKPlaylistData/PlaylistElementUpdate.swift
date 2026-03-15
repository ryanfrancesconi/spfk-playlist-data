import Foundation

public struct PlaylistElementUpdate: Sendable {
    public let index: Int
    public var element: PlaylistElement
    public var error: Error?

    public init(index: Int, element: PlaylistElement, error: Error? = nil) {
        self.index = index
        self.element = element
        self.error = error
    }
}
