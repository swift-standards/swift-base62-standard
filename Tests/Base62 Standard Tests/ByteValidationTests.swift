//
//  ByteValidationTests.swift
//  swift-base62-standard
//
//  Tests for single byte Base62 validation using static methods on UInt8.ASCII
//
//  Following the INCITS_4_1986 pattern:
//  - UInt8.ASCII.base62(digit: byte) for digit parsing
//  - UInt8.ASCII.isBase62Digit(byte) for validation
//

import Testing
@testable import Base62_Standard

@Suite("Byte Validation Tests")
struct ByteValidationTests {

    // MARK: - Valid Bytes

    @Test("Valid Base62 bytes pass validation")
    func validBytes() {
        // Digits
        for byte in UInt8(ascii: "0")...UInt8(ascii: "9") {
            #expect(UInt8.ASCII.isBase62Digit(byte), "Byte \(byte) should be valid")
        }

        // Uppercase
        for byte in UInt8(ascii: "A")...UInt8(ascii: "Z") {
            #expect(UInt8.ASCII.isBase62Digit(byte), "Byte \(byte) should be valid")
        }

        // Lowercase
        for byte in UInt8(ascii: "a")...UInt8(ascii: "z") {
            #expect(UInt8.ASCII.isBase62Digit(byte), "Byte \(byte) should be valid")
        }
    }

    // MARK: - Invalid Bytes

    @Test("Invalid bytes fail validation")
    func invalidBytes() {
        let invalidBytes: [UInt8] = [
            0,                      // NUL
            10,                     // newline
            32,                     // space
            UInt8(ascii: "!"),
            UInt8(ascii: "@"),
            UInt8(ascii: "#"),
            UInt8(ascii: "-"),
            UInt8(ascii: "_"),
            127,                    // DEL
            128,                    // high bit set
            255
        ]

        for byte in invalidBytes {
            #expect(!UInt8.ASCII.isBase62Digit(byte), "Byte \(byte) should be invalid")
            #expect(UInt8.ASCII.base62(digit: byte) == nil, "Byte \(byte) should have nil value")
        }
    }

    // MARK: - Value Extraction

    @Test("Value extraction works for valid bytes")
    func valueExtraction() {
        // Standard alphabet
        #expect(UInt8.ASCII.base62(digit: UInt8(ascii: "0")) == 0)
        #expect(UInt8.ASCII.base62(digit: UInt8(ascii: "9")) == 9)
        #expect(UInt8.ASCII.base62(digit: UInt8(ascii: "A")) == 10)
        #expect(UInt8.ASCII.base62(digit: UInt8(ascii: "Z")) == 35)
        #expect(UInt8.ASCII.base62(digit: UInt8(ascii: "a")) == 36)
        #expect(UInt8.ASCII.base62(digit: UInt8(ascii: "z")) == 61)
    }

    @Test("Value extraction returns nil for invalid bytes")
    func valueExtractionInvalid() {
        #expect(UInt8.ASCII.base62(digit: UInt8(ascii: "!")) == nil)
        #expect(UInt8.ASCII.base62(digit: UInt8(ascii: " ")) == nil)
        #expect(UInt8.ASCII.base62(digit: UInt8(0)) == nil)
    }

    // MARK: - Different Alphabets

    @Test("Different alphabets produce different values")
    func alphabetDifference() {
        let byteA = UInt8.ascii.A

        // Standard: A = 10
        #expect(UInt8.ASCII.base62(digit: byteA, using: .standard) == 10)

        // Inverted: A = 36
        #expect(UInt8.ASCII.base62(digit: byteA, using: .inverted) == 36)

        // GMP: A = 0
        #expect(UInt8.ASCII.base62(digit: byteA, using: .gmp) == 0)
    }
}
