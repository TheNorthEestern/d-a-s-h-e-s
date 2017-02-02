//
//  String+Ext.swift
//  d-a-s-h-e-s
//
//  Created by Kacy James on 1/30/17.
//  Copyright © 2017 Student Driver. All rights reserved.
//

import Foundation

/*
    This extension allows us to check if a string contains alphanumeric characters.
 */

extension String {
    var containsAlphabets: Bool {
        return utf16.contains { (CharacterSet.alphanumerics as NSCharacterSet).characterIsMember($0) }
    }
    var containsSymbols: Bool {
        return utf16.contains { (CharacterSet.symbols as NSCharacterSet).characterIsMember($0) }
    }
}
