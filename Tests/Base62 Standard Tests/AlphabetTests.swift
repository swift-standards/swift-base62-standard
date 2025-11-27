//
//  AlphabetTests.swift
//  swift-base62-standard
//
//  Tests for Base62 alphabet functionality
//

import Testing
@testable import Base62_Standard

@Suite("Alphabet Tests")
struct AlphabetTests {

    // MARK: - Predefined Alphabets

    @Test("Standard alphabet has correct character ordering")
    func standardAlphabetOrdering() {
        let alphabet = Base62_Standard.Alphabet.standard

        // 0-9 → values 0-9
        #expect(alphabet.decode(UInt8(ascii: "0")) == 0)
        #expect(alphabet.decode(UInt8(ascii: "9")) == 9)

        // A-Z → values 10-35
        #expect(alphabet.decode(UInt8(ascii: "A")) == 10)
        #expect(alphabet.decode(UInt8(ascii: "Z")) == 35)

        // a-z → values 36-61
        #expect(alphabet.decode(UInt8(ascii: "a")) == 36)
        #expect(alphabet.decode(UInt8(ascii: "z")) == 61)
    }

    @Test("Inverted alphabet has correct character ordering")
    func invertedAlphabetOrdering() {
        let alphabet = Base62_Standard.Alphabet.inverted

        // 0-9 → values 0-9
        #expect(alphabet.decode(UInt8(ascii: "0")) == 0)
        #expect(alphabet.decode(UInt8(ascii: "9")) == 9)

        // a-z → values 10-35
        #expect(alphabet.decode(UInt8(ascii: "a")) == 10)
        #expect(alphabet.decode(UInt8(ascii: "z")) == 35)

        // A-Z → values 36-61
        #expect(alphabet.decode(UInt8(ascii: "A")) == 36)
        #expect(alphabet.decode(UInt8(ascii: "Z")) == 61)
    }

    @Test("GMP alphabet has correct character ordering")
    func gmpAlphabetOrdering() {
        let alphabet = Base62_Standard.Alphabet.gmp

        // A-Z → values 0-25
        #expect(alphabet.decode(UInt8(ascii: "A")) == 0)
        #expect(alphabet.decode(UInt8(ascii: "Z")) == 25)

        // a-z → values 26-51
        #expect(alphabet.decode(UInt8(ascii: "a")) == 26)
        #expect(alphabet.decode(UInt8(ascii: "z")) == 51)

        // 0-9 → values 52-61
        #expect(alphabet.decode(UInt8(ascii: "0")) == 52)
        #expect(alphabet.decode(UInt8(ascii: "9")) == 61)
    }

    // MARK: - Encode/Decode Round-Trip

    @Test("All predefined alphabets have 62 unique characters")
    func alphabetUniqueness() {
        for alphabet in [Base62_Standard.Alphabet.standard, .inverted, .gmp] {
            #expect(alphabet.encodeTable.count == 62)
            #expect(Set(alphabet.encodeTable).count == 62)
        }
    }

    @Test("Encode/decode round-trip for all values")
    func encodeDecodeRoundTrip() {
        for alphabet in [Base62_Standard.Alphabet.standard, .inverted, .gmp] {
            for value in UInt8(0)..<62 {
                let encoded = alphabet.encode(value)
                let decoded = alphabet.decode(encoded)
                #expect(decoded == value, "Failed for value \(value) in alphabet \(alphabet.name)")
            }
        }
    }

    // MARK: - Invalid Characters

    @Test("Invalid characters return nil")
    func invalidCharacters() {
        let alphabet = Base62_Standard.Alphabet.standard

        // Special characters
        #expect(alphabet.decode(UInt8(ascii: "!")) == nil)
        #expect(alphabet.decode(UInt8(ascii: "@")) == nil)
        #expect(alphabet.decode(UInt8(ascii: "#")) == nil)
        #expect(alphabet.decode(UInt8(ascii: " ")) == nil)
        #expect(alphabet.decode(UInt8(ascii: "-")) == nil)
        #expect(alphabet.decode(UInt8(ascii: "_")) == nil)

        // Control characters
        #expect(alphabet.decode(0) == nil)
        #expect(alphabet.decode(10) == nil)  // newline
        #expect(alphabet.decode(127) == nil) // DEL
    }

    @Test("isValid returns correct values")
    func isValidTest() {
        let alphabet = Base62_Standard.Alphabet.standard

        // Valid
        #expect(alphabet.isValid(UInt8(ascii: "0")))
        #expect(alphabet.isValid(UInt8(ascii: "A")))
        #expect(alphabet.isValid(UInt8(ascii: "z")))

        // Invalid
        #expect(!alphabet.isValid(UInt8(ascii: "!")))
        #expect(!alphabet.isValid(UInt8(ascii: " ")))
        #expect(!alphabet.isValid(0))
    }

    // MARK: - Custom Alphabet

    @Test("Custom alphabet creation")
    func customAlphabet() {
        // GMP-like but with different name
        let custom = Base62_Standard.Alphabet(
            characters: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
            name: "custom"
        )

        #expect(custom.name == "custom")
        #expect(custom.decode(UInt8(ascii: "A")) == 0)
        #expect(custom.decode(UInt8(ascii: "0")) == 52)
    }

    // MARK: - Default Alphabet

    @Test("Default alphabet is standard")
    func defaultAlphabet() {
        #expect(Base62_Standard.Alphabet.default.name == "standard")
    }
}
