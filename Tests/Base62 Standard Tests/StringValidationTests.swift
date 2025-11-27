//
//  StringValidationTests.swift
//  swift-base62-standard
//
//  Tests for string Base62 validation
//

import Testing

@testable import Base62_Standard

@Suite("String Validation Tests")
struct StringValidationTests {

    // MARK: - Valid Strings

    @Test("Valid Base62 strings pass validation")
    func validStrings() {
        #expect("abc123".base62() == "abc123")
        #expect("ABC".base62() == "ABC")
        #expect("0123456789".base62() == "0123456789")
        #expect("AaBbCc".base62() == "AaBbCc")
    }

    @Test("Empty string is valid")
    func emptyStringValid() {
        #expect("".base62()?.isEmpty == true)
        #expect("".base62.isValid)
    }

    @Test("isValid returns true for valid strings")
    func isValidTrue() {
        #expect("abc123".base62.isValid)
        #expect("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".base62.isValid)
    }

    // MARK: - Invalid Strings

    @Test("Invalid characters cause validation to fail")
    func invalidCharacters() {
        #expect("abc!".base62() == nil)
        #expect("hello world".base62() == nil)  // space
        #expect("test-123".base62() == nil)  // hyphen
        #expect("test_123".base62() == nil)  // underscore
        #expect("test@123".base62() == nil)  // at sign
    }

    @Test("isValid returns false for invalid strings")
    func isValidFalse() {
        #expect(!"abc!".base62.isValid)
        #expect(!" ".base62.isValid)
        #expect(!"-".base62.isValid)
    }

    // MARK: - Different Alphabets

    @Test("Validation respects alphabet")
    func validationRespectsAlphabet() {
        // A valid string in standard
        let standardValid = "ABCabc123"

        // All alphabets should accept alphanumeric
        #expect(standardValid.base62(using: .standard).isValid)
        #expect(standardValid.base62(using: .inverted).isValid)
        #expect(standardValid.base62(using: .gmp).isValid)
    }

    // MARK: - Unicode and Non-ASCII

    @Test("Non-ASCII characters are invalid")
    func nonAsciiInvalid() {
        #expect("café".base62() == nil)
        #expect("日本語".base62() == nil)
        #expect("emoji😀".base62() == nil)
    }

    // MARK: - StringProtocol Extension

    @Test("Substring validation works")
    func substringValidation() {
        let fullString = "abc!def"
        let validPart = fullString.prefix(3)  // "abc"

        #expect(validPart.base62() == "abc")
        #expect(validPart.base62.isValid)
    }
}
