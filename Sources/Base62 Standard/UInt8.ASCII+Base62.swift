//
//  Binary.ASCII+Base62.swift
//  swift-base62-standard
//
//  Base62 digit parsing following INCITS_4_1986 patterns
//
//  Uses static methods on Binary.ASCII to avoid conflicts with
//  BinaryInteger.base62 (which returns IntegerWrapper).
//

public import INCITS_4_1986

extension Binary.ASCII {
    // MARK: - Base62 Digit Parsing

    /// Parses a Base62 digit byte to its numeric value (0-61)
    ///
    /// Pure function transformation from Base62 digit to numeric value.
    /// Similar to `ascii(digit:)` for decimal and `ascii(hexDigit:)` for hex.
    ///
    /// The standard Base62 alphabet maps:
    /// - '0'...'9' → 0...9
    /// - 'A'...'Z' → 10...35
    /// - 'a'...'z' → 36...61
    ///
    /// ## Usage
    ///
    /// ```swift
    /// Binary.ASCII.base62(digit: UInt8.ascii.`0`)  // 0
    /// Binary.ASCII.base62(digit: UInt8.ascii.`9`)  // 9
    /// Binary.ASCII.base62(digit: UInt8.ascii.A)    // 10
    /// Binary.ASCII.base62(digit: UInt8.ascii.Z)    // 35
    /// Binary.ASCII.base62(digit: UInt8.ascii.a)    // 36
    /// Binary.ASCII.base62(digit: UInt8.ascii.z)    // 61
    /// Binary.ASCII.base62(digit: UInt8.ascii.exclamationPoint)  // nil
    /// ```
    ///
    /// ## Different Alphabets
    ///
    /// ```swift
    /// // GMP alphabet: A-Z, a-z, 0-9
    /// Binary.ASCII.base62(digit: UInt8.ascii.A, using: .gmp)    // 0
    /// Binary.ASCII.base62(digit: UInt8.ascii.`0`, using: .gmp)  // 52
    ///
    /// // Inverted alphabet: 0-9, a-z, A-Z
    /// Binary.ASCII.base62(digit: UInt8.ascii.a, using: .inverted)  // 10
    /// Binary.ASCII.base62(digit: UInt8.ascii.A, using: .inverted)  // 36
    /// ```
    ///
    /// - Parameters:
    ///   - byte: The ASCII byte representing a Base62 digit
    ///   - alphabet: The alphabet to use (default: `.default` which is `.standard`)
    /// - Returns: The digit value (0-61), or `nil` if byte is not a valid Base62 digit
    ///
    /// ## See Also
    ///
    /// - ``isBase62Digit(_:using:)``
    /// - ``Base62_Standard/Alphabet``
    @inlinable
    public static func base62(digit byte: UInt8, using alphabet: Base62_Standard.Alphabet = .default) -> UInt8? {
        alphabet.decode(byte)
    }

    /// Returns true if byte is a valid Base62 digit character
    ///
    /// Tests whether an ASCII byte is a valid digit in the specified Base62 alphabet.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// Binary.ASCII.isBase62Digit(UInt8.ascii.A)                 // true
    /// Binary.ASCII.isBase62Digit(UInt8.ascii.exclamationPoint)  // false
    /// Binary.ASCII.isBase62Digit(UInt8.ascii.hyphen)            // false
    /// ```
    ///
    /// - Parameters:
    ///   - byte: The ASCII byte to test
    ///   - alphabet: The alphabet to use (default: `.default` which is `.standard`)
    /// - Returns: `true` if the byte is valid in the specified alphabet
    ///
    /// ## See Also
    ///
    /// - ``base62(digit:using:)``
    @inlinable
    public static func isBase62Digit(_ byte: UInt8, using alphabet: Base62_Standard.Alphabet = .default) -> Bool {
        alphabet.isValid(byte)
    }
}
