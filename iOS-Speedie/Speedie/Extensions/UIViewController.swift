//
//  UIViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 28/06/16.
//
//

import Foundation

extension UIViewController {
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
