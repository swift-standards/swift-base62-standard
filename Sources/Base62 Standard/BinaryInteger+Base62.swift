//
//  BinaryInteger+Base62.swift
//  swift-base62-standard
//
//  Base62 extensions for all integer types
//

extension BinaryInteger where Self.Magnitude: UnsignedInteger {
    /// Access to Base62 operations with default alphabet
    ///
    /// Returns a wrapper that provides encoding operations for this integer.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// 42.base62()                     // "g"
    /// 42.base62.encoded()             // "g"
    /// 42.base62.encodedBytes()        // [0x67]
    /// UInt64.max.base62()             // "LygHa16AHYF"
    /// ```
    public var base62: Base62_Standard.IntegerWrapper<Self> {
        Base62_Standard.IntegerWrapper(self)
    }

    /// Access to Base62 operations with custom alphabet
    ///
    /// Returns a wrapper configured with the specified alphabet.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// 42.base62(using: .inverted)()   // "G"
    /// 42.base62(using: .gmp)()        // "Q"
    /// ```
    ///
    /// - Parameter alphabet: The alphabet to use for encoding
    /// - Returns: A wrapper configured with the specified alphabet
    public func base62(using alphabet: Base62_Standard.Alphabet) -> Base62_Standard.IntegerWrapper<Self> {
        Base62_Standard.IntegerWrapper(self, alphabet: alphabet)
    }
}

extension FixedWidthInteger where Self: UnsignedInteger {
    /// Creates an unsigned integer from a Base62-encoded string
    ///
    /// - Parameters:
    ///   - string: Base62 encoded string to decode
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Decoded integer, or `nil` if invalid or overflow
    ///
    /// ## Usage
    ///
    /// ```swift
    /// UInt64(base62Encoded: "g")      // 42
    /// UInt64(base62Encoded: "abc")    // 95818
    /// UInt64(base62Encoded: "!!")     // nil (invalid)
    /// UInt8(base62Encoded: "ZZ")      // nil (overflow)
    /// ```
    public init?(base62Encoded string: some StringProtocol, using alphabet: Base62_Standard.Alphabet = .default) {
        guard let value: Self = Base62_Standard.decode(Array(string.utf8), using: alphabet) else {
            return nil
        }
        self = value
    }

    /// Creates an unsigned integer from Base62-encoded bytes
    ///
    /// - Parameters:
    ///   - bytes: Base62 encoded bytes to decode
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Decoded integer, or `nil` if invalid or overflow
    public init?(base62Encoded bytes: some Collection<UInt8>, using alphabet: Base62_Standard.Alphabet = .default) {
        guard let value: Self = Base62_Standard.decode(bytes, using: alphabet) else {
            return nil
        }
        self = value
    }
}
