//
//  Base62_Standard.Error.swift
//  swift-base62-standard
//
//  Error types for Base62 encoding/decoding operations
//

extension Base62_Standard {
    /// Errors that can occur during Base62 encoding or decoding
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Input is empty when a non-empty value is required
        ///
        /// Thrown when decoding an empty string to an integer type.
        /// Note: Empty input for byte array decoding returns `[]`, not an error.
        case empty

        /// Input contains a character not in the alphabet
        ///
        /// - Parameters:
        ///   - value: The full input string for context
        ///   - byte: The specific invalid byte encountered
        case invalidCharacter(_ value: String, byte: UInt8)

        /// Decoded value exceeds the maximum representable integer
        ///
        /// Thrown when the Base62 value is too large for the target integer type.
        case overflow
    }
}

extension Base62_Standard.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Base62 value cannot be empty"
        case .invalidCharacter(let value, let byte):
            return "Invalid Base62 byte 0x\(String(byte, radix: 16, uppercase: true)) in '\(value)'"
        case .overflow:
            return "Base62 value exceeds maximum representable integer"
        }
    }
}
