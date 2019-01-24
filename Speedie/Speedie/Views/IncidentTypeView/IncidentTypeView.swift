//
//  IncidentTypeView.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 21/06/16.
//
//

import Foundation
import UIKit
import pop

@IBDesignable class IncidentTypeView : BaseCustomXibView {
    
    @IBOutlet weak var imgvType: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    
    @IBInspectable var typeImage : UIImage? {
        get {
            return imgvType.image
        }
        set(image) {
            imgvType.image = image?.withRenderingMode(.alwaysTemplate)
            imgvType.tintColor = UIColor.lightGray
        }
    }
    
    @IBInspectable var scaleSize : CGFloat = 1.5
    
    @IBInspectable var typeLabel : String? {
        get {
            return lblType.text
        }
        set(text) {
            lblType.text = text
        }
    }
    
    var isSelected : Bool = false {
        didSet {
            animateView(isSelected)
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        layer.masksToBounds = false
    }
    
    func updateView(_ text : String, image : UIImage) {
        imgvType.image = image
        lblType.text = text
    }
    
    func animateView(_ didSelect : Bool) {
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        
        if didSelect {
            scaleAnimation?.toValue = NSValue(cgSize: CGSize(width: scaleSize, height: scaleSize))
            imgvType.tintColor = UIColor(hexCode: 0x14213D)
        } else {
            scaleAnimation?.toValue = NSValue(cgSize: CGSize(width: 1.0, height: 1.0))
            imgvType.tintColor = UIColor.lightGray
        }
        
        scaleAnimation?.springBounciness = 12
        scaleAnimation?.springSpeed = 8
        
        imgvType.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
    }
    
}
