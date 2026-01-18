//
//  ReadmeVerificationTests.swift
//  swift-base62-standard
//
//  Tests that verify all README code examples compile and work correctly
//

import ASCII
import Testing

@testable import Base62_Standard

@Suite("README Verification Tests")
struct ReadmeVerificationTests {

    // MARK: - Quick Start Examples

    @Test("Quick Start - Integer encoding")
    func quickStartIntegerEncoding() {
        // Encode integers
        let encoded = 42.base62()  // "g"
        let max = UInt64.max.base62()  // "LygHa16AHYF"

        #expect(encoded == "g")
        #expect(max == "LygHa16AHYF")
    }

    @Test("Quick Start - Integer decoding")
    func quickStartIntegerDecoding() {
        // Decode integers
        let value = UInt64(base62Encoded: "g")  // Optional(42)

        #expect(value == 42)
    }

    @Test("Quick Start - Byte array encoding")
    func quickStartByteArrayEncoding() {
        // Encode byte arrays
        let bytes: [UInt8] = [72, 101, 108, 108, 111]
        let base62 = bytes.base62()

        #expect(!base62.isEmpty)
    }

    @Test("Quick Start - Byte array decoding")
    func quickStartByteArrayDecoding() {
        // Decode byte arrays
        let decoded = [UInt8](base62: "4Wd")  // [67, 247]

        #expect(decoded == [67, 247])
    }

    // MARK: - Integer Encoding Examples

    @Test("Integer Encoding - Basic")
    func integerEncodingBasic() {
        // Basic encoding
        #expect(42.base62() == "g")
        #expect(42.base62.encoded() == "g")
        #expect(42.base62.encodedBytes() == [103])  // ASCII 'g'
    }

    @Test("Integer Encoding - Different alphabets")
    func integerEncodingAlphabets() {
        // Different alphabets
        #expect(42.base62(using: .standard)() == "g")
        #expect(42.base62(using: .inverted)() == "G")
        #expect(42.base62(using: .gmp)() == "q")
    }

    @Test("Integer Encoding - String initializer")
    func integerEncodingStringInit() {
        // String initializer
        #expect(String(base62: 42) == "g")
        #expect(String(base62: 42, using: .inverted) == "G")
    }

    // MARK: - Integer Decoding Examples

    @Test("Integer Decoding - Failable initializer")
    func integerDecodingFailable() {
        // Failable initializer
        #expect(UInt64(base62Encoded: "g") == 42)
        #expect(UInt64(base62Encoded: "abc") == 140716)
        #expect(UInt64(base62Encoded: "!!") == nil)  // invalid
        #expect(UInt8(base62Encoded: "ZZ") == nil)  // overflow
    }

    @Test("Integer Decoding - Throwing decode")
    func integerDecodingThrowing() throws {
        // Throwing decode via wrapper
        let value: UInt64 = try "g".base62.decode()
        #expect(value == 42)
    }

    // MARK: - Byte Array Encoding Examples

    @Test("Byte Array Encoding - Basic")
    func byteArrayEncodingBasic() {
        let bytes: [UInt8] = [1, 0, 0]
        #expect(bytes.base62() == "H32")  // 65536 in Base62
    }

    @Test("Byte Array Encoding - Leading zeros preserved")
    func byteArrayEncodingLeadingZeros() {
        // Leading zeros are preserved
        #expect([0, 0, 1].base62() == "001")
        #expect([0].base62() == "0")
    }

    // MARK: - Byte Array Decoding Examples

    @Test("Byte Array Decoding")
    func byteArrayDecoding() {
        #expect([UInt8](base62: "H32") == [1, 0, 0])
        #expect([UInt8](base62: "001") == [0, 0, 1])
        #expect([UInt8](base62: "") == [])  // empty
        #expect([UInt8](base62: "!!") == nil)  // invalid
    }

    // MARK: - String Validation Examples

    @Test("String Validation")
    func stringValidation() {
        #expect("abc123".base62() == "abc123")  // valid
        #expect("abc!".base62() == nil)  // invalid character
        #expect("abc123".base62.isValid == true)
    }

    // MARK: - Alphabet Variant Examples

    @Test("Alphabet Variants - Standard")
    func alphabetStandard() {
        // Standard: 0-9, A-Z, a-z (default)
        #expect(10.base62(using: .standard)() == "A")
        #expect(36.base62(using: .standard)() == "a")
    }

    @Test("Alphabet Variants - Inverted")
    func alphabetInverted() {
        // Inverted: 0-9, a-z, A-Z
        #expect(10.base62(using: .inverted)() == "a")
        #expect(36.base62(using: .inverted)() == "A")
    }

    @Test("Alphabet Variants - GMP")
    func alphabetGMP() {
        // GMP: A-Z, a-z, 0-9
        #expect(0.base62(using: .gmp)() == "A")
        #expect(52.base62(using: .gmp)() == "0")
    }

    @Test("Alphabet Variants - Custom")
    func alphabetCustom() {
        // Custom alphabet
        let custom = Base62_Standard.Alphabet(
            characters: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
            name: "custom"
        )
        #expect(42.base62(using: custom)() == "q")
    }

    // MARK: - Single Byte Validation (INCITS Pattern)

    @Test("Single Byte Validation - isBase62Digit")
    func singleByteIsBase62Digit() {
        // Check if a byte is a valid Base62 digit
        #expect(Binary.ASCII.isBase62Digit(UInt8.ascii.A) == true)
        #expect(Binary.ASCII.isBase62Digit(UInt8.ascii.exclamationPoint) == false)
    }

    @Test("Single Byte Validation - base62 digit parsing")
    func singleByteDigitParsing() {
        // Parse Base62 digit to numeric value
        #expect(Binary.ASCII.base62(digit: UInt8.ascii.A) == 10)  // standard alphabet
        #expect(Binary.ASCII.base62(digit: UInt8.ascii.A, using: .gmp) == 0)  // GMP alphabet
    }
}
