//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 04.01.21.
//

import Foundation

public class CsvDataSet {

    public let columns: [String]?
    public let columnsCount: Int
    public let rows: [[String]]
    public let rowsCount: Int

    public init(columns: [String]?, rows: [[String]]) {
        self.columns = columns
        self.rows = rows

        if let columns = columns {
            self.columnsCount = columns.count
        }
        else {
            var maxColumnsCount = 0
            for row in rows {
                maxColumnsCount = max(maxColumnsCount, row.count)
            }

            self.columnsCount = maxColumnsCount
        }

        self.rowsCount = rows.count
    }

    public var hasHeader: Bool {
        return self.columns != nil
    }

    public func getValue(forColumn column: Int) -> String? {
        if self.columns != nil && self.columnsCount > column {
            return self.columns![column]
        }

        return nil
    }

    public func getValue(forRow row: Int, withFieldIndex field: Int) -> String? {
        if self.rows.count > row && self.rows[row].count > field {
            return self.rows[row][field]
        }

        return nil
    }

    subscript(row: Int, field: Int) -> String? {
        get {
            return getValue(forRow: row, withFieldIndex: field)
        }
    }

}
