//
//  Base62_Standard.StringWrapper.swift
//  swift-base62-standard
//
//  Wrapper for string Base62 operations
//
//  **Note**: `callAsFunction()` validates and returns the original string,
//  not an encoding. Use `.decodeBytes()` to decode Base62 to bytes.
//

extension Base62_Standard {
    /// Wrapper providing Base62 operations for string values
    ///
    /// Treats the source string as a Base62-encoded value for validation
    /// and decoding operations.
    ///
    /// ## Important
    ///
    /// `callAsFunction()` is a **validation operation**, not encoding.
    /// It returns the original string if all characters are valid Base62,
    /// or `nil` if any character is invalid.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Validation
    /// "abc123".base62()                        // "abc123" (valid)
    /// "abc!".base62()                          // nil (invalid character)
    /// "abc123".base62.isValid                  // true
    ///
    /// // Decoding
    /// "g".base62.decode(as: UInt64.self)       // 42
    /// "4Wd".base62.decodeBytes()               // [72, 101]
    /// ```
    public struct StringWrapper<S: StringProtocol> {
        /// The source string (assumed to be Base62-encoded)
        public let source: S

        /// The alphabet to use for validation and decoding
        public let alphabet: Alphabet

        /// Creates a wrapper for the given string and alphabet
        @usableFromInline
        internal init(_ source: S, alphabet: Alphabet = .default) {
            self.source = source
            self.alphabet = alphabet
        }

        /// Returns source string if all characters are valid Base62, nil otherwise
        ///
        /// **Note**: This is validation, not encoding. Returns original string if valid.
        ///
        /// - Returns: The source string if valid, `nil` if any character is invalid
        @inlinable
        public func callAsFunction() -> S? {
            isValid ? source : nil
        }

        /// Returns `true` if all characters are valid Base62 in the stored alphabet
        @inlinable
        public var isValid: Bool {
            source.utf8.allSatisfy { alphabet.isValid($0) }
        }

//        /// Decodes the Base62 string to an unsigned integer
//        ///
//        /// - Parameter type: Target integer type (can be inferred)
//        /// - Returns: Decoded integer, or `nil` if invalid or overflow
//        @inlinable
//        public func decode<T: UnsignedInteger & FixedWidthInteger>(
//            as type: T.Type = T.self
//        ) -> T? {
//            Base62_Standard.decode(Array(source.utf8), as: type, using: alphabet)
//        }

        /// Decodes the Base62 string to an unsigned integer with detailed errors
        ///
        /// - Parameter type: Target integer type (can be inferred)
        /// - Returns: Decoded integer
        /// - Throws: `Base62_Standard.Error` if decoding fails
        @inlinable
        public func decode<T: UnsignedInteger & FixedWidthInteger>(
            as type: T.Type = T.self
        ) throws(Base62_Standard.Error) -> T {
            try Base62_Standard.decode(Array(source.utf8), as: type, using: alphabet)
        }

        /// Decodes the Base62 string to bytes
        ///
        /// - Returns: Decoded byte array, or `nil` if any character is invalid
        @inlinable
        public func decodeBytes() -> [UInt8]? {
            Base62_Standard.decode(bytes: Array(source.utf8), using: alphabet)
        }
    }
}
