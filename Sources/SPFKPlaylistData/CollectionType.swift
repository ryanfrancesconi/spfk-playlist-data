import Foundation
import RawCodable

@RawCodable
public enum CollectionType: String, Sendable, Hashable, Equatable {
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
