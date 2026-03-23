import Foundation

public enum CollectionType: String, Sendable, Hashable, Equatable, Codable {
    case system
    case user

    public var title: String {
        switch self {
        case .system:
            "System"
        case .user:
            "User"
        }
    }
}
