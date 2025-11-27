//
//  UInt8.Base62.Serializing.swift
//  swift-base62-standard
//
//  Protocol for types with canonical Base62 byte-level transformations
//
//  Follows the pattern established by UInt8.ASCII.Serializing in INCITS_4_1986.
//

public import Standards

extension UInt8 {
    /// Base62 encoding namespace for protocols and types
    public enum Base62 {}
}

extension UInt8.Base62 {
    /// Protocol for types with canonical Base62 byte-level transformations
    ///
    /// Types conforming to this protocol work at the byte level as the primitive form,
    /// with string operations derived through composition.
    ///
    /// ## Philosophy
    ///
    /// This protocol captures the canonical transformation pattern for types
    /// that work at the Base62-encoded byte level.
    ///
    /// ```
    /// String → [UInt8] (UTF-8) → Type  (parsing)
    /// Type → [UInt8] (Base62) → String  (serialization)
    /// ```
    ///
    /// ## Usage
    ///
    /// Conforming types must provide:
    /// 1. `init(base62:in:)` - byte-level parsing with context
    /// 2. `static var serialize` - byte-level serialization function
    /// 3. `static var alphabet` - alphabet to use (default: `.standard`)
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct ShortID: UInt8.Base62.Serializing {
    ///     let value: UInt64
    ///
    ///     init<Bytes: Collection>(base62 bytes: Bytes, in context: Void) throws(Error) where Bytes.Element == UInt8 {
    ///         guard let decoded: UInt64 = Base62_Standard.decode(bytes, using: Self.alphabet) else {
    ///             throw .invalidFormat
    ///         }
    ///         self.value = decoded
    ///     }
    ///
    ///     static let serialize: @Sendable (Self) -> [UInt8] = {
    ///         Base62_Standard.encode($0.value, using: alphabet)
    ///     }
    /// }
    ///
    /// // Now you get for free:
    /// let id = try ShortID("abc123")  // String parsing
    /// let str = String(id)            // String conversion
    /// ```
    public protocol Serializing: UInt8.Streaming {
        /// The error type for parsing failures
        associatedtype Error: Swift.Error

        /// The context type required for parsing
        ///
        /// Use `Void` (the default) for context-free types.
        associatedtype Context: Sendable = Void

        /// Parse from canonical Base62 byte representation with context
        ///
        /// - Parameters:
        ///   - bytes: The Base62 byte representation
        ///   - context: Parsing context (use `()` for context-free types)
        /// - Throws: Self.Error if the bytes are malformed
        init<Bytes: Collection>(
            base62 bytes: Bytes,
            in context: Context
        ) throws(Error) where Bytes.Element == UInt8

        /// Serialize to canonical Base62 byte representation
        ///
        /// Unlike parsing, serialization is always context-free because
        /// the value itself contains all necessary information.
        static var serialize: @Sendable (Self) -> [UInt8] { get }

        /// The alphabet to use for encoding/decoding
        ///
        /// Defaults to `.standard`. Override to use a different alphabet.
        static var alphabet: Base62_Standard.Alphabet { get }
    }

    /// Marker protocol for RawRepresentable Base62 types
    public protocol RawRepresentable: UInt8.Base62.Serializing, Swift.RawRepresentable {}
}

// MARK: - Default Implementations

extension UInt8.Base62.Serializing {
    /// Default alphabet is standard
    public static var alphabet: Base62_Standard.Alphabet { .default }
}

// MARK: - UInt8.Streaming Default Implementation

extension UInt8.Base62.Serializing {
    /// Default `UInt8.Streaming` implementation via `static var serialize`
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: Self.serialize(self))
    }
}

// MARK: - Context-Free Convenience

extension UInt8.Base62.Serializing where Context == Void {
    /// Parse from canonical Base62 byte representation (context-free convenience)
    ///
    /// - Parameter bytes: The Base62 byte representation
    /// - Throws: Self.Error if the bytes are malformed
    public init<Bytes: Collection>(base62 bytes: Bytes) throws(Error) where Bytes.Element == UInt8 {
        try self.init(base62: bytes, in: ())
    }

    /// Parse from string representation
    ///
    /// Composes through canonical byte representation:
    /// ```
    /// String → [UInt8] (UTF-8) → Self (via init(base62:))
    /// ```
    ///
    /// - Parameter string: The string representation to parse
    /// - Throws: Self.Error if the string is malformed
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(base62: Array(string.utf8))
    }
}

// MARK: - String Conversion

extension StringProtocol {
    /// String representation of a Base62-serializable value
    ///
    /// Composes through canonical byte representation:
    /// ```
    /// Serializing → [UInt8] (Base62) → String (UTF-8 interpretation)
    /// ```
    ///
    /// - Parameter value: Any type conforming to UInt8.Base62.Serializing
    public init<T: UInt8.Base62.Serializing>(_ value: T) {
        self = Self(decoding: T.serialize(value), as: UTF8.self)
    }
}

// MARK: - CustomStringConvertible

extension UInt8.Base62.Serializing where Self: CustomStringConvertible {
    /// Default CustomStringConvertible implementation via byte serialization
    public var description: String {
        String(decoding: Self.serialize(self), as: UTF8.self)
    }
}

// MARK: - RawRepresentable Support

extension UInt8.Base62.RawRepresentable where Self.RawValue == String, Context == Void {
    /// Default RawRepresentable implementation for string-based raw values
    public init?(rawValue: String) {
        try? self.init(base62: Array(rawValue.utf8))
    }

    /// Default rawValue implementation
    public var rawValue: String {
        String(decoding: Self.serialize(self), as: UTF8.self)
    }
}

extension UInt8.Base62.RawRepresentable where Self.RawValue == [UInt8], Context == Void {
    /// Default RawRepresentable implementation for byte array raw values
    public init?(rawValue: [UInt8]) {
        try? self.init(base62: rawValue)
    }

    /// Default rawValue implementation
    public var rawValue: [UInt8] {
        Self.serialize(self)
    }
}

// MARK: - ExpressibleByStringLiteral

extension UInt8.Base62.Serializing where Self: ExpressibleByStringLiteral, Context == Void {
    /// Default ExpressibleByStringLiteral implementation
    ///
    /// **Warning**: Uses force-try. Will crash at runtime if the literal is invalid.
    public init(stringLiteral value: String) {
        // swiftlint:disable:next force_try
        try! self.init(value)
    }
}
