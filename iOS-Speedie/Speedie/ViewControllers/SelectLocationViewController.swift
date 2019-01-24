//
//  SelectLocationViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 22/06/16.
//
//

import UIKit
import CoreLocation
import MapKit
import pop

protocol SelectLocationDelegate {
    func didSetLocation(_ location : CLLocation)
}

class SelectLocationViewController: BaseViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var vwSearchBar: UIView!
    @IBOutlet weak var imgvPin: UIImageView!
    @IBOutlet weak var imgvCenter: UIImageView!
    @IBOutlet weak var txtAdress: UITextField!
    
    var incidentType : IncidentType!
    var delegate : SelectLocationDelegate?
    var updatedLocation : Bool = false
    
    var annotations : [SpeedieAnnotation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true

        if let annotations = annotations {
            for annotation in annotations {
                self.mapView.addAnnotation(annotation)
            }
        }
        
        vwSearchBar.addDropShadowToView(color: UIColor.black, radius: 1, offset: CGSize.zero, opacity: 0.5)
        vwSearchBar.layer.cornerRadius = 5
        txtAdress.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 1, animations: {
            self.imgvPin.alpha = 1
        }) 
    }
    
    override func viewDidLayoutSubviews() {
        var center = imgvCenter.center
        center.y -= imgvPin.frame.size.height/2
        imgvPin.center = center
    }
    
    
    @IBAction func onSelectLocationClicked(_ sender: AnyObject) {
        
        let pinsOnMap = self.mapView.annotations(in: self.mapView.visibleMapRect)
        let centerPointCoordinates = mapView.convert(imgvCenter.center, toCoordinateFrom: self.view)
        
        var isFarEnough = true
        
        for pin in pinsOnMap {
            if !(pin is MKUserLocation) {
                if let pin = pin as? MKAnnotation {
                    let pinLocation = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
                    let distance = pinLocation.distance(from: CLLocation(latitude: centerPointCoordinates.latitude, longitude: centerPointCoordinates.longitude))
                    
                    if distance < 30 {
                        isFarEnough = false
                        break
                    }
                    
                    //print("Distance : \(distance)")
                }
            }
        }
        
        if isFarEnough {
            if delegate != nil {
                
                delegate?.didSetLocation(CLLocation(latitude: centerPointCoordinates.latitude, longitude: centerPointCoordinates.longitude))
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Oups", message: "Der må ikke oprettes en hændelse for tæt på en anden. De skal være minimum 30 meter fra hinanden", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)

        }
    
        /*if pinsOnMap.count == 0 || (pinsOnMap.count == 1 && pinsOnMap.first is MKUserLocation) {
            if delegate != nil {
                
                delegate?.didSetLocation(CLLocation(latitude: centerPointCoordinates.latitude, longitude: centerPointCoordinates.longitude))
                self.navigationController?.popViewControllerAnimated(true)
            }
        } else {
            let alert = UIAlertController(title: "Oups", message: "Der må ikke oprettes en hændelse for tæt på en anden. Zoom lidt tættere ind på kortet så andre hændelser ikke er synlige", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }*/
    }
    
    
    
    //MARK: MKMapView Delegate Function
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !updatedLocation{
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
            self.mapView.setRegion(region, animated: true)
            updatedLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        animateItems(mapIsMoving: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        animateItems(mapIsMoving: false)
    }
    
    func animateItems(mapIsMoving startedToMove : Bool) {
        
        let translateAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)

        translateAnimation?.springBounciness = 12
        
        var newAlpha : CGFloat
        var center = imgvCenter.center
        center.y -= imgvPin.frame.size.height/2
        var pinCenter = center
        
        if startedToMove {
            pinCenter.y -= 20
            newAlpha = 1.0
        } else {
            pinCenter.y = center.y
            newAlpha = 0.0
        }
        
        translateAnimation?.toValue = NSValue(cgPoint: pinCenter)
        alphaAnimation?.toValue = newAlpha
        
        imgvPin.pop_add(translateAnimation, forKey: "translate")
        imgvCenter.pop_add(alphaAnimation, forKey: "alpha")
    }
}

extension SelectLocationViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            if let adress = textField.text {
                let geocoder = CLGeocoder()
                self.showSpinner(true)
                geocoder.geocodeAddressString(adress, completionHandler: { (places, error) in
                    if let places = places {
                        let place = places[0]
                        if let location = place.location {
                            let region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.01, 0.01))
                            self.mapView.setRegion(region, animated: true)
                        }
                    } else {
                        let alert = UIAlertController(title: "Ooups", message: "Vi kunne ikke finde adressen. Skriv venligst gadenavn og by", preferredStyle: UIAlertControllerStyle.alert)
                        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.hideSpinner()
                })
            }
        }
        textField.endEditing(true)
        return true
    }
    
}
