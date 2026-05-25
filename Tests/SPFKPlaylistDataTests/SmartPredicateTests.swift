// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKAudioBase
import SPFKBase
import SPFKMetadataBase
import SPFKTesting
import SPFKUtils
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class SmartPredicateTests: TestCaseModel {
    // MARK: - Helpers

    private func makeElement(url: URL) throws -> PlaylistElement {
        try PlaylistElement(mafDescription: MetaAudioFileDescription(url: url))
    }

    // MARK: - isDirty

    @Test func isDirtyMatchesDirtyElement() throws {
        var element = try makeElement(url: TestBundleResources.shared.tabla_wav)
        element.dirtyFlags = [.metadata]

        #expect(SmartPredicate.isDirty.matches(element))
    }

    @Test func isDirtyDoesNotMatchCleanElement() throws {
        let element = try makeElement(url: TestBundleResources.shared.tabla_wav)

        #expect(!SmartPredicate.isDirty.matches(element))
    }

    @Test func isDirtyMatchesAudioEditPending() throws {
        var element = try makeElement(url: TestBundleResources.shared.tabla_wav)
        element.audioEditDescription = AudioEditDescription()

        #expect(SmartPredicate.isDirty.matches(element))
    }

    // MARK: - ratingAtLeast

    @Test func ratingAtLeastMatchesAboveThreshold() throws {
        var desc = MetaAudioFileDescription(url: TestBundleResources.shared.tabla_wav)
        desc.tagProperties.set(tag: .rating, value: "3")
        var element = try PlaylistElement(mafDescription: desc)

        #expect(SmartPredicate.ratingAtLeast(1).matches(element))
        #expect(SmartPredicate.ratingAtLeast(3).matches(element))
    }

    @Test func ratingAtLeastDoesNotMatchBelowThreshold() throws {
        var desc = MetaAudioFileDescription(url: TestBundleResources.shared.tabla_wav)
        desc.tagProperties.set(tag: .rating, value: "0")
        let element = try PlaylistElement(mafDescription: desc)

        #expect(!SmartPredicate.ratingAtLeast(1).matches(element))
    }

    @Test func ratingAtLeastDoesNotMatchMissingRating() throws {
        let element = try makeElement(url: TestBundleResources.shared.tabla_wav)

        #expect(!SmartPredicate.ratingAtLeast(1).matches(element))
    }

    @Test func ratingAtLeastDoesNotMatchMalformedRating() throws {
        var desc = MetaAudioFileDescription(url: TestBundleResources.shared.tabla_wav)
        desc.tagProperties.set(tag: .rating, value: "five")
        let element = try PlaylistElement(mafDescription: desc)

        #expect(!SmartPredicate.ratingAtLeast(1).matches(element))
    }

    @Test func ratingAtLeastBoundary() throws {
        var desc = MetaAudioFileDescription(url: TestBundleResources.shared.tabla_wav)
        desc.tagProperties.set(tag: .rating, value: "1")
        let element = try PlaylistElement(mafDescription: desc)

        #expect(SmartPredicate.ratingAtLeast(1).matches(element))
        #expect(!SmartPredicate.ratingAtLeast(2).matches(element))
    }

    // MARK: - hasColor

    @Test func hasColorMatchesElementWithHexColor() throws {
        var element = try makeElement(url: TestBundleResources.shared.tabla_wav)
        element.hexColor = HexColor(red: 1, green: 0, blue: 0)

        #expect(SmartPredicate.hasColor.matches(element))
    }

    @Test func hasColorDoesNotMatchElementWithoutColor() throws {
        let element = try makeElement(url: TestBundleResources.shared.tabla_wav)

        #expect(!SmartPredicate.hasColor.matches(element))
    }

    // MARK: - tagPresent

    @Test func tagPresentMatchesElementWithTag() throws {
        var desc = MetaAudioFileDescription(url: TestBundleResources.shared.tabla_wav)
        desc.tagProperties.set(tag: .comment, value: "test comment")
        let element = try PlaylistElement(mafDescription: desc)

        #expect(SmartPredicate.tagPresent(.comment).matches(element))
    }

    @Test func tagPresentDoesNotMatchMissingTag() throws {
        let element = try makeElement(url: TestBundleResources.shared.tabla_wav)

        #expect(!SmartPredicate.tagPresent(.comment).matches(element))
    }

    // MARK: - tagEquals

    @Test func tagEqualsMatchesExactValue() throws {
        var desc = MetaAudioFileDescription(url: TestBundleResources.shared.tabla_wav)
        desc.tagProperties.set(tag: .genre, value: "Ambient")
        let element = try PlaylistElement(mafDescription: desc)

        #expect(SmartPredicate.tagEquals(.genre, "Ambient").matches(element))
    }

    @Test func tagEqualsDoesNotMatchDifferentValue() throws {
        var desc = MetaAudioFileDescription(url: TestBundleResources.shared.tabla_wav)
        desc.tagProperties.set(tag: .genre, value: "Ambient")
        let element = try PlaylistElement(mafDescription: desc)

        #expect(!SmartPredicate.tagEquals(.genre, "ambient").matches(element))
        #expect(!SmartPredicate.tagEquals(.genre, "Jazz").matches(element))
    }

    // MARK: - and combinator

    @Test func andMatchesWhenAllSubpredicatesMatch() throws {
        var element = try makeElement(url: TestBundleResources.shared.tabla_wav)
        element.dirtyFlags = [.metadata]
        element.hexColor = HexColor(red: 0, green: 1, blue: 0)

        #expect(SmartPredicate.and([.isDirty, .hasColor]).matches(element))
    }

    @Test func andDoesNotMatchWhenAnySubpredicateFails() throws {
        var element = try makeElement(url: TestBundleResources.shared.tabla_wav)
        element.dirtyFlags = [.metadata]
        // hexColor is nil

        #expect(!SmartPredicate.and([.isDirty, .hasColor]).matches(element))
    }

    @Test func andEmptyIsAlwaysTrue() throws {
        let element = try makeElement(url: TestBundleResources.shared.tabla_wav)

        #expect(SmartPredicate.and([]).matches(element))
    }

    // MARK: - or combinator

    @Test func orMatchesWhenAnySubpredicateMatches() throws {
        var element = try makeElement(url: TestBundleResources.shared.tabla_wav)
        element.hexColor = HexColor(red: 0, green: 0, blue: 1)
        // isDirty == false, hasColor == true

        #expect(SmartPredicate.or([.isDirty, .hasColor]).matches(element))
    }

    @Test func orDoesNotMatchWhenNoSubpredicateMatches() throws {
        let element = try makeElement(url: TestBundleResources.shared.tabla_wav)

        #expect(!SmartPredicate.or([.isDirty, .hasColor]).matches(element))
    }

    @Test func orEmptyIsAlwaysFalse() throws {
        let element = try makeElement(url: TestBundleResources.shared.tabla_wav)

        #expect(!SmartPredicate.or([]).matches(element))
    }

    // MARK: - Codable round-trip

    @Test func codableRoundTrip() throws {
        let predicates: [SmartPredicate] = [
            .isDirty,
            .ratingAtLeast(2),
            .hasColor,
            .tagPresent(.comment),
            .tagEquals(.genre, "Ambient"),
            .and([.isDirty, .hasColor]),
            .or([.ratingAtLeast(1), .hasColor]),
        ]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for predicate in predicates {
            let data = try encoder.encode(predicate)
            let decoded = try decoder.decode(SmartPredicate.self, from: data)
            #expect(decoded == predicate)
        }
    }

    // MARK: - isSmart

    @Test func playlistIsSmartForBuiltins() {
        for definition in SmartPlaylistDefinition.builtins {
            let playlist = Playlist(uuid: definition.uuid, title: definition.title, collectionType: .system)
            #expect(playlist.isSmart)
        }
    }

    @Test func playlistIsNotSmartForRandomUUID() {
        let playlist = Playlist(uuid: UUID(), title: "Regular", collectionType: .user)
        #expect(!playlist.isSmart)
    }
}
