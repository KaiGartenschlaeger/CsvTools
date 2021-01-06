//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 06.01.21.
//

import Foundation

class StringIterator {

    let text: String

    private var currentIndex: String.Index
    private var breakpoint: String.Index?

    init(text: String) {
        self.text = text
        self.currentIndex = text.startIndex
    }

    func moveBack() -> Bool {
        if isStartOfString {
            return false
        }

        self.currentIndex = self.text.index(before: self.currentIndex)
        return true
    }

    //    /// Moves to the next character and returns it, or nil if the end is reached.
    //    func next() -> Character? {
    //        if self.moveForward() && self.currentIndex != self.text.endIndex {
    //            return self.currentChar
    //        }
    //        return nil
    //    }

    func next() -> Bool {
        if isEndOfString {
            return false
        }

        self.currentIndex = self.text.index(after: self.currentIndex)
        return true
    }

    func moveForward(untilChar char: Character, fallbackEndOfString: Bool = true) -> Bool {
        if self.isEndOfString {
            return false
        }

        let startIndex = self.text.index(after: self.currentIndex)
        if let newIndex = self.text[startIndex..<self.text.endIndex].firstIndex(of: char) {
            self.currentIndex = newIndex
            return true
        }
        else {
            if fallbackEndOfString {
                self.currentIndex = self.text.endIndex
                return true
            }
        }

        return false
    }

    func moveForward(untilText text: String) -> Bool {
        if self.isEndOfString {
            return false
        }

        if let range = self.text[self.currentIndex..<self.text.endIndex].range(of: text) {
            self.currentIndex = range.lowerBound
        }

        return true
    }

    /// Moves to start of the text
    func moveToStart() {
        self.currentIndex = self.text.startIndex
    }

    /// Moves to end of the text
    func moveToEnd() {
        self.currentIndex = self.text.endIndex
    }

    /// Returns the character before the current position
    var previousChar: Character? {
        if isStartOfString {
            return nil
        }

        return self.text[self.text.index(before: self.currentIndex)]
    }

    /// Returns the character at the current position
    var currentChar: Character? {
        if isEndOfString {
            return nil
        }

        return self.text[self.currentIndex]
    }

    private var nextIndex: String.Index? {
        if self.currentIndex < self.text.endIndex {
            return self.text.index(after: self.currentIndex)
        }

        return nil
    }

    /// Returns the character after the current position
    var nextChar: Character? {
        if let index = self.nextIndex {
            if index != self.text.endIndex {
                return self.text[index]
            }
        }

        return nil
    }

    /// Checks if the current position is at start of the text
    var isStartOfString: Bool {
        return self.currentIndex <= self.text.startIndex
    }

    /// Checks if the current position is at end of the text
    var isEndOfString: Bool {
        return self.currentIndex >= self.text.endIndex
    }

    /// Sets the breakpoint to the current position
    func setBreakpoint() {
        self.breakpoint = self.currentIndex
    }

    /// Removes the breakpoint
    func unsetBreakpoint() {
        self.breakpoint = nil
    }

    /// Checks if the text at the current position starts with the given text
    func startsWith(text: String) -> Bool {
        if self.isEndOfString {
            return false
        }

        let range = self.text[self.currentIndex..<self.text.endIndex].range(of: text)
        return self.currentIndex == range?.lowerBound
    }

    /// Sets the current position to the breakpoint
    func moveToBreakpoint() -> Bool {
        guard let breakpoint = self.breakpoint else {
            return false
        }

        self.currentIndex = breakpoint
        return true
    }

    //    func moveToNextLine() -> Bool {
    //    }

    /// Returns true if the current position is the same as the breakpoint
    var isAtBreakpoint: Bool {
        return self.currentIndex == self.breakpoint
    }

    /// Returns true if a breakpoint is set
    var hasBreakpoint: Bool {
        return self.breakpoint != nil
    }

    /// Returns the left part of the text up to the breakpoint
    var leftText: Substring {
        if self.isStartOfString {
            return ""
        }

        var startIndex: String.Index = self.text.startIndex
        if self.breakpoint != nil && self.breakpoint! < self.currentIndex {
            startIndex = breakpoint!
        }

        return self.text[startIndex..<self.currentIndex]
    }

    /// Returns the right part of the text up to the breakpoint
    var rightText: Substring? {
        //        if self.isEndOfString {
        //            return nil
        //        }
        //
        //        return self.text[self.currentIndex..<self.text.endIndex]

        return nil
    }

}
