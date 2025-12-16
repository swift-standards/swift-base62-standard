//
//  Base62_Standard.Alphabet.swift
//  swift-base62-standard
//
//  Base62 alphabet configuration with encode/decode lookup tables
//
//  Supports predefined alphabets and custom 62-character sets.
//  Uses direct table lookup for O(1) encode/decode operations.
//  No closure overhead - tables stored directly with @inlinable methods.
//

import INCITS_4_1986

extension Base62_Standard {
    /// Base62 alphabet configuration with encode/decode lookup tables
    ///
    /// Each alphabet defines a bijective mapping between:
    /// - Digit values 0-61 (internal representation)
    /// - ASCII bytes (external representation)
    ///
    /// ## Predefined Alphabets
    ///
    /// - `.standard`: 0-9, A-Z, a-z (canonical, most common)
    /// - `.inverted`: 0-9, a-z, A-Z (lowercase before uppercase)
    /// - `.gmp`: A-Z, a-z, 0-9 (GNU MP style)
    ///
    /// ## Custom Alphabets
    ///
    /// ```swift
    /// let custom = Base62_Standard.Alphabet(
    ///     characters: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
    ///     name: "custom"
    /// )
    /// ```
    public struct Alphabet: Sendable, Hashable {
        /// Encoding lookup: maps value (0-61) to ASCII byte
        public let encodeTable: [UInt8]

        /// Decoding lookup: maps ASCII byte (0-255) to value, 255 = invalid
        public let decodeTable: [UInt8]

        /// Human-readable name for this alphabet
        public let name: String

        /// Creates alphabet from a 62-character string
        ///
        /// - Parameters:
        ///   - characters: Exactly 62 unique ASCII characters
        ///   - name: Human-readable name for identification
        ///
        /// - Precondition: `characters` must contain exactly 62 unique ASCII characters
        public init(characters: String, name: String) {
            let bytes = Array(characters.utf8)
            precondition(bytes.count == 62, "Alphabet must contain exactly 62 characters")
            precondition(Set(bytes).count == 62, "Alphabet must contain 62 unique characters")

            self.encodeTable = bytes
            self.name = name

            // Build decode table
            var decode = [UInt8](repeating: 255, count: 256)
            for (index, byte) in bytes.enumerated() {
                decode[Int(byte)] = UInt8(index)
            }
            self.decodeTable = decode
        }

        /// Creates alphabet from pre-computed tables
        ///
        /// Internal initializer for static alphabet construction.
        @usableFromInline
        internal init(encodeTable: [UInt8], decodeTable: [UInt8], name: String) {
            self.encodeTable = encodeTable
            self.decodeTable = decodeTable
            self.name = name
        }

        /// Encodes a digit value (0-61) to its ASCII character
        ///
        /// - Parameter value: Digit value in range 0-61
        /// - Returns: ASCII byte representation
        ///
        /// - Precondition: `value` must be in range 0-61
        @inlinable
        public func encode(_ value: UInt8) -> UInt8 {
            encodeTable[Int(value)]
        }

        /// Decodes an ASCII byte to its digit value (0-61)
        ///
        /// - Parameter byte: ASCII byte to decode
        /// - Returns: Digit value, or `nil` if byte is not in alphabet
        @inlinable
        public func decode(_ byte: UInt8) -> UInt8? {
            let value = decodeTable[Int(byte)]
            return value == 255 ? nil : value
        }

        /// Returns true if byte is a valid character in this alphabet
        ///
        /// - Parameter byte: ASCII byte to validate
        /// - Returns: `true` if byte is a valid Base62 character
        @inlinable
        public func isValid(_ byte: UInt8) -> Bool {
            decodeTable[Int(byte)] != 255
        }
    }
}

// MARK: - Predefined Alphabets

extension Base62_Standard.Alphabet {
    /// Standard alphabet: 0-9, A-Z, a-z
    ///
    /// This is the **canonical Base62 alphabet** for interoperability.
    /// Most common ordering used by URL shorteners and unique ID generators.
    ///
    /// Character mapping:
    /// - 0-9 → values 0-9
    /// - A-Z → values 10-35
    /// - a-z → values 36-61
    public static let standard: Base62_Standard.Alphabet = {
        var encode: [UInt8] = []
        encode.reserveCapacity(62)

        // Digits 0-9
        for byte in UInt8.ascii.`0`...UInt8.ascii.`9` {
            encode.append(byte)
        }
        // Uppercase A-Z
        for byte in UInt8.ascii.A...UInt8.ascii.Z {
            encode.append(byte)
        }
        // Lowercase a-z
        for byte in UInt8.ascii.a...UInt8.ascii.z {
            encode.append(byte)
        }

        var decode = [UInt8](repeating: 255, count: 256)
        for (index, byte) in encode.enumerated() {
            decode[Int(byte)] = UInt8(index)
        }

        return Self(encodeTable: encode, decodeTable: decode, name: "standard")
    }()

    /// Inverted alphabet: 0-9, a-z, A-Z
    ///
    /// Lowercase letters precede uppercase letters.
    /// Used by some implementations that prefer lowercase.
    ///
    /// Character mapping:
    /// - 0-9 → values 0-9
    /// - a-z → values 10-35
    /// - A-Z → values 36-61
    public static let inverted: Base62_Standard.Alphabet = {
        var encode: [UInt8] = []
        encode.reserveCapacity(62)

        // Digits 0-9
        for byte in UInt8.ascii.`0`...UInt8.ascii.`9` {
            encode.append(byte)
        }
        // Lowercase a-z
        for byte in UInt8.ascii.a...UInt8.ascii.z {
            encode.append(byte)
        }
        // Uppercase A-Z
        for byte in UInt8.ascii.A...UInt8.ascii.Z {
            encode.append(byte)
        }

        var decode = [UInt8](repeating: 255, count: 256)
        for (index, byte) in encode.enumerated() {
            decode[Int(byte)] = UInt8(index)
        }

        return Self(encodeTable: encode, decodeTable: decode, name: "inverted")
    }()

    /// GMP alphabet: A-Z, a-z, 0-9
    ///
    /// GNU Multiple Precision Arithmetic Library style.
    /// Letters precede digits.
    ///
    /// Character mapping:
    /// - A-Z → values 0-25
    /// - a-z → values 26-51
    /// - 0-9 → values 52-61
    public static let gmp: Base62_Standard.Alphabet = {
        var encode: [UInt8] = []
        encode.reserveCapacity(62)

        // Uppercase A-Z
        for byte in UInt8.ascii.A...UInt8.ascii.Z {
            encode.append(byte)
        }
        // Lowercase a-z
        for byte in UInt8.ascii.a...UInt8.ascii.z {
            encode.append(byte)
        }
        // Digits 0-9
        for byte in UInt8.ascii.`0`...UInt8.ascii.`9` {
            encode.append(byte)
        }

        var decode = [UInt8](repeating: 255, count: 256)
        for (index, byte) in encode.enumerated() {
            decode[Int(byte)] = UInt8(index)
        }

        return Self(encodeTable: encode, decodeTable: decode, name: "gmp")
    }()

    /// Default alphabet (standard)
    ///
    /// Returns `.standard` alphabet for use when no alphabet is specified.
    public static var `default`: Base62_Standard.Alphabet { .standard }
}
