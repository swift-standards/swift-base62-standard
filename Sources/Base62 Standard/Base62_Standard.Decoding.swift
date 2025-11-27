//
//  Base62_Standard.Decoding.swift
//  swift-base62-standard
//
//  Core decoding algorithms for Base62
//
//  ## Integer Decoding
//
//  Converts Base62 to unsigned integers using Horner's method.
//  Includes overflow detection for fixed-width integers.
//
//  ## Byte Array Decoding (BigInt approach)
//
//  Reconstructs the original byte array from Base62.
//  Builds result in little-endian order, then reverses once.
//  Preserves leading zero digits as leading zero bytes.
//

extension Base62_Standard {
    // MARK: - Integer Decoding (Optional result)

    /// Decodes Base62 bytes to an unsigned integer
    ///
    /// - Parameters:
    ///   - bytes: Base62 encoded bytes to decode
    ///   - type: Target integer type (inferred if not specified)
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Decoded integer, or `nil` if input is empty, invalid, or overflows
    ///
    /// ## Examples
    ///
    /// ```swift
    /// Base62_Standard.decode([0x67], as: UInt8.self)     // 42 ("g")
    /// Base62_Standard.decode([0x7A], as: UInt8.self)     // 61 ("z")
    /// Base62_Standard.decode([], as: UInt64.self)        // nil (empty)
    /// Base62_Standard.decode([0x21], as: UInt64.self)    // nil (invalid)
    /// ```
    @inlinable
    public static func decode<T: UnsignedInteger & FixedWidthInteger>(
        _ bytes: some Collection<UInt8>,
        as type: T.Type = T.self,
        using alphabet: Alphabet = .default
    ) -> T? {
        guard !bytes.isEmpty else { return nil }

        var result: T = 0
        for byte in bytes {
            guard let value = alphabet.decode(byte) else { return nil }

            let (multiplied, overflow1) = result.multipliedReportingOverflow(by: 62)
            guard !overflow1 else { return nil }

            let (added, overflow2) = multiplied.addingReportingOverflow(T(value))
            guard !overflow2 else { return nil }

            result = added
        }
        return result
    }

    // MARK: - Integer Decoding (Throwing)

    /// Decodes Base62 bytes to an unsigned integer with detailed errors
    ///
    /// - Parameters:
    ///   - bytes: Base62 encoded bytes to decode
    ///   - type: Target integer type (inferred if not specified)
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Decoded integer
    /// - Throws: `Base62_Standard.Error` if decoding fails
    ///
    /// ## Errors
    ///
    /// - `.empty`: Input is empty
    /// - `.invalidCharacter`: Input contains non-Base62 character
    /// - `.overflow`: Decoded value exceeds target type's range
    public static func decode<T: UnsignedInteger & FixedWidthInteger>(
        _ bytes: some Collection<UInt8>,
        as type: T.Type = T.self,
        using alphabet: Alphabet = .default
    ) throws(Error) -> T {
        guard !bytes.isEmpty else { throw .empty }

        var result: T = 0
        for byte in bytes {
            guard let value = alphabet.decode(byte) else {
                throw .invalidCharacter(String(decoding: Array(bytes), as: UTF8.self), byte: byte)
            }

            let (multiplied, overflow1) = result.multipliedReportingOverflow(by: 62)
            guard !overflow1 else { throw .overflow }

            let (added, overflow2) = multiplied.addingReportingOverflow(T(value))
            guard !overflow2 else { throw .overflow }

            result = added
        }
        return result
    }

    // MARK: - Byte Array Decoding

    /// Decodes Base62 bytes to original byte array
    ///
    /// Reconstructs the original byte array from Base62 encoding.
    /// Leading zero digits are preserved as leading zero bytes.
    ///
    /// - Parameters:
    ///   - bytes: Base62 encoded bytes to decode
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Decoded byte array, or `nil` if input contains invalid characters
    ///
    /// ## Complexity
    ///
    /// O(n²) where n is the number of input characters.
    /// Builds result in little-endian order and reverses once at the end.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// Base62_Standard.decode(bytes: [])           // [] (empty)
    /// Base62_Standard.decode(bytes: [0x30])       // [0] ("0")
    /// Base62_Standard.decode(bytes: [0x34, 0x57, 0x64])  // [72, 101] ("4Wd")
    /// ```
    public static func decode(
        bytes: some Collection<UInt8>,
        using alphabet: Alphabet = .default
    ) -> [UInt8]? {
        guard !bytes.isEmpty else { return [] }

        // Count leading zero digits
        let zeroDigit = alphabet.encode(0)
        let leadingZeros = bytes.prefix(while: { $0 == zeroDigit }).count
        if leadingZeros == bytes.count {
            return [UInt8](repeating: 0, count: leadingZeros)
        }

        // Build result in little-endian order (LSB first), reverse at end
        var result: [UInt8] = []
        result.reserveCapacity(bytes.count * 75 / 100 + 1)  // log(62)/log(256) ≈ 0.74

        for byte in bytes {
            guard let digitValue = alphabet.decode(byte) else { return nil }

            // Multiply existing result by 62 and add new digit
            var carry = UInt(digitValue)
            for i in 0..<result.count {
                let value = UInt(result[i]) * 62 + carry
                result[i] = UInt8(value & 0xFF)
                carry = value >> 8
            }

            // Extend with carry bytes (appending is O(1) amortized)
            while carry > 0 {
                result.append(UInt8(carry & 0xFF))
                carry >>= 8
            }
        }

        // Reverse to big-endian, then prepend leading zeros
        result.reverse()
        if leadingZeros > 0 {
            result.insert(contentsOf: [UInt8](repeating: 0, count: leadingZeros), at: 0)
        }
        return result
    }
}
