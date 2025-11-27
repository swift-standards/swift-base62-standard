//
//  EdgeCaseTests.swift
//  swift-base62-standard
//
//  Tests for edge cases and boundary conditions
//

import Testing
@testable import Base62_Standard

@Suite("Edge Case Tests")
struct EdgeCaseTests {

    // MARK: - Boundary Values

    @Test("All single-digit values round-trip")
    func allSingleDigitRoundTrip() {
        for value in UInt8(0)...61 {
            let encoded = value.base62()
            let decoded = UInt8(base62Encoded: encoded)
            #expect(decoded == value, "Failed for value \(value)")
            #expect(encoded.count == 1, "Single digit should encode to single char")
        }
    }

    @Test("Value 62 is first two-digit value")
    func value62() {
        let encoded = 62.base62()
        #expect(encoded == "10")
        #expect(UInt64(base62Encoded: "10") == 62)
    }

    @Test("Maximum values for each integer type")
    func maxValues() {
        // UInt8
        let u8 = UInt8.max
        #expect(UInt8(base62Encoded: u8.base62()) == u8)

        // UInt16
        let u16 = UInt16.max
        #expect(UInt16(base62Encoded: u16.base62()) == u16)

        // UInt32
        let u32 = UInt32.max
        #expect(UInt32(base62Encoded: u32.base62()) == u32)

        // UInt64
        let u64 = UInt64.max
        #expect(UInt64(base62Encoded: u64.base62()) == u64)
    }

    // MARK: - Leading Zeros in Byte Arrays

    @Test("Single leading zero preserved")
    func singleLeadingZero() {
        let bytes: [UInt8] = [0, 42]
        let encoded = bytes.base62()
        let decoded = [UInt8](base62: encoded)
        #expect(decoded == bytes)
    }

    @Test("Many leading zeros preserved")
    func manyLeadingZeros() {
        for count in 1...10 {
            var bytes = [UInt8](repeating: 0, count: count)
            bytes.append(42)

            let encoded = bytes.base62()
            let decoded = [UInt8](base62: encoded)
            #expect(decoded == bytes, "Failed for \(count) leading zeros")
        }
    }

    @Test("All zeros array")
    func allZerosArray() {
        for count in 1...5 {
            let bytes = [UInt8](repeating: 0, count: count)
            let encoded = bytes.base62()
            let decoded = [UInt8](base62: encoded)

            #expect(encoded.count == count, "Encoded should have \(count) zero chars")
            #expect(decoded == bytes, "Failed for \(count) zeros")
        }
    }

    // MARK: - Large Data

    @Test("1KB data round-trip")
    func oneKilobyteRoundTrip() {
        let bytes = (0..<1024).map { _ in UInt8.random(in: 0...255) }
        let encoded = bytes.base62()
        let decoded = [UInt8](base62: encoded)
        #expect(decoded == bytes)
    }

    @Test("Data with pattern round-trip")
    func patternDataRoundTrip() {
        // Alternating pattern
        let pattern: [UInt8] = (0..<256).map { UInt8($0) }
        let encoded = pattern.base62()
        let decoded = [UInt8](base62: encoded)
        #expect(decoded == pattern)
    }

    // MARK: - Alphabet Storage in Wrappers

    @Test("Alphabet stored in IntegerWrapper")
    func integerWrapperAlphabetStored() {
        let wrapper = 42.base62(using: .inverted)

        // Using the wrapper should use the stored alphabet
        let result = wrapper()
        #expect(result == "G")  // Inverted alphabet

        // Not "g" which would be standard
        #expect(result != "g")
    }

    @Test("Alphabet stored in StringWrapper")
    func stringWrapperAlphabetStored() {
        let wrapper = "G".base62(using: .inverted)

        // Decode should use the stored alphabet
        let result: UInt64? = try? wrapper.decode()
        #expect(result == 42)
    }

    @Test("Alphabet stored in CollectionWrapper")
    func collectionWrapperAlphabetStored() {
        let bytes: [UInt8] = [42]
        let wrapper = bytes.base62(using: .inverted)

        // Encoding should use the stored alphabet
        let result = wrapper.encoded()
        #expect(result != bytes.base62(using: .standard).encoded())
    }

    // MARK: - Cross-Alphabet Incompatibility

    @Test("Decoding with wrong alphabet fails for most values")
    func crossAlphabetIncompatibility() {
        // Encode with standard, try to decode with GMP (different meanings)
        let bytes: [UInt8] = [200, 100, 50]
        let encoded = bytes.base62(using: .standard).encoded()

        // The string might still be "valid" in GMP alphabet (same chars, different values)
        // but will decode to different bytes
        let decodedWithGmp = [UInt8](base62: encoded, using: .gmp)

        // Should decode (all chars are valid in both) but to different value
        #expect(decodedWithGmp != nil)
        #expect(decodedWithGmp != bytes)
    }

    // MARK: - Unicode Edge Cases

    @Test("High byte values in source don't crash")
    func highByteValues() {
        let bytes: [UInt8] = [0xFF, 0xFE, 0xFD]
        let encoded = bytes.base62()
        let decoded = [UInt8](base62: encoded)
        #expect(decoded == bytes)
    }

    // MARK: - Encoding Size Growth

    @Test("Encoded size is approximately 1.37x input")
    func encodingSizeGrowth() {
        // Base62 encoding grows by factor of log(256)/log(62) ≈ 1.37
        for size in [100, 500, 1000] {
            let bytes = [UInt8](repeating: 128, count: size)
            let encoded = bytes.base62()

            let ratio = Double(encoded.count) / Double(size)
            // Should be between 1.3 and 1.5
            #expect(ratio > 1.3 && ratio < 1.5, "Ratio \(ratio) out of expected range for size \(size)")
        }
    }
}
