//
//  AboutUsViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 14/10/16.
//
//

import Foundation
import UIKit

class AboutUsViewController : UIViewController {
    
    @IBOutlet weak var txtvDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(AboutUsViewController.dismissViewController))
        self.navigationItem.leftBarButtonItem = leftButton
        
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.txtvDescription.scrollRangeToVisible(NSMakeRange(0, 0))
        self.txtvDescription.isEditable = false
    }
    
    @IBAction func facebookClicked(_ sender: AnyObject) {
        let facebookURL = URL(string: "fb://profile/speedie")!
        if UIApplication.shared.canOpenURL(facebookURL) {
            UIApplication.shared.openURL(facebookURL)
        } else {
            UIApplication.shared.openURL(URL(string: "https://www.facebook.com/speedie")!)
        }
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
