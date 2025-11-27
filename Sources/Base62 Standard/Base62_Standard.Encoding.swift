//
//  Base62_Standard.Encoding.swift
//  swift-base62-standard
//
//  Core encoding algorithms for Base62
//
//  ## Integer Encoding
//
//  Converts unsigned integers to Base62 using repeated division.
//  Complexity: O(log n) where n is the integer value.
//
//  ## Byte Array Encoding (BigInt approach)
//
//  Treats byte array as big-endian unsigned integer and converts to Base62.
//  Uses index bookkeeping to maintain O(n²) complexity.
//  Preserves leading zero bytes as leading zero digits.
//

extension Base62_Standard {
    // MARK: - Integer Encoding

    /// Encodes an unsigned integer to Base62 bytes
    ///
    /// - Parameters:
    ///   - value: The unsigned integer to encode
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Array of ASCII bytes representing the Base62 encoding
    ///
    /// ## Examples
    ///
    /// ```swift
    /// Base62_Standard.encode(0)           // [0x30] → "0"
    /// Base62_Standard.encode(61)          // [0x7A] → "z"
    /// Base62_Standard.encode(62)          // [0x31, 0x30] → "10"
    /// Base62_Standard.encode(UInt64.max)  // "LygHa16AHYF"
    /// ```
    @inlinable
    public static func encode<T: UnsignedInteger>(
        _ value: T,
        using alphabet: Alphabet = .default
    ) -> [UInt8] {
        guard value != 0 else { return [alphabet.encode(0)] }

        var result: [UInt8] = []
        result.reserveCapacity(11) // UInt64.max needs ~11 chars

        var remaining = value
        while remaining > 0 {
            let (quotient, remainder) = remaining.quotientAndRemainder(dividingBy: 62)
            result.append(alphabet.encode(UInt8(remainder)))
            remaining = quotient
        }

        result.reverse()
        return result
    }

    // MARK: - Byte Array Encoding (BigInt approach)

    /// Encodes bytes to Base62 using big-integer base conversion
    ///
    /// Treats the byte array as a big-endian unsigned integer and converts
    /// it to Base62 representation. Leading zero bytes are preserved as
    /// leading zero digits in the output.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode (interpreted as big-endian integer)
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Array of ASCII bytes representing the Base62 encoding
    ///
    /// ## Complexity
    ///
    /// O(n²) where n is the number of input bytes.
    /// Uses index bookkeeping to avoid O(n) `removeFirst()` operations.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// Base62_Standard.encode(bytes: [])           // []
    /// Base62_Standard.encode(bytes: [0])          // "0"
    /// Base62_Standard.encode(bytes: [0, 0, 1])    // "001"
    /// Base62_Standard.encode(bytes: [72, 101])    // "4Wd"
    /// ```
    public static func encode(
        bytes: some Collection<UInt8>,
        using alphabet: Alphabet = .default
    ) -> [UInt8] {
        guard !bytes.isEmpty else { return [] }

        // Count leading zeros (preserved as '0' chars)
        let leadingZeros = bytes.prefix(while: { $0 == 0 }).count
        if leadingZeros == bytes.count {
            return [UInt8](repeating: alphabet.encode(0), count: leadingZeros)
        }

        var source = Array(bytes)
        var result: [UInt8] = []
        result.reserveCapacity(bytes.count * 137 / 100 + 1) // log(256)/log(62) ≈ 1.37

        // Use index to track logical start (avoids O(n) removeFirst)
        var startIndex = 0

        // Repeated division by 62
        while startIndex < source.count {
            var remainder: UInt = 0
            var newStartIndex = source.count // Will find first non-zero

            for i in startIndex..<source.count {
                let value = UInt(source[i]) + remainder * 256
                source[i] = UInt8(value / 62)
                remainder = value % 62

                // Track first non-zero position
                if source[i] != 0 && newStartIndex == source.count {
                    newStartIndex = i
                }
            }

            result.append(alphabet.encode(UInt8(remainder)))
            startIndex = newStartIndex
        }

        // Add preserved leading zeros, then reverse
        result.append(contentsOf: [UInt8](repeating: alphabet.encode(0), count: leadingZeros))
        result.reverse()
        return result
    }
}
