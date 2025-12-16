//
//  Base62_Standard.swift
//  swift-base62-standard
//
//  Base62 Encoding Standard
//
//  Authoritative namespace for Base62 encoding operations.
//  Supports multiple alphabet orderings and encoding modes.
//
//  ## Formal Semantics
//
//  ### Byte Array Encoding
//  1. Interpret input bytes as a **non-negative big-endian integer N**
//  2. Represent N in base-62 using the supplied alphabet's digit ordering
//  3. **Leading zero bytes** are preserved by emitting leading zero digits
//  4. Empty input produces empty output
//
//  ### Integer Encoding
//  - Special case of byte encoding where N is a fixed-width integer
//  - The integer `0` is always encoded as a single digit (alphabet position 0)
//
//  ### Decoding
//  - Integer decode of empty input returns `nil` / throws `.empty`
//  - Byte decode of empty input returns `[]` (empty array)
//  - Invalid characters cause immediate failure with `.invalidCharacter`
//
//  ## Alphabet Variants
//
//  - **standard**: 0-9, A-Z, a-z (canonical Base62 for interoperability)
//  - **inverted**: 0-9, a-z, A-Z (lowercase before uppercase)
//  - **gmp**: A-Z, a-z, 0-9 (GNU MP style)
//
//  ## Usage
//
//  ```swift
//  // Integer encoding
//  42.base62()                           // "g"
//  UInt64(base62Encoded: "abc")          // Optional(Int)
//
//  // Byte array encoding
//  bytes.base62.encoded()                // Base62 string
//  [UInt8](base62: "abc123")             // Decoded bytes
//
//  // Custom alphabet
//  42.base62(using: .inverted)()         // "G"
//  ```
//
//  Created by Claude Code on behalf of the swift-standards project.
//

import Standards

/// Base62 Encoding Standard namespace
///
/// Provides Base62 encoding and decoding operations with support for
/// multiple alphabet variants and both integer and byte-array modes.
public enum Base62_Standard {}
