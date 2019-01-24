//
//  BaseViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 26/06/16.
//
//

import Foundation
import UIKit

class BaseViewController : UIViewController {
    
    var actvIndicator : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showSpinner(_ lifted : Bool = false){
        if actvIndicator == nil {
            self.actvIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.actvIndicator.color = UIColor.black
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight =  screenSize.height
            self.actvIndicator.center = CGPoint(x: CGFloat(screenWidth / 2), y: CGFloat(screenHeight/(lifted ? 3 : 2)))
            self.actvIndicator.startAnimating()
        }
        
        UIApplication.shared.keyWindow?.addSubview(self.actvIndicator)
    }
    
    func hideSpinner(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.actvIndicator.alpha = 0
        }, completion: { (finished) -> Void in
            self.actvIndicator.removeFromSuperview()
            self.actvIndicator.alpha = 1
        }) 
    }
}
