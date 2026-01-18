//
//  IntegerEncodingTests.swift
//  swift-base62-standard
//
//  Tests for integer Base62 encoding
//

import Testing

@testable import Base62_Standard

@Suite("Integer Encoding Tests")
struct IntegerEncodingTests {

    // MARK: - Basic Encoding

    @Test("Zero encodes to single character")
    func zeroEncoding() {
        #expect(0.base62() == "0")
        #expect(UInt8(0).base62() == "0")
        #expect(UInt64(0).base62() == "0")
    }

    @Test("Single digit values encode correctly")
    func singleDigitEncoding() {
        // Standard alphabet: 0-9 A-Z a-z
        #expect(0.base62() == "0")
        #expect(9.base62() == "9")
        #expect(10.base62() == "A")
        #expect(35.base62() == "Z")
        #expect(36.base62() == "a")
        #expect(61.base62() == "z")
    }

    @Test("Two digit values encode correctly")
    func twoDigitEncoding() {
        // 62 = 1*62 + 0 = "10"
        #expect(62.base62() == "10")
        // 63 = 1*62 + 1 = "11"
        #expect(63.base62() == "11")
        // 123 = 1*62 + 61 = "1z"
        #expect(123.base62() == "1z")
    }

    @Test("Known values encode correctly")
    func knownValueEncoding() {
        // Some well-known test values
        // Standard alphabet: 0-9 (0-9), A-Z (10-35), a-z (36-61)
        #expect(42.base62() == "g")  // 42 = position 42, 42-36 = 6th lowercase = 'g'
        #expect(100.base62() == "1c")  // 100 = 1*62 + 38 = "1" + 'c' (position 38)
        #expect(1000.base62() == "G8")  // 1000 = 16*62 + 8 = 'G' (position 16) + "8"
        #expect(10000.base62() == "2bI")  // 10000 = 2*62² + 37*62 + 18 = "2" + 'b' + 'I'
    }

    // MARK: - Large Values

    @Test("UInt64.max encodes correctly")
    func uint64MaxEncoding() {
        let encoded = UInt64.max.base62()
        #expect(encoded == "LygHa16AHYF")
    }

    @Test("Large values round-trip correctly")
    func largeValueRoundTrip() {
        let values: [UInt64] = [
            1_000_000,
            1_000_000_000,
            1_000_000_000_000,
            UInt64.max / 2,
            UInt64.max,
        ]

        for value in values {
            let encoded = value.base62()
            let decoded = UInt64(base62Encoded: encoded)
            #expect(decoded == value, "Failed for value \(value)")
        }
    }

    // MARK: - Different Integer Types

    @Test("All unsigned integer types work")
    func allUnsignedTypes() {
        #expect(UInt8(42).base62() == "g")
        #expect(UInt16(42).base62() == "g")
        #expect(UInt32(42).base62() == "g")
        #expect(UInt64(42).base62() == "g")
        #expect(UInt(42).base62() == "g")
    }

    @Test("Signed integers encode magnitude")
    func signedIntegerEncoding() {
        // BinaryInteger extension uses magnitude
        #expect(42.base62() == "g")
        #expect(Int8(42).base62() == "g")
        #expect(Int64(42).base62() == "g")
    }

    // MARK: - Different Alphabets

    @Test("Inverted alphabet encoding")
    func invertedAlphabetEncoding() {
        // In inverted: 0-9 a-z A-Z
        // 10 = 'a', 36 = 'A'
        #expect(10.base62(using: .inverted)() == "a")
        #expect(36.base62(using: .inverted)() == "A")
    }

    @Test("GMP alphabet encoding")
    func gmpAlphabetEncoding() {
        // In GMP: A-Z a-z 0-9
        // 0 = 'A', 26 = 'a', 52 = '0'
        #expect(0.base62(using: .gmp)() == "A")
        #expect(26.base62(using: .gmp)() == "a")
        #expect(52.base62(using: .gmp)() == "0")
    }

    @Test("Different alphabets produce different encodings")
    func alphabetDifference() {
        let value = 42

        let standard = value.base62(using: .standard)()
        let inverted = value.base62(using: .inverted)()
        let gmp = value.base62(using: .gmp)()

        // 42 = digit value 42, which maps to different chars in each alphabet
        // Standard: 42 - 36 = 6 -> 'g' (position 6 in a-z)
        // Inverted: 42 - 10 = 32 -> position 32 in a-z is... no wait
        // Let me recalculate:
        // Standard: 42 maps to encodeTable[42] = 'g' (36 + 6 = 42, so 6th lowercase = 'g')
        // Inverted: 42 maps to encodeTable[42] = 'G' (36 + 6 = 42, so 6th uppercase = 'G')
        // GMP: 42 maps to encodeTable[42] = 'q' (26 + 16 = 42, so 16th lowercase = 'q')

        #expect(standard == "g")
        #expect(inverted == "G")
        #expect(gmp == "q")
    }

    // MARK: - API Variants

    @Test("callAsFunction works")
    func callAsFunctionAPI() {
        #expect(42.base62() == "g")
    }

    @Test("encoded() method works")
    func encodedMethodAPI() {
        #expect(42.base62.encoded() == "g")
    }

    @Test("encodedBytes() method works")
    func encodedBytesAPI() {
        let bytes = 42.base62.encodedBytes()
        #expect(bytes == [UInt8(ascii: "g")])
    }

    @Test("String(base62:) initializer works")
    func stringInitializer() {
        #expect(String(base62: 42) == "g")
        #expect(String(base62: 42, using: .inverted) == "G")
    }
}
