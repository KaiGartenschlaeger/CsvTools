//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 04.01.21.
//

import Foundation

public class CsvReader {

    private let text: String

    public var hasHeader: Bool = true
    public var adjustColumns: CsvReaderColumnAdjustment = .ignore

    public init(_ text: String) {
        self.text = text
    }

    private func moveToEndOfField(iterator: StringIterator, isQuoted: Bool) {
        while iterator.next() {
            //print("moveToEndOfField() isQuoted = \(isQuoted), currentChar = \(iterator.currentChar as Any), nextChar = \(iterator.nextChar as Any)")

            if isQuoted {
                if iterator.currentChar == Characters.doubleQuote {
                    if iterator.nextChar != Characters.doubleQuote {
                        break
                    }
                    else {
                        let _ = iterator.next()
                    }
                }
            }
            else {
                if iterator.currentChar == Characters.comma {
                    break
                }
            }
        }
    }

    private func readField(from iterator: StringIterator) -> String? {
        if iterator.isEndOfString {
            return nil
        }

        let isQuotedField = iterator.currentChar == Characters.doubleQuote && iterator.nextChar != Characters.doubleQuote
        if isQuotedField {
            let _ = iterator.next()
        }

        iterator.setBreakpoint()

        moveToEndOfField(iterator: iterator, isQuoted: isQuotedField)
        let fieldText = createFieldString(fieldText: iterator.leftText)

        //print("readField() fieldText = '\(fieldText)', currentChar = \(iterator.currentChar as Any), nextChat = \(iterator.nextChar as Any)")

        // skip closing double quote
        if isQuotedField && iterator.currentChar == Characters.doubleQuote {
            let _ = iterator.next()
        }

        return fieldText
    }

    private func createFieldString(fieldText: Substring) -> String {
        let text = String(fieldText)
        return text
            .replacingOccurrences(of: "\"\"", with: "\"")
    }

    public func parse() -> CsvReaderDataSet {
        var headerColumns: [String]?
        var rows: [[String]] = []

        var isFirstRow = true
        self.text.enumerateLines { (line, stop) in
            //print("parse() line = \(line)")

            var currentRow: [String] = []

            let iterator = StringIterator(text: line)
            while let field = self.readField(from: iterator) {
                //print("parse() field = '\(field)'")
                currentRow.append(field)

                // skip comma after field
                if iterator.currentChar == Characters.comma {
                    let _ = iterator.next()

                    if iterator.isEndOfString {
                        // add last empty field
                        currentRow.append("")
                    }
                }
            }

            if self.hasHeader && isFirstRow {
                isFirstRow = false
                headerColumns = currentRow
            }
            else {
                rows.append(currentRow)
            }
        }

        return CsvReaderDataSet(
            columns: headerColumns,
            rows: rows)
    }
}
