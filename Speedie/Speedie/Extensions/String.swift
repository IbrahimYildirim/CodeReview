//
//  String.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 20/06/16.
//
//

import Foundation
import UIKit

extension String {
    func attributedTextWithColor(_ color : UIColor) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [NSForegroundColorAttributeName: color])
    }
}
