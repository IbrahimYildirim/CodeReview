//
//  CreateIncidentViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 19/06/16.
//
//

import UIKit
import CoreLocation
import pop
import JVFloatLabeledTextField
import IQKeyboardManagerSwift
import RxSwift

class CreateIncidentViewController: BaseViewController, SelectLocationDelegate {
    
    @IBOutlet weak var incidentSpeedControl: IncidentTypeView!
    @IBOutlet weak var incidentCue: IncidentTypeView!
    @IBOutlet weak var incidentAccident: IncidentTypeView!
    @IBOutlet weak var incidentOther: IncidentTypeView!
    @IBOutlet weak var btnSelectLocation: UIButton!
    @IBOutlet weak var txtDescription: JVFloatLabeledTextView!
    @IBOutlet weak var txtvAddress: JVFloatLabeledTextField!
    @IBOutlet weak var txtvAddressWidthCnstr: NSLayoutConstraint!
    @IBOutlet weak var txtvAdressTrailingCnstr: NSLayoutConstraint!
    
    var selectedType : IncidentType!
    var selectedLocation : CLLocation?
    var delegate : CreateIncidentDelegate?
    let disposeBag = DisposeBag()
    
    var annotations : [SpeedieAnnotation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(CreateIncidentViewController.cancelClicked))
        self.navigationItem.rightBarButtonItem = closeBtn
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.isTranslucent = false
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateIncidentViewController.dismissKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
        selectIncidentType(.SpeedControl)
        
        btnSelectLocation.layer.borderWidth = 2
        btnSelectLocation.layer.borderColor = Colors.appColor().cgColor
        btnSelectLocation.layer.cornerRadius = 10
    }
    
    func selectIncidentType(_ type : IncidentType) {
        if let currentSelectedType = selectedType {
            getViewForIncidentType(currentSelectedType).isSelected = false
        }
        getViewForIncidentType(type).isSelected = true
        selectedType = type
    }
    
    func didSetLocation(_ location: CLLocation) {
        selectedLocation = location
        getAddressFromLatLng(location)
        updateTextViewWidth()
    }
    
    func updateTextViewWidth() {
        let expandAnimation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        expandAnimation?.toValue = view.frame.size.width * 0.70 //70% of screen width
        txtvAddressWidthCnstr.pop_add(expandAnimation, forKey: "expand")
        
        let trailingAnimation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        trailingAnimation?.toValue = 10
        txtvAdressTrailingCnstr.pop_add(trailingAnimation, forKey: "trailing")
        
        btnSelectLocation.setTitle("Ændre", for: UIControlState())
    }
    
    func dismissKeyboard() {
        view.endEditing(false)
    }
    
    func checkForInputAndCreateIncident() -> IncidentResponse? {
        var description = txtDescription.text!
        
        if selectedLocation == nil {
            showError("Ooups", message: "Du har ikke valgt en lokation for denne hændelse")
            return nil
        } else {
            let incident = IncidentResponse()
            incident.latitude = selectedLocation!.coordinate.latitude
            incident.longiuted = selectedLocation!.coordinate.longitude
            incident.address = txtvAddress.text!
            incident.type = selectedType
            
            if description.isEmpty {
                switch incident.type {
                case .SpeedControl:
                    description = "Fartkontrol"
                case .Cue:
                    description = "Kø"
                case .Accident:
                    description = "Uheld"
                case .Other:
                    description = "Andet"
                }
            }
            
            incident.description = description
            
            return incident
        }
    }
    
    func showError(_ title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Button Events
    @IBAction func createIncidentClicked(_ sender: AnyObject) {
//        if let incident = checkForInputAndCreateIncident() {
//            showSpinner()
//            let incidentRequest = CreateIncidentRequest(longitude: incident.longiuted, latitude: incident.latitude, type: incident.type, address: incident.address, description: incident.description)
//            createIncident(incidentRequest).subscribe(onNext: { incident in
//                SpeedieUserDefaults.updateConfirmedIncidents(incident.id)
//                self.hideSpinner()
//                DispatchQueue.main.async(execute: {
//                    self.dismiss(animated: true, completion: {
//                        if self.delegate != nil {
//                            self.delegate?.didCreateIncident(incident)
//                        }
//                    })
//                })
//            }).addDisposableTo(disposeBag)
//        }
    }
    
    func cancelClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSelectSpeedControl(_ sender: AnyObject) {
        selectIncidentType(.SpeedControl)
    }
    @IBAction func didSelectCue(_ sender: AnyObject) {
        selectIncidentType(.Cue)
    }
    @IBAction func didSelectAccident(_ sender: AnyObject) {
        selectIncidentType(.Accident)
    }
    @IBAction func didSelectOther(_ sender: AnyObject) {
        selectIncidentType(.Other)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectLocationSegue" {
            let controller = segue.destination as! SelectLocationViewController
            controller.delegate = self
            controller.incidentType = selectedType
            if let annotations = annotations {
                controller.annotations = annotations
            }
        }
    }
    
    //MARK: Helpers
    func getViewForIncidentType(_ incidentType : IncidentType) -> IncidentTypeView {
        switch incidentType {
        case .SpeedControl:
            return incidentSpeedControl
        case .Cue:
            return incidentCue
        case .Accident:
            return incidentAccident
        default:
            return incidentOther
        }
    }
    
    //MARK: Private Events
    func getAddressFromLatLng(_ latLng : CLLocation) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(latLng, completionHandler: { (placeMarks, error) -> Void in
            if let placeMarks = placeMarks {
                let place = placeMarks[0]
                if place.thoroughfare != nil {
                    var s : String = ""
                    if place.subThoroughfare != nil {
                        s = String(format : "%@ %@, %@", place.thoroughfare!, place.subThoroughfare!, place.locality!)
                    }
                    else {
                        s = String(format : "%@, %@ %@", place.thoroughfare!, place.postalCode!, place.locality!)
                    }
                    self.txtvAddress.text = s
                }
                else {
                    self.txtvAddress.text = "Ukendt adresse"
                }
            }
        })
    }
    
}
