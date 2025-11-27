//
//  Base62_Standard.IntegerWrapper.swift
//  swift-base62-standard
//
//  Wrapper for integer Base62 operations
//
//  Stores the alphabet so that `42.base62(using: .inverted)()` works correctly.
//

extension Base62_Standard {
    /// Wrapper providing Base62 operations for integer values
    ///
    /// Stores both the value and the alphabet to ensure consistent encoding
    /// when chaining operations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// 42.base62()                        // "g"
    /// 42.base62.encoded()                // "g"
    /// 42.base62(using: .inverted)()      // "G"
    /// 42.base62.encodedBytes()           // [0x67]
    /// ```
    public struct IntegerWrapper<T: BinaryInteger> where T.Magnitude: UnsignedInteger {
        /// The integer value to encode
        public let value: T

        /// The alphabet to use for encoding
        public let alphabet: Alphabet

        /// Creates a wrapper for the given integer and alphabet
        @usableFromInline
        internal init(_ value: T, alphabet: Alphabet = .default) {
            self.value = value
            self.alphabet = alphabet
        }

        /// Encodes the integer to a Base62 string using the stored alphabet
        ///
        /// Callable as a function: `42.base62()`
        @inlinable
        public func callAsFunction() -> String {
            encoded()
        }

        /// Encodes the integer to a Base62 string
        ///
        /// - Returns: Base62 encoded string representation
        @inlinable
        public func encoded() -> String {
            String(decoding: Base62_Standard.encode(value.magnitude, using: alphabet), as: UTF8.self)
        }

        /// Encodes the integer to Base62 bytes
        ///
        /// - Returns: Array of ASCII bytes representing the Base62 encoding
        @inlinable
        public func encodedBytes() -> [UInt8] {
            Base62_Standard.encode(value.magnitude, using: alphabet)
        }
    }
}
