//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 07.01.21.
//

import Foundation

public class CsvParserState {

    private enum State {
        case fieldStart
        case fieldText
        case quoteStarted
    }

    private var fieldText: String = ""
    private var currentState: State = .fieldStart
    private var isQuoted: Bool = false
    private var lastChar: Character? = nil

    public var onField: ((String) -> Void)? = nil
    public var onNewRow: (() -> Void)? = nil

    private func fieldFinished() {
        print("[CsvParserState] fieldFinished() fieldText = '\(self.fieldText)'")

        guard let callback = self.onField else {
            return
        }

        callback(self.fieldText)

        self.fieldText = ""
        self.isQuoted = false
        self.currentState = .fieldStart
    }

    private func handleSignalChar(char: Character) {
        print("[CsvParserState] handleSignalChar() char = \(char.toLiterizedString()), currentState = \(self.currentState)")

        switch currentState {
        case .fieldStart:
            if char == Characters.doubleQuote {
                self.currentState = .quoteStarted
            }
            else if char == Characters.comma {
                self.fieldFinished()
            }
            else if char.isNewline {
                self.fieldFinished()
                self.onNewRow?()
            }
            else {
                self.currentState = .fieldText
                self.fieldText.append(char)
            }

        case .fieldText:
            if char == Characters.comma && !self.isQuoted {
                self.fieldFinished()
            }
            else if char == Characters.doubleQuote && self.isQuoted {
                self.currentState = .quoteStarted
            }
            else if char.isNewline {
                self.fieldFinished()
                self.onNewRow?()
            }
            else {
                self.fieldText.append(char)
            }

        case .quoteStarted:
            if char == Characters.doubleQuote {
                self.currentState = .fieldText
            }
            else if char == Characters.comma {
                fieldFinished()
            }
            else {
                self.isQuoted = true
                self.fieldText.append(char)
                self.currentState = .fieldText
            }

        }
    }

    private func handleSignalEndOfFile() {
        print("[CsvParserState] handleSignalEndOfFile()")

        switch self.currentState {
        case .fieldStart:
            if self.lastChar == Characters.comma {
                self.fieldFinished()
            }

        case .fieldText,
             .quoteStarted:
            if self.fieldText.count > 0 {
                self.fieldFinished()
            }
        }
    }

    func sendSignal(_ signal: CsvParserSignal) {
        let initialState = self.currentState
        print("[CsvParserState] sendSignal() signal = '\(signal)', currentState = \(self.currentState)")

        switch signal {
        case .character(let char):
            self.handleSignalChar(char: char)
            self.lastChar = char
            
        case .end:
            self.handleSignalEndOfFile()
        }

        if initialState != self.currentState {
            print("[CsvParserState] sendSignal() changed state from \(initialState) to \(self.currentState)")
        }
    }

}
