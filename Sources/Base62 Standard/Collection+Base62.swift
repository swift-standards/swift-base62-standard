//
//  Collection+Base62.swift
//  swift-base62-standard
//
//  Base62 extensions for byte collections
//

extension Collection where Element == UInt8 {
    /// Access to Base62 operations with default alphabet
    ///
    /// Returns a wrapper for encoding this byte collection to Base62.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]
    /// bytes.base62()                   // Base62 string
    /// bytes.base62.encoded()           // Base62 string
    /// bytes.base62.encodedBytes()      // ASCII bytes
    ///
    /// let data: Data = ...
    /// data.base62()                    // Base62 string
    ///
    /// let slice: ArraySlice<UInt8> = ...
    /// slice.base62.encoded()           // Base62 string
    /// ```
    public var base62: Base62_Standard.CollectionWrapper<Self> {
        Base62_Standard.CollectionWrapper(self)
    }

    /// Access to Base62 operations with custom alphabet
    ///
    /// - Parameter alphabet: The alphabet to use for encoding
    /// - Returns: A wrapper configured with the specified alphabet
    public func base62(using alphabet: Base62_Standard.Alphabet) -> Base62_Standard.CollectionWrapper<Self> {
        Base62_Standard.CollectionWrapper(self, alphabet: alphabet)
    }
}

// MARK: - [UInt8] Convenience Initializers

extension [UInt8] {
    /// Creates a byte array by decoding a Base62-encoded string
    ///
    /// - Parameters:
    ///   - string: Base62 encoded string to decode
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Decoded bytes, or `nil` if any character is invalid
    ///
    /// ## Usage
    ///
    /// ```swift
    /// [UInt8](base62: "4Wd")           // [72, 101]
    /// [UInt8](base62: "0")             // [0]
    /// [UInt8](base62: "")              // []
    /// [UInt8](base62: "!!")            // nil (invalid)
    /// ```
    public init?(base62 string: some StringProtocol, using alphabet: Base62_Standard.Alphabet = .default) {
        guard let decoded = Base62_Standard.decode(bytes: Array(string.utf8), using: alphabet) else {
            return nil
        }
        self = decoded
    }

    /// Creates a byte array by decoding Base62-encoded bytes
    ///
    /// - Parameters:
    ///   - bytes: Base62 encoded bytes to decode
    ///   - alphabet: Alphabet to use (default: `.standard`)
    /// - Returns: Decoded bytes, or `nil` if any byte is invalid
    public init?(base62 bytes: some Collection<UInt8>, using alphabet: Base62_Standard.Alphabet = .default) {
        guard let decoded = Base62_Standard.decode(bytes: bytes, using: alphabet) else {
            return nil
        }
        self = decoded
    }
}
