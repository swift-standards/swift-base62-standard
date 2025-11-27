//
//  ExhaustiveVerificationTests.swift
//  swift-base62-standard
//
//  Comprehensive verification tests for mathematical correctness
//

import Testing

@testable import Base62_Standard

@Suite("Exhaustive Verification Tests")
struct ExhaustiveVerificationTests {

    // MARK: - Integer Round-Trip Tests

    @Test("UInt8 boundary and sample values round-trip correctly")
    func uint8RoundTrip() {
        // Boundaries
        let boundaries: [UInt8] = [0, 1, 61, 62, 63, 254, 255]
        for value in boundaries {
            let encoded = value.base62()
            let decoded = UInt8(base62Encoded: encoded)
            #expect(decoded == value, "Failed for \(value)")
        }

        // Random samples
        for _ in 0..<100 {
            let value = UInt8.random(in: 0...255)
            let encoded = value.base62()
            let decoded = UInt8(base62Encoded: encoded)
            #expect(decoded == value)
        }
    }

    @Test("UInt16 boundary and sample values round-trip correctly")
    func uint16RoundTrip() {
        let boundaries: [UInt16] = [
            0, 1, 61, 62, 63,
            255, 256,
            3843, 3844,
            UInt16.max - 1, UInt16.max,
        ]

        for value in boundaries {
            let encoded = value.base62()
            let decoded = UInt16(base62Encoded: encoded)
            #expect(decoded == value, "Failed for \(value)")
        }

        for _ in 0..<100 {
            let value = UInt16.random(in: 0...UInt16.max)
            let encoded = value.base62()
            let decoded = UInt16(base62Encoded: encoded)
            #expect(decoded == value)
        }
    }

    @Test("Single-byte arrays round-trip correctly")
    func singleByteArrayRoundTrip() {
        // Boundaries
        for byte: UInt8 in [0, 1, 61, 62, 127, 128, 254, 255] {
            let bytes: [UInt8] = [byte]
            let encoded = bytes.base62()
            let decoded = [UInt8](base62: encoded)
            #expect(decoded == bytes, "Failed for byte \(byte)")
        }

        // Random samples
        for _ in 0..<100 {
            let byte = UInt8.random(in: 0...255)
            let bytes: [UInt8] = [byte]
            let encoded = bytes.base62()
            let decoded = [UInt8](base62: encoded)
            #expect(decoded == bytes)
        }
    }

    // MARK: - Alphabet Verification

    static let allAlphabets: [Base62_Standard.Alphabet] = [.standard, .inverted, .gmp]

    @Test("Alphabet encode/decode is bijective", arguments: allAlphabets)
    func alphabetBijective(alphabet: Base62_Standard.Alphabet) {
        var seen = Set<UInt8>()
        for value in UInt8(0)..<62 {
            let encoded = alphabet.encode(value)
            let decoded = alphabet.decode(encoded)
            #expect(decoded == value)
            #expect(!seen.contains(encoded), "Duplicate encoding")
            seen.insert(encoded)
        }
        #expect(seen.count == 62)
    }

    @Test("Byte validity is consistent with decode")
    func byteValidityConsistency() {
        let alphabet = Base62_Standard.Alphabet.standard
        var validCount = 0

        for byte in UInt8.min...UInt8.max {
            let isValid = alphabet.isValid(byte)
            let decoded = alphabet.decode(byte)
            #expect(isValid == (decoded != nil))
            if isValid { validCount += 1 }
        }

        #expect(validCount == 62)
    }

    // MARK: - Known Integer Encodings

    static let knownIntegerEncodings: [(UInt64, String)] = [
        (0, "0"), (9, "9"), (10, "A"), (35, "Z"), (36, "a"), (61, "z"),
        (62, "10"), (63, "11"), (123, "1z"), (124, "20"), (255, "47"),
        (3844, "100"),
        (UInt64.max, "LygHa16AHYF"),
    ]

    @Test("Known integer encodings match expected", arguments: knownIntegerEncodings)
    func knownIntegerEncoding(value: UInt64, expected: String) {
        #expect(value.base62() == expected)
        #expect(UInt64(base62Encoded: expected) == value)
    }

    // MARK: - Known Byte Array Encodings

    static let knownByteArrayEncodings: [([UInt8], String)] = [
        ([0], "0"), ([1], "1"), ([61], "z"), ([62], "10"), ([255], "47"),
        ([1, 0], "48"),  // 256 = 4*62 + 8
        ([0, 1], "01"),  // 1 with leading zero
        ([1, 0, 0], "H32"),  // 65536 = 17*62² + 3*62 + 2
        ([0, 0, 0], "000"),  // three zeros
    ]

    @Test("Known byte array encodings match expected", arguments: knownByteArrayEncodings)
    func knownByteArrayEncoding(bytes: [UInt8], expected: String) {
        #expect(bytes.base62() == expected)
        #expect([UInt8](base62: expected) == bytes)
    }

    // MARK: - Overflow Boundary Tests

    static let uint8BoundaryValues: [(String, UInt8?)] = [
        ("46", 254), ("47", 255), ("48", nil), ("49", nil), ("ZZ", nil),
    ]

    @Test("UInt8 overflow boundary is correct", arguments: uint8BoundaryValues)
    func uint8OverflowBoundary(encoded: String, expected: UInt8?) {
        #expect(UInt8(base62Encoded: encoded) == expected)
    }

    // MARK: - Encoding Length Formula

    static let encodingLengthTestCases: [(UInt64, Int)] = [
        (0, 1), (1, 1), (61, 1), (62, 2), (3843, 2), (3844, 3), (238327, 3), (238328, 4),
    ]

    @Test("Encoding length matches expected formula", arguments: encodingLengthTestCases)
    func encodingLengthFormula(value: UInt64, expectedLength: Int) {
        #expect(value.base62().count == expectedLength)
    }

    // MARK: - Cross-Alphabet Tests

    static let crossAlphabetTestValues: [UInt64] = [0, 1, 61, 62, 255, 256, 65535, 1_000_000]

    @Test(
        "Integer decode is inverse of encode for all alphabets",
        arguments: allAlphabets, crossAlphabetTestValues)
    func decodeIsInverseOfEncode(alphabet: Base62_Standard.Alphabet, value: UInt64) {
        let encoded = value.base62(using: alphabet)()
        let decoded = UInt64(base62Encoded: encoded, using: alphabet)
        #expect(decoded == value)
    }

    static let crossAlphabetByteArrays: [[UInt8]] = [
        [], [0], [0, 0], [1], [255], [1, 0], [0, 1], [0, 0, 1], [255, 255, 255],
    ]

    @Test(
        "Byte array decode is inverse of encode for all alphabets",
        arguments: allAlphabets, crossAlphabetByteArrays)
    func byteArrayDecodeIsInverse(alphabet: Base62_Standard.Alphabet, bytes: [UInt8]) {
        let encoded = bytes.base62(using: alphabet).encoded()
        let decoded = [UInt8](base62: encoded, using: alphabet)
        #expect(decoded == bytes)
    }

    // MARK: - Leading Zero Preservation

    static let leadingZeroTestCases: [[UInt8]] = [
        [0], [0, 0], [0, 0, 0], [0, 1], [0, 0, 1], [0, 0, 0, 1], [0, 255], [0, 0, 255],
    ]

    @Test("Leading zeros are preserved in byte arrays", arguments: leadingZeroTestCases)
    func leadingZerosPreserved(bytes: [UInt8]) {
        let encoded = bytes.base62()
        let decoded = [UInt8](base62: encoded)
        #expect(decoded == bytes)

        let leadingZeroCount = bytes.prefix(while: { $0 == 0 }).count
        let leadingZeroChars = encoded.prefix(while: { $0 == Character("0") }).count
        #expect(leadingZeroChars == leadingZeroCount)
    }
}
