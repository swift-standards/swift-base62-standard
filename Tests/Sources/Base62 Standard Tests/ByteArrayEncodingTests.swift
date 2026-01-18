//
//  ByteArrayEncodingTests.swift
//  swift-base62-standard
//
//  Tests for byte array Base62 encoding/decoding
//

import Testing

@testable import Base62_Standard

@Suite("Byte Array Encoding Tests")
struct ByteArrayEncodingTests {

    // MARK: - Empty Input

    @Test("Empty array encodes to empty string")
    func emptyArrayEncoding() {
        let bytes: [UInt8] = []
        #expect(bytes.base62().isEmpty == true)
    }

    @Test("Empty string decodes to empty array")
    func emptyStringDecoding() {
        #expect([UInt8](base62: "") == [])
    }

    // MARK: - Leading Zeros

    @Test("Single zero byte encodes to single zero")
    func singleZeroEncoding() {
        let bytes: [UInt8] = [0]
        #expect(bytes.base62() == "0")
    }

    @Test("Multiple leading zeros are preserved")
    func leadingZerosPreserved() {
        let bytes: [UInt8] = [0, 0, 1]
        let encoded = bytes.base62()
        let decoded = [UInt8](base62: encoded)

        #expect(decoded == bytes)
    }

    @Test("All zeros encode to correct number of zeros")
    func allZerosEncoding() {
        let bytes: [UInt8] = [0, 0, 0]
        #expect(bytes.base62() == "000")
    }

    // MARK: - Basic Encoding

    @Test("Single byte encoding")
    func singleByteEncoding() {
        // 1 encodes to "1"
        #expect([UInt8(1)].base62() == "1")
        // 61 encodes to "z"
        #expect([UInt8(61)].base62() == "z")
        // 62 encodes to "10"
        #expect([UInt8(62)].base62() == "10")
        // 255 encodes to "47"
        #expect([UInt8(255)].base62() == "47")
    }

    @Test("Two byte encoding")
    func twoByteEncoding() {
        // [1, 0] = 256 in big-endian
        let bytes: [UInt8] = [1, 0]
        let encoded = bytes.base62()
        let decoded = [UInt8](base62: encoded)
        #expect(decoded == bytes)
    }

    // MARK: - Known Values

    @Test("Known byte sequences encode correctly")
    func knownByteSequences() {
        // "Hello" = [72, 101, 108, 108, 111]
        let hello: [UInt8] = [72, 101, 108, 108, 111]
        let encoded = hello.base62()

        // Verify round-trip
        let decoded = [UInt8](base62: encoded)
        #expect(decoded == hello)
    }

    // MARK: - Round-Trip Tests

    @Test("Random bytes round-trip correctly")
    func randomBytesRoundTrip() {
        for length in [1, 10, 100, 500] {
            let bytes = (0..<length).map { _ in UInt8.random(in: 0...255) }
            let encoded = bytes.base62()
            let decoded = [UInt8](base62: encoded)

            #expect(decoded == bytes, "Failed for length \(length)")
        }
    }

    @Test("Bytes with leading zeros round-trip")
    func leadingZerosRoundTrip() {
        for leadingZeros in 1...5 {
            var bytes = [UInt8](repeating: 0, count: leadingZeros)
            bytes.append(contentsOf: [42, 123, 255])

            let encoded = bytes.base62()
            let decoded = [UInt8](base62: encoded)

            #expect(decoded == bytes, "Failed for \(leadingZeros) leading zeros")
        }
    }

    // MARK: - Invalid Input

    @Test("Invalid characters return nil when decoding")
    func invalidCharactersReturnNil() {
        #expect([UInt8](base62: "abc!") == nil)
        #expect([UInt8](base62: " ") == nil)
        #expect([UInt8](base62: "-_") == nil)
    }

    // MARK: - Different Alphabets

    @Test("Different alphabets produce different encodings")
    func alphabetDifference() {
        let bytes: [UInt8] = [72, 101, 108, 108, 111]

        let standard = bytes.base62(using: .standard).encoded()
        let inverted = bytes.base62(using: .inverted).encoded()
        let gmp = bytes.base62(using: .gmp).encoded()

        // All should be different
        #expect(standard != inverted || standard != gmp)

        // All should round-trip with same alphabet
        #expect([UInt8](base62: standard, using: .standard) == bytes)
        #expect([UInt8](base62: inverted, using: .inverted) == bytes)
        #expect([UInt8](base62: gmp, using: .gmp) == bytes)
    }

    // MARK: - API Variants

    @Test("callAsFunction works")
    func callAsFunctionAPI() {
        let bytes: [UInt8] = [1, 2, 3]
        let encoded = bytes.base62()
        #expect(!encoded.isEmpty)
    }

    @Test("encoded() method works")
    func encodedMethodAPI() {
        let bytes: [UInt8] = [1, 2, 3]
        let encoded = bytes.base62.encoded()
        #expect(!encoded.isEmpty)
    }

    @Test("encodedBytes() method works")
    func encodedBytesAPI() {
        let bytes: [UInt8] = [1, 2, 3]
        let encodedBytes = bytes.base62.encodedBytes()
        #expect(!encodedBytes.isEmpty)
    }

    @Test("String(base62:) initializer works")
    func stringInitializer() {
        let bytes: [UInt8] = [72, 101, 108, 108, 111]
        let encoded = String(base62: bytes)
        let decoded = [UInt8](base62: encoded)
        #expect(decoded == bytes)
    }

    // MARK: - Collection Extension

    @Test("ArraySlice works")
    func arraySliceWorks() {
        let bytes: [UInt8] = [0, 1, 2, 3, 4, 5]
        let slice = bytes[1..<4]

        let encoded = slice.base62.encoded()
        let decoded = [UInt8](base62: encoded)

        #expect(decoded == [1, 2, 3])
    }

    @Test("CollectionWrapper.decoded() works")
    func collectionWrapperDecoded() {
        // Encode then decode as Base62 bytes
        let original: [UInt8] = [72, 101]
        let encoded = original.base62.encodedBytes()

        // Now decode those ASCII bytes back to original
        let decoded = encoded.base62.decoded()
        #expect(decoded == original)
    }
}
