# CsvTools

Reads and writes files in csv format.

## Read files
~~~swift
let reader = CsvReader(csvString)
reader.hasHeader = false

let csvData = reader.parse()
~~~

## Write files
Not implemented yet
