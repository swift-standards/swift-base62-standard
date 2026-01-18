//
//  ErrorTests.swift
//  swift-base62-standard
//
//  Tests for Base62 error types
//

import Testing

@testable import Base62_Standard

@Suite("Error Tests")
struct ErrorTests {

    // MARK: - Error Descriptions

    @Test("Empty error has correct description")
    func emptyErrorDescription() {
        let error = Base62_Standard.Error.empty
        #expect(error.description == "Base62 value cannot be empty")
    }

    @Test("Invalid character error has correct description")
    func invalidCharacterErrorDescription() {
        let error = Base62_Standard.Error.invalidCharacter("abc!", byte: UInt8(ascii: "!"))
        #expect(error.description.contains("abc!"))
        #expect(error.description.contains("21"))  // hex for '!'
    }

    @Test("Overflow error has correct description")
    func overflowErrorDescription() {
        let error = Base62_Standard.Error.overflow
        #expect(error.description == "Base62 value exceeds maximum representable integer")
    }

    // MARK: - Error Equatable

    @Test("Errors are equatable")
    func errorsEquatable() {
        #expect(Base62_Standard.Error.empty == Base62_Standard.Error.empty)
        #expect(Base62_Standard.Error.overflow == Base62_Standard.Error.overflow)

        let invalid1 = Base62_Standard.Error.invalidCharacter("abc", byte: 33)
        let invalid2 = Base62_Standard.Error.invalidCharacter("abc", byte: 33)
        let invalid3 = Base62_Standard.Error.invalidCharacter("xyz", byte: 33)

        #expect(invalid1 == invalid2)
        #expect(invalid1 != invalid3)
    }

    // MARK: - Error Throwing

    @Test("Empty input throws empty error")
    func emptyThrowsEmptyError() {
        #expect(throws: Base62_Standard.Error.empty) {
            let _: UInt64 = try "".base62.decode()
        }
    }

    @Test("Invalid character throws invalidCharacter error")
    func invalidCharacterThrowsError() {
        do {
            let _: UInt64 = try "abc!def".base62.decode()
            Issue.record("Should have thrown")
        } catch let error as Base62_Standard.Error {
            if case .invalidCharacter(_, let byte) = error {
                #expect(byte == UInt8(ascii: "!"))
            } else {
                Issue.record("Wrong error case")
            }
        } catch {
            Issue.record("Wrong error type")
        }
    }

    @Test("Overflow throws overflow error")
    func overflowThrowsOverflowError() {
        #expect(throws: Base62_Standard.Error.overflow) {
            // This value is too large for UInt8
            let _: UInt8 = try "ZZ".base62.decode()
        }
    }
}
