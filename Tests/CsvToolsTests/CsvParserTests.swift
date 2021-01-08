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

    func testCommaAtStart() {
        let parser = CsvParser(text: ",Field 2,Field 3")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "Field 2")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 2), "Field 3")
    }

    func testCommaInMiddle() {
        let parser = CsvParser(text: "Field 1,,Field 3")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "Field 1")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 2), "Field 3")
    }

    func testCommaAtEnd() {
        let parser = CsvParser(text: "Field 1,Field 2,")
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "Field 1")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "Field 2")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 2), "")
    }

    func testCommaInFieldText() {
        let text = """
        "Mustermann, Max","Musterweg 123"
        "Mustermann, Susi","Musterweg 123"
        """

        let parser = CsvParser(text: text)
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 2)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "Mustermann, Max")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "Musterweg 123")
        XCTAssertEqual(result.getValue(forRow: 1, withFieldIndex: 0), "Mustermann, Susi")
        XCTAssertEqual(result.getValue(forRow: 1, withFieldIndex: 1), "Musterweg 123")
    }

    func testDoubleQuoteinFieldText() {
        let text = """
        Feld""1,Feld""2
        """

        let parser = CsvParser(text: text)
        parser.hasHeader = false

        let result = parser.parse()

        XCTAssertFalse(result.hasHeader)
        XCTAssertEqual(result.rowsCount, 1)
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 0), "Feld\"1")
        XCTAssertEqual(result.getValue(forRow: 0, withFieldIndex: 1), "Feld\"2")
    }

}
