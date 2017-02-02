//
//  StringManipulator.swift
//  d-a-s-h-e-s
//
//  Created by Kacy James on 1/30/17.
//  Copyright © 2017 Student Driver. All rights reserved.
//

import Foundation

class StringManipulator {
    public static func dashify(_ text: String,_ separator: Character = "-") -> String
    {
        var dashedText = [String]()
        for (index, char) in text.characters.enumerated() {
            dashedText.append("\(char)")
            if index != text.characters.count - 1 {
                dashedText.append("\(separator)")
            }
        }
        return dashedText.joined()
    }
}
