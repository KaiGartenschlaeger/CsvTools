import XCTest
@testable import CsvTools

final class CsvToolsTests: XCTestCase {

    func testNormal() {
        let text =
        """
        Spalte 1,Spalte 2
        Zelle 1 1,Zelle 1 2
        Zelle 2 1,Zelle 2 2
        """

        let reader = CsvReader(text)
        reader.hasHeader = true

        let result = reader.parse()

        XCTAssertNotNil(result.columns)

        XCTAssertEqual(2, result.columns?.count)
        XCTAssertEqual("Spalte 1", result.columns![0])
        XCTAssertEqual("Spalte 2", result.columns![1])

        XCTAssertEqual(2, result.rows.count)

        XCTAssertEqual(2, result.rows[0].count)
        XCTAssertEqual("Zelle 1 1", result.rows[0][0])
        XCTAssertEqual("Zelle 1 2", result.rows[0][1])

        XCTAssertEqual(2, result.rows[1].count)
        XCTAssertEqual("Zelle 2 1", result.rows[1][0])
        XCTAssertEqual("Zelle 2 2", result.rows[1][1])
    }

    func testAdjustColumns() {
        let text =
        """
        Spalte 1,Spalte 2
        Zelle 1 1,Zelle 1 2
        Zelle 2 1,
        Zelle 3 1
        """

        let reader = CsvReader(text)
        reader.hasHeader = true

        let result = reader.parse()

        XCTAssertNotNil(result.columns)

        XCTAssertEqual(2, result.columns?.count)

        XCTAssertEqual(result.columns?[0], "Spalte 1")
        XCTAssertEqual(result.columns?[1], "Spalte 2")

        XCTAssertEqual(3, result.rows.count)

        XCTAssertEqual(2, result.rows[0].count)
        XCTAssertEqual(result.rows[0][0], "Zelle 1 1")
        XCTAssertEqual(result.rows[0][1], "Zelle 1 2")

        XCTAssertEqual(2, result.rows[1].count)
        XCTAssertEqual(result.rows[1][0], "Zelle 2 1")
        XCTAssertEqual(result.rows[1][1], "")

        XCTAssertEqual(1, result.rows[2].count)
        XCTAssertEqual(result.rows[2][0], "Zelle 3 1")
    }

    func testDoubleQuotes1() {
        let text =
        """
        "Zelle 1 1","Zelle 1 2"
        "Zelle 2 1","Zelle 2 2"
        """

        let reader = CsvReader(text)
        reader.hasHeader = false

        let result = reader.parse()

        XCTAssertNil(result.columns)

        XCTAssertEqual(result.rows.count, 2)
        XCTAssertEqual("Zelle 1 1", result.rows[0][0])
        XCTAssertEqual("Zelle 1 2", result.rows[0][1])
        XCTAssertEqual("Zelle 2 1", result.rows[1][0])
        XCTAssertEqual("Zelle 2 2", result.rows[1][1])
    }

    func testDoubledDoubleQuotes1() {
        let text =
        """
        ""Z 1.1"",""Z 2.1""
        ""Z 1.2,Z 2.2""
        """

        let reader = CsvReader(text)
        reader.hasHeader = false

        let result = reader.parse()

        XCTAssertNil(result.columns)

        XCTAssertEqual(result.rows.count, 2)
        XCTAssertEqual("\"Z 1.1\"", result.rows[0][0])
        XCTAssertEqual("\"Z 2.1\"", result.rows[0][1])
        XCTAssertEqual("\"Z 1.2", result.rows[1][0])
        XCTAssertEqual("Z 2.2\"", result.rows[1][1])
    }

    func testDoubledDoubleQuotes2() {
        let text =
        """
        Test 1"".,Test 2"".
        """

        let reader = CsvReader(text)
        reader.hasHeader = false

        let result = reader.parse()

        XCTAssertNil(result.columns)

        XCTAssertEqual(result.rows.count, 1)
        XCTAssertEqual("Test 1\".", result.rows[0][0])
        XCTAssertEqual("Test 2\".", result.rows[0][1])
    }

    func testWhitespaces() {
        let text = " WSL1,WSR1 \n WSLR1 ,  WSLR 2  "

        let reader = CsvReader(text)
        reader.hasHeader = false

        let result = reader.parse()

        XCTAssertNil(result.columns)

        XCTAssertEqual(result.rows.count, 2)
        XCTAssertEqual(" WSL1", result.rows[0][0])
        XCTAssertEqual("WSR1 ", result.rows[0][1])
        XCTAssertEqual(" WSLR1 ", result.rows[1][0])
        XCTAssertEqual("  WSLR 2  ", result.rows[1][1])
    }

    func testInvalidData1() {
        let text = "\"Spalte1,Spalte2"

        let reader = CsvReader(text)
        reader.hasHeader = false

        let result = reader.parse()

        XCTAssertNil(result.columns)

        XCTAssertEqual(result.rows.count, 1)
        XCTAssertEqual("Spalte1,Spalte2", result.rows[0][0])
    }

    func testFix1() {
        let text = "Spalte 1,"

        let reader = CsvReader(text)
        let result = reader.parse()

        XCTAssertNotNil(result.columns)
        XCTAssertEqual(result.columns?[0], "Spalte 1")
        XCTAssertEqual(result.columns?[1], "")

        XCTAssertEqual(result.rows.count, 0)
    }

    func testInvalidComma() {
        let text = "\"Zelle A, Zelle A.B\",Zelle C"

        let reader = CsvReader(text)
        reader.hasHeader = false

        let result = reader.parse()

        XCTAssertNil(result.columns)

        XCTAssertEqual(result.rows.count, 1)
        XCTAssertEqual(result.rows[0][0], "Zelle A, Zelle A.B")
        XCTAssertEqual(result.rows[0][1], "Zelle C")
    }

}
