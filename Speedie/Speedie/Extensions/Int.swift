//
//  Int.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 26/06/16.
//
//

import Foundation

extension Int {
    public var timeValue: String {
        get {
            if self >= 0 && self < 10 {
                return "0\(self)"
            } else {
                return "\(self)"
            }
        }
    }
}