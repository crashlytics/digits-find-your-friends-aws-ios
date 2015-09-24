//
//  Extensions.swift
//  DigitsFYF
//
//  Created by Valentin Polouchkine  on 9/1/15.
//  Copyright © 2015 Fabric. All rights reserved.
//

import Foundation

extension String {
    func stringByRemovingOccurrencesOfCharacters(chars: String) -> String {
        let cs = characters.filter {
            chars.characters.indexOf($0) == nil
        }
        
        return String(cs)
    }
}