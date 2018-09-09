//
//  Regexp.swift
//  translate
//
//  Created by Pavel Driver on 09.09.2018.
//  Copyright © 2018 Pavel Driver. All rights reserved.
//

import Foundation

extension String
{
    func checkLang(pattern: String) -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).lowercased()
            }
        }
        
        return []
    }
}
