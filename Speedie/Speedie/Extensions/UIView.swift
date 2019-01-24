//
//  UIView.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 19/06/16.
//
//

import UIKit

extension UIView {
    func addDropShadowToView(color: UIColor, radius : CGFloat, offset : CGSize, opacity : Float) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func fadeAway(hideAfterwards hide : Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            }, completion: { _ in
                self.isHidden = hide
        }) 
    }
    
    func fadein() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        })
    }
}
