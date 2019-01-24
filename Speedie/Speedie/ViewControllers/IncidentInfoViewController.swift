//
//  IncidentInfoViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 20/06/16.
//
//

import UIKit
import MapKit
import RxSwift

class IncidentInfoViewController: BaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblConfirms: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnDeny: UIButton!
    @IBOutlet weak var lblAmountOfConfirms: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblAmountOfDenies: UILabel!
    @IBOutlet weak var vwConfirmationAndDenial: UIView!
    
    
    let disposeBag = DisposeBag()
    var delegate : UpdatedIncidentDelegate?
    var incident : IncidentResponse!
    
    //MARK: - Utillities
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let coordinate = CLLocationCoordinate2D(latitude: incident.latitude, longitude: incident.longiuted)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.003, 0.003)), animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        updateDescription()
    }
    
    func setupUI() {
        self.title = "Info"
        edgesForExtendedLayout = UIRectEdge()
        mapView.isUserInteractionEnabled = false
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        btnConfirm.addDropShadowToView(color: UIColor.black, radius: 1, offset: CGSize.zero, opacity: 0.5)
        btnDeny.addDropShadowToView(color: UIColor.black, radius: 1, offset: CGSize.zero, opacity: 0.5)
        
        if !SpeedieUserDefaults.getConfirmedIncidents().contains((incident?.id)!) {
            vwConfirmationAndDenial.fadein()
        }
        
        lblDescription.text = incident.description
        lblAmountOfDenies.text = "\(incident.denies)"
        lblAmountOfConfirms.text = "\(incident.confirms)"
        lblDate.text = incident.createdDate(includeCreated: false)
        lblAddress.text = incident.address
    }
    
    func updateDescription() {
        var descFrame = lblDescription.frame
        descFrame.size.height = 0
        lblDescription.frame = descFrame
        lblDescription.sizeToFit()
    }
    
    func updateHistory(_ incident : IncidentResponse?) {
        
        if let incident = incident {
            lblAmountOfDenies.text = "\(incident.denies)"
            lblAmountOfConfirms.text = "\(incident.confirms)"
            
            let mutableAttributedString = NSMutableAttributedString()
            
            if let activites = incident.activities {
                for activity in activites {
                    mutableAttributedString.append(activity.getAttributedText())
                }
            }
            lblConfirms.attributedText = mutableAttributedString
            
            var historyFrame = lblConfirms.frame
            historyFrame.size.height = 0
            lblConfirms.frame = historyFrame
            UIView.animate(withDuration: 0.3, animations: {
                self.lblConfirms.sizeToFit()
            }) 
            
            self.incident = incident
            
            if self.delegate != nil {
                self.delegate?.didUpdateIncident(incident)
            }
        }
    }
    
    @IBAction func confirmClicked(_ sender: AnyObject) {
//        vwConfirmationAndDenial.fadeAway(hideAfterwards: true)
//        showSpinner()
//        confirmIncident(incident.id).subscribe(onNext: { incident in
//            self.hideSpinner()
//            self.updateHistory(incident)
//            SpeedieUserDefaults.updateConfirmedIncidents(incident.id)
//            if self.delegate != nil {
//                self.delegate?.didUpdateIncident(incident)
//            }
//        }).addDisposableTo(disposeBag)
    }
    
    @IBAction func denyClicked(_ sender: AnyObject) {
//        vwConfirmationAndDenial.fadeAway(hideAfterwards: true)
//        showSpinner()
//        denyIncident(incident.id).subscribe(onNext: { incident in
//            self.hideSpinner()
//            self.updateHistory(incident)
//            SpeedieUserDefaults.updateConfirmedIncidents(incident.id)
//            if self.delegate != nil {
//                self.delegate?.didUpdateIncident(incident)
//            }
//            }).addDisposableTo(disposeBag)
    }
}

extension IncidentInfoViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        
        annotationView!.image = UIImage(named: getImagePinString()!)
        annotationView!.centerOffset = CGPoint(x: 0.0, y: -60/2)
        return annotationView
    }
    
    func getImagePinString() -> String? {
        if let type : IncidentType = incident?.type {
            switch type {
            case .SpeedControl: return "ControlPin"
            case .Cue: return "CuePin"
            case .Accident: return "AccidentPin"
            case .Other: return "OtherPin"
            }
        }
        return ""
    }
}

extension IncidentInfoViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffSet = scrollView.contentOffset.y
        let newScale = ((scrollOffSet * -1) / 200) + 1
        
        if scrollOffSet < 0.0 {
            if newScale > 1.0 && newScale < 2.0 {
                mapView.transform = CGAffineTransform(scaleX: newScale, y: newScale)
            }
            var newFrame = mapView.frame
            newFrame.origin.y = scrollOffSet / 4
            mapView.frame = newFrame
        } else if scrollOffSet > 0.0 {
            var newFrame = mapView.frame
            newFrame.origin.y = -scrollOffSet / 2
            mapView.frame = newFrame
        } else if scrollOffSet == 0 {
            mapView.transform = CGAffineTransform.identity
            var newFrame = mapView.frame
            newFrame.origin.y = 0
            mapView.frame = newFrame
        }
    }
}
