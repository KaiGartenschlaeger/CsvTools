//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 04.01.21.
//

import Foundation

public class CsvReader {

    private let text: String

    var hasHeader: Bool = true
    var adjustColumns: CsvReaderColumnAdjustment = .ignore

    public init(_ text: String) {
        self.text = text
    }

    private func isDoubleQuote(text: Substring, index: String.Index) -> Bool {
        if index >= text.endIndex {
            return false
        }

        let firstIndex = index
        let nextIndex = text.index(after: firstIndex)
        if text[firstIndex] == "\"" {
            if nextIndex < text.endIndex && text[nextIndex] != "\"" {
                return true
            }
        }

        return false
    }

    private func findEndIndex(text: Substring) -> String.Index? {
        return text.firstIndex(of: "\"")
    }

    private func parseField(fieldText: Substring) -> Substring {
        var startIndex: String.Index = fieldText.startIndex
        var endIndex: String.Index

        //print("[parseField], startCharacter = '\(fieldText[fieldText.startIndex])', count = \(fieldText.count)")

        // skip "," at start
        if fieldText[startIndex] == "," {
            startIndex = fieldText.index(after: startIndex)
        }

        //print("[parseField], startCharacter = '\(fieldText[startIndex])', startIndex = \(fieldText.distance(from: fieldText.startIndex, to: startIndex))")

        let hasDoubleQuotes = isDoubleQuote(text: fieldText, index: startIndex)
        if hasDoubleQuotes {
            startIndex = fieldText.index(after: startIndex)

            let left = fieldText[startIndex..<fieldText.endIndex]
            if let index = findEndIndex(text: left) {
                endIndex = index
            } else {
                endIndex = fieldText.endIndex
            }
        } else {
            if let index = fieldText[startIndex..<fieldText.endIndex].firstIndex(of: ",") {
                endIndex = index
            } else {
                endIndex = fieldText.endIndex
            }
        }

        return fieldText[startIndex..<endIndex]
    }

    public func parse() -> CsvReaderDataSet {
        var headerColumns: [String]?
        var rows: [[String]] = []
        var isFirstRow = true

        self.text.enumerateLines { (line, stop) in
            var columns: [String] = []
            var substring = Substring(line)

            //print()
            //print("[parse] line = '\(substring)'")

            while (true) {
                let field = self.parseField(fieldText: substring)

                //print("[parse] fieldRange = \(line.distance(from: line.startIndex, to: field.startIndex)) - \(line.distance(from: line.startIndex, to: field.endIndex))")
                //print("[parse] fieldText = '\(field)'")

                columns.append(String(field).replacingOccurrences(of: "\"\"", with: "\""))

                let leftCount = line.count - line.distance(from: line.startIndex, to: field.endIndex)
                //print("[parse] leftCount = \(leftCount)")

                if field.endIndex >= line.endIndex || leftCount == 0 {
                    break
                }
                else if leftCount == 1 && line[field.endIndex] == "," {
                    columns.append("")
                    break
                }
                else if leftCount == 1 && line[field.endIndex] == "\"" {
                    columns.append("")
                    break
                }
                else {
                    substring = line[line.index(after: field.endIndex)..<line.endIndex];
                }
            }

            if isFirstRow {
                // header row
                if self.hasHeader {
                    headerColumns = columns
                }
                else {
                    rows.append(columns)
                }

                isFirstRow = false
            } else {
                // data row
                if self.hasHeader && self.adjustColumns != .ignore {
                    switch self.adjustColumns {
                    case .adjust:
                        if columns.count == headerColumns?.count {
                            rows.append(columns)
                        } else {
                            if let headerColumnsCount = headerColumns?.count {
                                while columns.count < headerColumnsCount {
                                    columns.append("")
                                }
                                while columns.count > headerColumnsCount {
                                    columns.removeLast()
                                }
                            }

                            rows.append(columns)
                        }
                        break

                    case .remove:
                        if columns.count == headerColumns?.count {
                            rows.append(columns)
                        }

                    case .ignore:
                        break
                    }
                } else {
                    rows.append(columns)
                }
            }
        }

        return CsvReaderDataSet(
            columns: headerColumns,
            rows: rows)
    }
}
