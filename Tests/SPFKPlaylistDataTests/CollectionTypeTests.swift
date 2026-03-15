// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKPlaylistData

final class CollectionTypeTests {
    @Test func titles() {
        #expect(CollectionType.system.title == "System")
        #expect(CollectionType.user.title == "User")
    }

    @Test func rawValues() {
        #expect(CollectionType.system.rawValue == "system")
        #expect(CollectionType.user.rawValue == "user")
    }

    @Test func codableRoundTrip() throws {
        for type in [CollectionType.system, CollectionType.user] {
            let data = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(CollectionType.self, from: data)
            #expect(decoded == type)
        }
    }
}
