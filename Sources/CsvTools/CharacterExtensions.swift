//
//  File.swift
//  
//
//  Created by Kai Gartenschläger on 08.01.21.
//

import Foundation

extension Character {

    func toLiterizedString() -> String {
        switch self {
        case "\n":   return "\\n"
        case "\r":   return "\\r"
        case "\r\n": return "\\r\\n"
        case "\t":   return "\t"
        case "\0":   return "\\0"
        default:     return String(self)
        }
    }
    
}
