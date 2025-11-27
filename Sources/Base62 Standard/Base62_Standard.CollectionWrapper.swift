//
//  Base62_Standard.CollectionWrapper.swift
//  swift-base62-standard
//
//  Wrapper for byte collection Base62 operations
//
//  Provides encoding operations for byte arrays and collections,
//  treating them as big-endian integers for Base62 conversion.
//

extension Base62_Standard {
    /// Wrapper providing Base62 operations for byte collections
    ///
    /// Encodes byte arrays using big-integer base conversion.
    /// The bytes are treated as a big-endian unsigned integer.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]  // "Hello"
    /// bytes.base62()                                 // Base62 string
    /// bytes.base62.encoded()                         // Base62 string
    /// bytes.base62.encodedBytes()                    // ASCII bytes
    ///
    /// // Decoding (when source is Base62-encoded)
    /// let encoded: [UInt8] = Array("4Wd".utf8)
    /// encoded.base62.decoded()                       // [72, 101]
    /// ```
    public struct CollectionWrapper<Source: Collection> where Source.Element == UInt8 {
        /// The source byte collection
        public let source: Source

        /// The alphabet to use for encoding/decoding
        public let alphabet: Alphabet

        /// Creates a wrapper for the given collection and alphabet
        @usableFromInline
        internal init(_ source: Source, alphabet: Alphabet = .default) {
            self.source = source
            self.alphabet = alphabet
        }

        /// Encodes the bytes to a Base62 string using the stored alphabet
        ///
        /// Callable as a function: `bytes.base62()`
        @inlinable
        public func callAsFunction() -> String {
            encoded()
        }

        /// Encodes the bytes to a Base62 string
        ///
        /// - Returns: Base62 encoded string representation
        @inlinable
        public func encoded() -> String {
            String(decoding: Base62_Standard.encode(bytes: source, using: alphabet), as: UTF8.self)
        }

        /// Encodes the bytes to Base62 bytes
        ///
        /// - Returns: Array of ASCII bytes representing the Base62 encoding
        @inlinable
        public func encodedBytes() -> [UInt8] {
            Base62_Standard.encode(bytes: source, using: alphabet)
        }

        /// Decodes the bytes as Base62 to original bytes
        ///
        /// Treats the source bytes as Base62-encoded ASCII and decodes them.
        ///
        /// - Returns: Decoded byte array, or `nil` if any byte is invalid
        @inlinable
        public func decoded() -> [UInt8]? {
            Base62_Standard.decode(bytes: source, using: alphabet)
        }

        /// Validates that all bytes are valid Base62 characters
        ///
        /// - Returns: `true` if all bytes are valid Base62 characters
        @inlinable
        public var isValid: Bool {
            source.allSatisfy { alphabet.isValid($0) }
        }
    }
}
