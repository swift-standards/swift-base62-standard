//
//  UInt8.Base62.Serializable.swift
//  swift-base62-standard
//
//  Protocol for types with canonical Base62 byte-level transformations
//
//  Follows the pattern established by Binary.ASCII.Serializable in INCITS_4_1986.
//

public import Standard_Library_Extensions

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
    /// 2. `static func serialize(base62:into:)` - byte-level buffer serialization
    /// 3. `static var alphabet` - alphabet to use (default: `.standard`)
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct ShortID: UInt8.Base62.Serializable {
    ///     let value: UInt64
    ///
    ///     init<Bytes: Collection>(base62 bytes: Bytes, in context: Void) throws(Error) where Bytes.Element == UInt8 {
    ///         guard let decoded: UInt64 = Base62_Standard.decode(bytes, using: Self.alphabet) else {
    ///             throw .invalidFormat
    ///         }
    ///         self.value = decoded
    ///     }
    ///
    ///     static func serialize<Buffer: RangeReplaceableCollection>(
    ///         base62 id: Self,
    ///         into buffer: inout Buffer
    ///     ) where Buffer.Element == UInt8 {
    ///         buffer.append(contentsOf: Base62_Standard.encode(id.value, using: alphabet))
    ///     }
    /// }
    ///
    /// // Now you get for free:
    /// let id = try ShortID("abc123")  // String parsing
    /// let str = String(id)            // String conversion
    /// ```
    public protocol Serializable: Binary.Serializable {
        /// Serialize this value into a Base62 byte buffer
        ///
        /// Writes the Base62 byte representation of this value into the buffer.
        /// Implementations should append bytes without clearing existing content.
        ///
        /// ## Implementation Requirements
        ///
        /// - MUST append bytes to buffer (not replace)
        /// - MUST produce valid Base62 (alphanumeric ASCII)
        /// - MUST NOT throw (serialization is infallible for valid values)
        /// - SHOULD be deterministic (same value produces same bytes)
        ///
        /// - Parameters:
        ///   - serializable: The value to serialize
        ///   - buffer: The buffer to append bytes to
        static func serialize<Buffer: RangeReplaceableCollection>(
            base62 serializable: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == UInt8

        /// The error type for parsing failures
        associatedtype Error: Swift.Error

        /// The context type required for parsing
        ///
        /// Use `Void` (the default) for context-free types.
        /// Define a custom type for context-dependent parsing.
        associatedtype Context: Sendable = Void

        /// Parse from canonical Base62 byte representation with context
        ///
        /// This is the primary parsing requirement. Implement this method
        /// for all conforming types.
        ///
        /// - For context-free types: use `in context: Void` (or just `in _: Void`)
        /// - For context-dependent types: use your custom context type
        ///
        /// - Parameters:
        ///   - bytes: The Base62 byte representation
        ///   - context: Parsing context (use `()` for context-free types)
        /// - Throws: Self.Error if the bytes are malformed
        init<Bytes: Collection>(
            base62 bytes: Bytes,
            in context: Context
        ) throws(Error) where Bytes.Element == UInt8

        /// The alphabet to use for encoding/decoding
        ///
        /// Defaults to `.standard`. Override to use a different alphabet.
        static var alphabet: Base62_Standard.Alphabet { get }
    }

    /// Marker protocol for RawRepresentable Base62 types
    public protocol RawRepresentable: UInt8.Base62.Serializable, Swift.RawRepresentable {}
}

// MARK: - Default Implementations

extension UInt8.Base62.Serializable {
    /// Default alphabet is standard
    public static var alphabet: Base62_Standard.Alphabet { .default }
}

// MARK: - Binary.Serializable Conformance

extension UInt8.Base62.Serializable {
    /// Default `Binary.Serializable` implementation via Base62 serialization
    ///
    /// Bridges Base62 serialization to the base `Binary.Serializable` protocol.
    /// This enables Base62 types to be used anywhere `Binary.Serializable` is expected.
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        Self.serialize(base62: serializable, into: &buffer)
    }
}

// MARK: - Context-Free Convenience

extension UInt8.Base62.Serializable where Context == Void {
    /// Parse from canonical Base62 byte representation (context-free convenience)
    ///
    /// - Parameter bytes: The Base62 byte representation
    /// - Throws: Self.Error if the bytes are malformed
    public init<Bytes: Collection>(
        base62 bytes: Bytes
    ) throws(Error) where Bytes.Element == UInt8 {
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

// MARK: - Static Returning Convenience

extension UInt8.Base62.Serializable {
    /// Serialize to a new collection (static method)
    ///
    /// Creates a new buffer of the inferred type and serializes into it.
    ///
    /// - Parameter serializable: The value to serialize
    /// - Returns: A new collection containing the serialized Base62 bytes
    @inlinable
    public static func serialize<Bytes: RangeReplaceableCollection>(
        base62 serializable: Self
    ) -> Bytes where Bytes.Element == UInt8 {
        var buffer = Bytes()
        Self.serialize(base62: serializable, into: &buffer)
        return buffer
    }
}

// MARK: - Collection Initializers

extension Array where Element == UInt8 {
    /// Create a Base62 byte array from a serializable value
    ///
    /// - Parameter serializable: The Base62 serializable value
    @inlinable
    public init<S: UInt8.Base62.Serializable>(base62 serializable: S) {
        self = []
        S.serialize(base62: serializable, into: &self)
    }
}

// MARK: - String Conversion

extension StringProtocol {
    /// Create a string from a Base62 serializable value
    ///
    /// Serializes the value and interprets the bytes as UTF-8.
    ///
    /// - Parameter value: The Base62 serializable value to convert
    @inlinable
    public init<T: UInt8.Base62.Serializable>(base62 value: T) {
        let bytes: [UInt8] = T.serialize(base62: value)
        self = .init(decoding: bytes, as: UTF8.self)
    }
}

// MARK: - CustomStringConvertible

extension UInt8.Base62.Serializable where Self: CustomStringConvertible {
    /// Default CustomStringConvertible implementation via byte serialization
    @inlinable
    public var description: String {
        String(base62: self)
    }
}

extension UInt8.Base62.Serializable
where Self: RawRepresentable, Self: CustomStringConvertible, Self.RawValue: CustomStringConvertible {
    /// Optimized description for RawRepresentable types with CustomStringConvertible raw values
    @inlinable
    public var description: String {
        rawValue.description
    }
}

extension UInt8.Base62.Serializable
where Self: RawRepresentable, Self: CustomStringConvertible, Self.RawValue == [UInt8] {
    /// UTF-8 decoded description for byte-array backed types
    @inlinable
    public var description: String {
        String(decoding: rawValue, as: UTF8.self)
    }
}

// MARK: - RawRepresentable Support

extension UInt8.Base62.RawRepresentable where Self.RawValue == String, Context == Void {
    /// Default RawRepresentable implementation for string-based raw values
    @inlinable
    public init?(rawValue: String) {
        try? self.init(base62: Array(rawValue.utf8))
    }

    /// Default rawValue implementation
    @inlinable
    public var rawValue: String {
        String(base62: self)
    }
}

extension UInt8.Base62.RawRepresentable where Self.RawValue == [UInt8], Context == Void {
    /// Default RawRepresentable implementation for byte array raw values
    @inlinable
    public init?(rawValue: [UInt8]) {
        try? self.init(base62: rawValue)
    }

    /// Default rawValue implementation
    @inlinable
    public var rawValue: [UInt8] {
        [UInt8](base62: self)
    }
}

extension UInt8.Base62.Serializable where Self: Swift.RawRepresentable, Self.RawValue == [UInt8] {
    /// Default implementation for byte-array-backed types
    ///
    /// Appends the raw value directly (identity transformation).
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        base62 serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: serializable.rawValue)
    }
}

// MARK: - ExpressibleBy*Literal Support

extension UInt8.Base62.Serializable
where Self: ExpressibleByStringLiteral, Context == Void {
    /// Default ExpressibleByStringLiteral implementation
    ///
    /// **Warning**: Uses force-try. Will crash at runtime if the literal is invalid.
    @inlinable
    public init(stringLiteral value: String) {
        // swiftlint:disable:next force_try
        try! self.init(value)
    }
}

extension UInt8.Base62.Serializable where Self: ExpressibleByIntegerLiteral, Context == Void {
    /// Default ExpressibleByIntegerLiteral implementation
    ///
    /// **Warning**: Uses force-try. Will crash at runtime if the integer
    /// string representation is invalid for this type.
    @inlinable
    public init(integerLiteral value: Int) {
        // swiftlint:disable:next force_try
        try! self.init(String(value))
    }
}

extension RangeReplaceableCollection where Element == UInt8 {
    @inlinable
    public mutating func append<Serializable: UInt8.Base62.Serializable>(
        base62 serializable: Serializable
    ) {
        Serializable.serialize(base62: serializable, into: &self)
    }
}

// MARK: - Base62 Serialization Wrapper

extension UInt8.Base62 {
    /// Wrapper for Base62 serializable types
    ///
    /// Provides instance-level access to Base62 serialization methods.
    /// This wrapper enables the syntax `value.base62.serialize(into:)` for types
    /// that have both binary and Base62 serializations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // For types with both binary and Base62 serialization:
    /// let id = try ShortID("abc123")
    ///
    /// var binaryBuffer: [UInt8] = []
    /// id.serialize(into: &binaryBuffer)  // Binary representation
    ///
    /// var base62Buffer: [UInt8] = []
    /// id.base62.serialize(into: &base62Buffer)  // Base62: "abc123"
    /// ```
    public struct Wrapper<Wrapped: UInt8.Base62.Serializable>: Sendable where Wrapped: Sendable {
        /// The wrapped value
        public let wrapped: Wrapped

        /// Creates a wrapper around the given value
        @inlinable
        init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}

// MARK: - Wrapper Serialization Methods

extension UInt8.Base62.Wrapper {
    /// Serialize the wrapped value into a Base62 byte buffer
    ///
    /// - Parameter buffer: The buffer to append Base62 bytes to
    @inlinable
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        Wrapped.serialize(base62: wrapped, into: &buffer)
    }

    /// Serialize to a new Base62 byte array
    ///
    /// - Returns: A new `[UInt8]` containing the Base62 representation
    @inlinable
    public var bytes: [UInt8] {
        var buffer: [UInt8] = []
        serialize(into: &buffer)
        return buffer
    }
}

extension UInt8.Base62.Wrapper: CustomStringConvertible {
    /// The Base62 string representation
    @inlinable
    public var description: String {
        String(decoding: bytes, as: UTF8.self)
    }
}

// MARK: - Serializable Extension

extension UInt8.Base62.Serializable where Self: Sendable {
    /// Access Base62 serialization wrapper
    ///
    /// Returns a wrapper that provides instance-level access to Base62 serialization.
    /// Use this when the type has both binary and Base62 serializations, and you need
    /// to explicitly select Base62 serialization.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let id = try ShortID("abc123")
    ///
    /// // Binary serialization
    /// var binary: [UInt8] = []
    /// id.serialize(into: &binary)
    ///
    /// // Base62 serialization
    /// var base62: [UInt8] = []
    /// id.base62.serialize(into: &base62)
    /// ```
    @inlinable
    public var base62: UInt8.Base62.Wrapper<Self> {
        UInt8.Base62.Wrapper(self)
    }
}
