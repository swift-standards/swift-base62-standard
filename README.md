# swift-base62-standard

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-standards%2Fswift-base62-standard%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swift-standards/swift-base62-standard)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-standards%2Fswift-base62-standard%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swift-standards/swift-base62-standard)
[![CI](https://github.com/swift-standards/swift-base62-standard/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-standards/swift-base62-standard/actions/workflows/ci.yml)

Base62 encoding and decoding for Swift with support for multiple alphabet variants.

## Overview

Base62 encoding uses 62 alphanumeric characters (0-9, A-Z, a-z) to represent binary data. This package provides type-safe Base62 operations for integers and byte arrays, following established swift-standards patterns.

## Features

- Integer encoding/decoding with overflow detection
- Byte array encoding/decoding with leading zero preservation
- Three predefined alphabets: standard, inverted, and GMP
- Custom alphabet support
- Fluent API via wrapper types
- Swift 6 strict concurrency support

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-base62-standard", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Base62 Standard", package: "swift-base62-standard")
    ]
)
```

## Quick Start

```swift
import Base62_Standard

// Encode integers
let encoded = 42.base62()           // "g"
let max = UInt64.max.base62()       // "LygHa16AHYF"

// Decode integers
let value = UInt64(base62Encoded: "g")  // Optional(42)

// Encode byte arrays
let bytes: [UInt8] = [72, 101, 108, 108, 111]
let base62 = bytes.base62()         // Base62 string

// Decode byte arrays
let decoded = [UInt8](base62: "4Wd") // [72, 101]
```

## Usage Examples

### Integer Encoding

```swift
// Basic encoding
42.base62()                          // "g"
42.base62.encoded()                  // "g"
42.base62.encodedBytes()             // [103] (ASCII 'g')

// Different alphabets
42.base62(using: .standard)()        // "g"
42.base62(using: .inverted)()        // "G"
42.base62(using: .gmp)()             // "q"

// String initializer
String(base62: 42)                   // "g"
String(base62: 42, using: .inverted) // "G"
```

### Integer Decoding

```swift
// Failable initializer
UInt64(base62Encoded: "g")           // Optional(42)
UInt64(base62Encoded: "abc")         // Optional(95818)
UInt64(base62Encoded: "!!")          // nil (invalid)
UInt8(base62Encoded: "ZZ")           // nil (overflow)

// Throwing decode via wrapper
let value: UInt64 = try "g".base62.decode()  // 42
```

### Byte Array Encoding

```swift
let bytes: [UInt8] = [1, 0, 0]
bytes.base62()                       // "H32" (65536 in Base62)

// Leading zeros are preserved
[0, 0, 1].base62()                   // "001"
[0].base62()                         // "0"
```

### Byte Array Decoding

```swift
[UInt8](base62: "H32")               // [1, 0, 0]
[UInt8](base62: "001")               // [0, 0, 1]
[UInt8](base62: "")                  // [] (empty)
[UInt8](base62: "!!")                // nil (invalid)
```

### String Validation

```swift
"abc123".base62()                    // Optional("abc123") - valid
"abc!".base62()                      // nil - invalid character
"abc123".base62.isValid              // true
```

### Alphabet Variants

```swift
// Standard: 0-9, A-Z, a-z (default)
10.base62(using: .standard)()        // "A"
36.base62(using: .standard)()        // "a"

// Inverted: 0-9, a-z, A-Z
10.base62(using: .inverted)()        // "a"
36.base62(using: .inverted)()        // "A"

// GMP: A-Z, a-z, 0-9
0.base62(using: .gmp)()              // "A"
52.base62(using: .gmp)()             // "0"

// Custom alphabet
let custom = Base62_Standard.Alphabet(
    characters: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
    name: "custom"
)
42.base62(using: custom)()           // "q"
```

### Single Byte Validation (INCITS Pattern)

```swift
import INCITS_4_1986

// Check if a byte is a valid Base62 digit
UInt8.ASCII.isBase62Digit(UInt8.ascii.A)  // true
UInt8.ASCII.isBase62Digit(UInt8.ascii.exclamationPoint)  // false

// Parse Base62 digit to numeric value
UInt8.ASCII.base62(digit: UInt8.ascii.A)  // 10 (standard alphabet)
UInt8.ASCII.base62(digit: UInt8.ascii.A, using: .gmp)  // 0 (GMP alphabet)
```

## Related Packages

| Package | Description |
|---------|-------------|
| [swift-incits-4-1986](https://github.com/swift-standards/swift-incits-4-1986) | ASCII character utilities per INCITS 4-1986 |
| [swift-standards](https://github.com/swift-standards/swift-standards) | Common Swift standard library extensions |

## License

Distributed under the Apache 2.0 License. See [LICENSE.md](LICENSE.md) for details.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.
