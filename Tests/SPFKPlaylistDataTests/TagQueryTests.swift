// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import SPFKMetadataBase
import SPFKTesting
import Testing

@testable import SPFKPlaylistData

@Suite(.tags(.file))
final class TagQueryTests: TestCaseModel {
    // MARK: - Empty / no-op

    @Test func emptyStringProducesNoClauses() {
        let q = TagQuery(string: "")
        #expect(q.tagClauses.isEmpty)
        #expect(q.fuzzyQuery.array.isEmpty)
        #expect(!q.hasStructuredClauses)
    }

    @Test func plainFuzzyTermPassesThrough() {
        let q = TagQuery(string: "piano")
        #expect(q.tagClauses.isEmpty)
        #expect(q.fuzzyQuery.array.isNotEmpty)
    }

    // MARK: - Colon syntax

    @Test func colonSyntaxRawValueKey() {
        let q = TagQuery(string: "bpm:120")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .bpm)
        #expect(q.tagClauses[0].value == "120")
        #expect(q.fuzzyQuery.array.isEmpty)
        #expect(q.hasStructuredClauses)
    }

    @Test func colonSyntaxAliasKey() {
        // "key" is an alias for .initialKey
        let q = TagQuery(string: "key:Cm")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .initialKey)
        #expect(q.tagClauses[0].value == "Cm")
    }

    @Test func colonSyntaxLufsAlias() {
        let q = TagQuery(string: "lufs:-14")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .loudnessIntegrated)
        #expect(q.tagClauses[0].value == "-14")
    }

    @Test func colonSyntaxUnknownKeyFallsToFuzzy() {
        let q = TagQuery(string: "unknown:value")
        #expect(q.tagClauses.isEmpty)
        #expect(q.fuzzyQuery.originalString == "unknown:value")
    }

    @Test func colonSyntaxEmptyValueIsIgnored() {
        let q = TagQuery(string: "bpm:")
        #expect(q.tagClauses.isEmpty)
    }

    @Test func colonSyntaxMultipleClauses() {
        let q = TagQuery(string: "bpm:120 artist:arca")
        #expect(q.tagClauses.count == 2)
        let keys = q.tagClauses.map(\.key)
        #expect(keys.contains(.bpm))
        #expect(keys.contains(.artist))
        #expect(q.fuzzyQuery.array.isEmpty)
    }

    @Test func colonSyntaxWithFuzzyRemainder() {
        let q = TagQuery(string: "piano bpm:120")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .bpm)
        #expect(q.fuzzyQuery.originalString == "piano")
    }

    // MARK: - Unit inference

    @Test func unitInferenceValueBeforeKey() {
        // "120 bpm" — natural order
        let q = TagQuery(string: "120 bpm")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .bpm)
        #expect(q.tagClauses[0].value == "120")
        #expect(q.fuzzyQuery.array.isEmpty)
    }

    @Test func unitInferenceValueAfterKey() {
        // "bpm 120" — reversed order
        let q = TagQuery(string: "bpm 120")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .bpm)
        #expect(q.tagClauses[0].value == "120")
    }

    @Test func unitInferenceWithFuzzyRemainder() {
        let q = TagQuery(string: "kick 120 bpm")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .bpm)
        #expect(q.tagClauses[0].value == "120")
        // "kick" is not consumed
        #expect(q.fuzzyQuery.originalString == "kick")
    }

    @Test func unitInferenceNonNumericAdjacentSkipped() {
        // "piano" is not numeric — no clause should be produced for bpm
        let q = TagQuery(string: "piano bpm")
        #expect(q.tagClauses.isEmpty)
        #expect(q.fuzzyQuery.originalString == "piano bpm")
    }

    @Test func unitInferenceLufs() {
        let q = TagQuery(string: "-14 lufs")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .loudnessIntegrated)
        #expect(q.tagClauses[0].value == "-14")
    }

    @Test func unitInferenceTempoAlias() {
        let q = TagQuery(string: "128 tempo")
        #expect(q.tagClauses.count == 1)
        #expect(q.tagClauses[0].key == .bpm)
        #expect(q.tagClauses[0].value == "128")
    }

    // MARK: - PlaylistElement.similarity(to: TagQuery)

    @Test func elementMatchesTagClause() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.tagProperties.set(tag: .bpm, value: "120")
        let element = try PlaylistElement(mafDescription: desc)

        let q = TagQuery(string: "120 bpm")
        #expect(element.similarity(to: q) != nil)
    }

    @Test func elementNoMatchWhenTagValueDiffers() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.tagProperties.set(tag: .bpm, value: "90")
        let element = try PlaylistElement(mafDescription: desc)

        let q = TagQuery(string: "120 bpm")
        #expect(element.similarity(to: q) == nil)
    }

    @Test func elementNoMatchWhenTagAbsent() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: MetaAudioFileDescription(url: url))

        let q = TagQuery(string: "120 bpm")
        #expect(element.similarity(to: q) == nil)
    }

    @Test func elementMatchesTagClauseReturnsFullScore() throws {
        let url = TestBundleResources.shared.tabla_wav
        var desc = MetaAudioFileDescription(url: url)
        desc.tagProperties.set(tag: .bpm, value: "120")
        let element = try PlaylistElement(mafDescription: desc)

        let q = TagQuery(string: "bpm:120")
        #expect(element.similarity(to: q) == 1.0)
    }

    @Test func elementEmptyQueryReturnsNil() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: MetaAudioFileDescription(url: url))

        let q = TagQuery(string: "")
        #expect(element.similarity(to: q) == nil)
    }

    @Test func elementPureFuzzyQueryStillWorks() throws {
        let url = TestBundleResources.shared.tabla_wav
        let element = try PlaylistElement(mafDescription: MetaAudioFileDescription(url: url))

        // "tabla" should match the filename via fuzzy
        let q = TagQuery(string: "tabla")
        #expect(element.similarity(to: q) != nil)
    }
}
