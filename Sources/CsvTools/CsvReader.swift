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
    public var trimFields: Bool = false
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
                        _ = iterator.next()
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

        if iterator.currentChar == Characters.comma {
            // empty field
            return ""
        }

        //print("readField() currentChar = \(iterator.currentChar as Any), nextChat = \(iterator.nextChar as Any)")
        iterator.setBreakpoint()
        if iterator.currentChar == Characters.doubleQuote && iterator.nextChar == Characters.doubleQuote {
            _ = iterator.next()
            _ = iterator.next()
            if iterator.currentChar == Characters.comma || iterator.isEndOfString {
                // empty field
                return ""
            }
            else {
                _ = iterator.moveToBreakpoint()
            }
        }

        let isQuotedField = iterator.currentChar == Characters.doubleQuote && iterator.nextChar != Characters.doubleQuote
        if isQuotedField {
            _ = iterator.next()
        }

        iterator.setBreakpoint()

        moveToEndOfField(iterator: iterator, isQuoted: isQuotedField)
        let fieldText = createFieldString(fieldText: iterator.leftText)

        //print("readField() fieldText = '\(fieldText)', currentChar = \(iterator.currentChar as Any), nextChat = \(iterator.nextChar as Any)")

        // skip closing double quote
        if isQuotedField && iterator.currentChar == Characters.doubleQuote {
            _ = iterator.next()
        }

        return fieldText
    }

    private func createFieldString(fieldText: Substring) -> String {
        var text = String(fieldText)
        text = text.replacingOccurrences(of: "\"\"", with: "\"")

        if self.trimFields {
            text = text.trimmingCharacters(in: .whitespaces)
        }

        return text
    }

    public func parse() -> CsvReaderDataSet {
        var tmpColumns: [String]?
        var tmpRows: [[String]] = []

        var isFirstRow = true
        self.text.enumerateLines { (line, stop) in
            //print("parse() line = '\(line)'")

            if !line.isEmpty {
                var currentRow: [String] = []

                let iterator = StringIterator(text: line)
                while let field = self.readField(from: iterator) {
                    //print("parse() field = '\(field)'")
                    currentRow.append(field)

                    // skip comma after field
                    if iterator.currentChar == Characters.comma {
                        _ = iterator.next()

                        if iterator.isEndOfString {
                            // add last empty field
                            //print("parse() ending empty fields")
                            currentRow.append("")
                        }
                    }
                }

                if self.hasHeader && isFirstRow {
                    isFirstRow = false
                    tmpColumns = currentRow
                }
                else {
                    if self.hasHeader {
                        switch self.adjustColumns {
                        case .adjust:
                            break
                        case .remove:
                            break
                        case .ignore:
                            break
                        }
                    }

                    tmpRows.append(currentRow)
                }
            }
        }

        return CsvReaderDataSet(
            columns: tmpColumns,
            rows: tmpRows)
    }
}
