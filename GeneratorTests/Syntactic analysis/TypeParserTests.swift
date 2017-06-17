//
//  TypeParserTests.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 23/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import XCTest
import Generator

class TypeParserTests: XCTestCase {

    func makeParser(storage: Storage) -> TypeParser {
        return TypeParser(storage: storage)
    }

    func test_givenColonToken_whenParse_thenThrowException() throws {
        let storage = try Storage(tokens: [.colon])
        let parser = makeParser(storage: storage)

        testException(with: TypeParserError.invalidName) {
            _ = try parser.parse()
        }
    }

    func test_givenNameToken_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.identifier(name: "x")])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "x")
            XCTAssertEqual(type.isOptional, false)
        } catch {
            XCTFail()
        }
    }

    func test_givenNameColonTokens_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.identifier(name: "x"), .colon])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "x")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenNameQuestionMarkTokens_whenParse_thenParse() throws {
        let storage = try Storage(tokens: [.identifier(name: "x"), .questionMark, .colon])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "x")
            XCTAssertEqual(type.isOptional, true)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenArrayTypeWithInvalidName_whenParse_thenExceptionIsThrown() throws {
        let storage = try Storage(tokens: [.leftSquareBracket, .arrow, .identifier(name: "A"), .colon])
        let parser = makeParser(storage: storage)

        testException(with: TypeParserError.invalidName) {
            _ = try parser.parse()
        }
    }

    func test_givenArrayTypeWithoutEndingBracket_whenParse_thenExceptionIsThrown() throws {
        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "A"), .colon])
        let parser = makeParser(storage: storage)

        testException(with: TypeParserError.missingEndingBracket) {
            _ = try parser.parse()
        }
    }

    func test_givenArrayType_whenParse_thenArrayIsParsed() throws {
        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "x"), .rightSquareBracket, .colon])
        let parser = makeParser(storage: storage)
        
        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "[x]")
            XCTAssertEqual(type.isOptional, false)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }

    func test_givenOptionalArrayType_whenParse_thenArrayIsParsed() throws {
        let storage = try Storage(tokens: [.leftSquareBracket, .identifier(name: "x"), .questionMark, .rightSquareBracket, .questionMark, .colon])
        let parser = makeParser(storage: storage)

        do {
            let type = try parser.parse()
            XCTAssertEqual(type.name, "[x?]")
            XCTAssertEqual(type.isOptional, true)
            XCTAssertEqual(storage.current, .colon)
        } catch {
            XCTFail()
        }
    }
}
