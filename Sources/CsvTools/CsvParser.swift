//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 07.01.21.
//

import Foundation

public class CsvParser {

    private let text: String

    public var hasHeader: Bool = true
    public var trimFields: Bool = false

    public init(text: String) {
        self.text = text
    }

    public func parse() -> CsvDataSet {
        var columns: [String]? = nil
        var rows: [[String]] = []
        var fields: [String] = []
        var isFirstRow: Bool = true

        let state = CsvParserState()

        state.onField = { fieldText in
            print("[CsvParser] parse() -> onField(), fieldText = '\(fieldText)'")

            if self.trimFields {
                fields.append(fieldText.trimmingCharacters(in: .whitespaces))
            }
            else {
                fields.append(fieldText)
            }
        }

        state.onNewRow = {
            print("[CsvParser] parse() -> onNewRow(), isFirstRow = \(isFirstRow)")

            if isFirstRow && self.hasHeader {
                isFirstRow = false
                columns = fields
            }
            else {
                rows.append(fields)
            }

            fields.removeAll()
        }

        var index = self.text.startIndex
        while index < self.text.endIndex {
            state.sendSignal(.character(ch: self.text[index]))
            index = self.text.index(after: index)
        }

        state.sendSignal(.end)

        if fields.count > 0 {
            rows.append(fields)
        }

        return CsvDataSet(
            columns: columns,
            rows: rows)
    }

}
