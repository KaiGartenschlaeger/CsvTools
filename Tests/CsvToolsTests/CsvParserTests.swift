//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 07.01.21.
//

import XCTest
@testable import CsvTools

final class CsvParserTests: XCTestCase {

    func testNormal() {
        let parser = CsvParser(text: "Field 1,Field 2")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "Field 1")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "Field 2")
    }

    func testNormalMultipleLines() {
        let parser = CsvParser(text: "Field 1.1,Field 2.1\nField 1.2,Field 2.2")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 2)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "Field 1.1")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "Field 2.1")
        XCTAssertEqual(result.getValue(forRow: 1, withFieldIndex: 0), "Field 1.2")
        XCTAssertEqual(result.getValue(forRow: 1, withFieldIndex: 1), "Field 2.2")
    }

    func testCommaOnly1Time() {
        let parser = CsvParser(text: ",")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(2, result.columnsCount)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "")
    }

    func testCommaOnly2Times() {
        let parser = CsvParser(text: ",,")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(3, result.columnsCount)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 2), "")
    }

    func testCommaOnlyWithLineBreak() {
        let parser = CsvParser(text: ",,\n,")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 2)
        XCTAssertEqual(3, result.columnsCount)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 2), "")
        XCTAssertEqual(result.getValue(forRow: 1, withFieldIndex: 0), "")
        XCTAssertEqual(result.getValue(forRow: 1, withFieldIndex: 1), "")
    }

    func testEmptyFieldAtStart() {
        let parser = CsvParser(text: ",Field 2,Field 3")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "Field 2")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 2), "Field 3")
    }

    func testEmptyFieldAtMiddle() {
        let parser = CsvParser(text: "Field 1,,Field 3")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "Field 1")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 2), "Field 3")
    }

    func testEmptyFieldAtEnd() {
        let parser = CsvParser(text: "Field 1,Field 2,")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "Field 1")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "Field 2")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 2), "")
    }

}
