//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 04.01.21.
//

import Foundation

public class CsvDataSet {

    private let columns: [String]?
    private let rows: [[String]]

    public init(columns: [String]?, rows: [[String]]) {
        self.columns = columns
        self.rows = rows
    }

    public var rowsCount: Int {
        return self.rows.count
    }

    public var columnsCount: Int {
        return self.columns?.count ?? 0
    }

    public var hasHeader: Bool {
        return self.columns != nil
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
