//
//  IntegerDecodingTests.swift
//  swift-base62-standard
//
//  Tests for integer Base62 decoding
//

import Testing
@testable import Base62_Standard

@Suite("Integer Decoding Tests")
struct IntegerDecodingTests {

    // MARK: - Basic Decoding

    @Test("Single character decodes correctly")
    func singleCharacterDecoding() {
        #expect(UInt64(base62Encoded: "0") == 0)
        #expect(UInt64(base62Encoded: "9") == 9)
        #expect(UInt64(base62Encoded: "A") == 10)
        #expect(UInt64(base62Encoded: "Z") == 35)
        #expect(UInt64(base62Encoded: "a") == 36)
        #expect(UInt64(base62Encoded: "z") == 61)
    }

    @Test("Multi-character decodes correctly")
    func multiCharacterDecoding() {
        #expect(UInt64(base62Encoded: "10") == 62)
        #expect(UInt64(base62Encoded: "11") == 63)
        #expect(UInt64(base62Encoded: "1z") == 123)
        #expect(UInt64(base62Encoded: "g") == 42)
    }

    // MARK: - Invalid Input

    @Test("Empty string returns nil")
    func emptyStringReturnsNil() {
        #expect(UInt64(base62Encoded: "") == nil)
    }

    @Test("Invalid characters return nil")
    func invalidCharactersReturnNil() {
        #expect(UInt64(base62Encoded: "!") == nil)
        #expect(UInt64(base62Encoded: "abc!") == nil)
        #expect(UInt64(base62Encoded: " ") == nil)
        #expect(UInt64(base62Encoded: "-") == nil)
        #expect(UInt64(base62Encoded: "_") == nil)
    }

    @Test("Overflow returns nil")
    func overflowReturnsNil() {
        // Value too large for UInt8 (max 255)
        // 256 = 4*62 + 8 = "48"
        #expect(UInt8(base62Encoded: "48") == nil)  // 256

        // Value too large for UInt64
        let tooLarge = "LygHa16AHYG" // UInt64.max + 1
        #expect(UInt64(base62Encoded: tooLarge) == nil)
    }

    // MARK: - Throwing Variant

    @Test("Throwing decode with empty input")
    func throwingDecodeEmpty() {
        #expect(throws: Base62_Standard.Error.empty) {
            try "".base62.decode(as: UInt64.self) as UInt64
        }
    }

    @Test("Throwing decode with invalid character")
    func throwingDecodeInvalidCharacter() {
        do {
            let _: UInt64 = try "abc!".base62.decode()
            Issue.record("Should have thrown")
        } catch let error as Base62_Standard.Error {
            if case .invalidCharacter(let value, let byte) = error {
                #expect(value == "abc!")
                #expect(byte == UInt8(ascii: "!"))
            } else {
                Issue.record("Wrong error type")
            }
        } catch {
            Issue.record("Unexpected error type")
        }
    }

    @Test("Throwing decode with overflow")
    func throwingDecodeOverflow() {
        #expect(throws: Base62_Standard.Error.overflow) {
            try "ZZZZZZZZZZZ".base62.decode(as: UInt8.self) as UInt8
        }
    }

    // MARK: - Different Alphabets

    @Test("Inverted alphabet decoding")
    func invertedAlphabetDecoding() {
        #expect(UInt64(base62Encoded: "a", using: .inverted) == 10)
        #expect(UInt64(base62Encoded: "A", using: .inverted) == 36)
    }

    @Test("GMP alphabet decoding")
    func gmpAlphabetDecoding() {
        #expect(UInt64(base62Encoded: "A", using: .gmp) == 0)
        #expect(UInt64(base62Encoded: "a", using: .gmp) == 26)
        #expect(UInt64(base62Encoded: "0", using: .gmp) == 52)
    }

    // MARK: - Round-Trip

    @Test("Random value round-trip")
    func randomValueRoundTrip() {
        for _ in 0..<100 {
            let value = UInt64.random(in: 0...UInt64.max)
            let encoded = value.base62()
            let decoded = UInt64(base62Encoded: encoded)
            #expect(decoded == value)
        }
    }

    // MARK: - API Variants

    @Test("String.base62.decode() works")
    func stringWrapperDecode() {
        let result: UInt64? = try? "g".base62.decode()
        #expect(result == 42)
    }

    @Test("String.base62.decode() with type parameter")
    func stringWrapperDecodeWithType() {
        let result = try? "g".base62.decode(as: UInt64.self)
        #expect(result == 42)
    }
}
