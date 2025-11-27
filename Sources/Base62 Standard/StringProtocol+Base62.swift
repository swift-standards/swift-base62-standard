//
//  StringProtocol+Base62.swift
//  swift-base62-standard
//
//  Base62 extensions for string types
//

extension StringProtocol {
    /// Access to Base62 validation and decoding with default alphabet
    ///
    /// Returns a wrapper for validating and decoding Base62-encoded strings.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Validation
    /// "abc123".base62()                      // "abc123" (valid)
    /// "abc!".base62()                        // nil (invalid)
    /// "abc123".base62.isValid                // true
    ///
    /// // Decoding
    /// "g".base62.decode(as: UInt64.self)     // 42
    /// "4Wd".base62.decodeBytes()             // [72, 101]
    /// ```
    public var base62: Base62_Standard.StringWrapper<Self> {
        Base62_Standard.StringWrapper(self)
    }

    /// Access to Base62 validation and decoding with custom alphabet
    ///
    /// - Parameter alphabet: The alphabet to use for validation/decoding
    /// - Returns: A wrapper configured with the specified alphabet
    ///
    /// ## Usage
    ///
    /// ```swift
    /// "G".base62(using: .inverted).decode(as: UInt64.self)  // 42
    /// ```
    public func base62(using alphabet: Base62_Standard.Alphabet) -> Base62_Standard.StringWrapper<Self> {
        Base62_Standard.StringWrapper(self, alphabet: alphabet)
    }
}

extension String {
    /// Creates a string from a Base62-encoded integer
    ///
    /// - Parameters:
    ///   - value: Integer value to encode
    ///   - alphabet: Alphabet to use (default: `.standard`)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// String(base62: 42)                     // "g"
    /// String(base62: 42, using: .inverted)   // "G"
    /// String(base62: UInt64.max)             // "LygHa16AHYF"
    /// ```
    public init<T: BinaryInteger>(base62 value: T, using alphabet: Base62_Standard.Alphabet = .default) where T.Magnitude: UnsignedInteger {
        self = value.base62(using: alphabet).encoded()
    }

    /// Creates a string from Base62-encoded bytes
    ///
    /// - Parameters:
    ///   - bytes: Bytes to encode
    ///   - alphabet: Alphabet to use (default: `.standard`)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// String(base62: [72, 101, 108, 108, 111])  // Base62 of "Hello"
    /// ```
    public init(base62 bytes: some Collection<UInt8>, using alphabet: Base62_Standard.Alphabet = .default) {
        self = String(decoding: Base62_Standard.encode(bytes: bytes, using: alphabet), as: UTF8.self)
    }
}
