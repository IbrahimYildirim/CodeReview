//
//  AskLocationViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 28/06/16.
//
//

import UIKit

class AskLocationViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    @IBAction func askMeForLocationClicked(_ sender: AnyObject) {
        SpeedieUserDefaults.setUserDidClickToBeAskedForLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            self.dismiss(animated: true, completion:nil)
            break
        case .denied:
            self.dismiss(animated: true, completion:nil)
            break
        default:
            break
        }
    }
}
