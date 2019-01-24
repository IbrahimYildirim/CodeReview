//
//  ViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 19/06/16.
//
//

import UIKit
import MapKit
import RxSwift
import pop
import kingpin
import Presentr
import AVFoundation

protocol CreateIncidentDelegate {
    func didCreateIncident(_ incident : IncidentResponse)
}

protocol UpdatedIncidentDelegate {
    func didUpdateIncident(_ incident : IncidentResponse)
}

protocol UpdatedAlarmSettingsDelegate {
    func didUpdateAlarmSettings()
}

class MainViewController: BaseViewController, CreateIncidentDelegate, UpdatedIncidentDelegate, UpdatedAlarmSettingsDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnAddIncident: UIButton!
    @IBOutlet weak var vwInfo: UIView!
    @IBOutlet weak var imgvInfo: UIImageView!
    @IBOutlet weak var txtInfoTitle: UILabel!
    @IBOutlet weak var txtInfoDate: UILabel!
    @IBOutlet weak var txtInfoAccepts: UILabel!
    @IBOutlet weak var txtInfoDismiss: UILabel!
    @IBOutlet weak var btnMoreInfo: UIButton!
    @IBOutlet weak var btnTrackLocation: UIButton!
    @IBOutlet weak var vwInfoTopContstraint: NSLayoutConstraint!
    
    fileprivate let infoViewHeight : CGFloat = 70
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var allLocationsTimer : Timer!
    
    fileprivate var allAnnotations : [SpeedieAnnotation]?
    fileprivate var clusteringController : KPClusteringController!
    fileprivate var forceShowInfo : Bool = false
    fileprivate var selectedIncident : IncidentResponse?
    fileprivate var showingEventInfo : Bool = false
    fileprivate var isTrackingUser : Bool = false
    
    fileprivate var player: AVAudioPlayer?
    
    fileprivate var alarmSettings : AlarmSetting!
    fileprivate var timeSinceLastCheck = Date()
    
    fileprivate let presenter : Presentr = {
        let screenRect = UIScreen.main.bounds
        
        let width = ModalSize.default
        let height = ModalSize.custom(size: Float(screenRect.size.height * 0.8))
        
        let customType = PresentationType.custom(width: width, height: height, center: ModalCenterPosition.center)
        
        let presenter = Presentr(presentationType: customType)
        presenter.transitionType = .crossDissolve
        presenter.roundCorners = true
        
        return presenter
    }()
    
    //MARK: - Utils
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        locationManager.delegate = self
        
        alarmSettings = SpeedieUserDefaults.getAlarmSettings()
        
        allLocationsTimer = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(MainViewController.updateAllIncidents), userInfo: nil, repeats: true)
        allLocationsTimer.fireDate = 5.minutes.fromNow()!
        
    }
    
    func playSound() {
        if let url = Bundle.main.url(forResource: "Sirene", withExtension: "m4a") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.volume = 0.5
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    //MARK: Timers
    func getNewIncidentsNearby() {
        if alarmSettings.alarmIsActive {
            if let location = locationManager.location {
                let coordinate = location.coordinate
//                getIncidentsNearByUser(alarmSettings.alarmRadius, location: coordinate)
                //Old alarm
                //            getIncidentsNearByUser(NEW_INCIDENTS_WITHIN_KM, location: coordinate)
            }
        }
    }
    
    func updateAllIncidents() {
//        getAllIncidentsAndUpdateMap()
    }
    
    //MARK: Delegate Methods
    func didCreateIncident(_ incident : IncidentResponse) {
//        getAllIncidentsAndUpdateMap(incident)
    }
    
    func didUpdateIncident(_ incident: IncidentResponse) {
        updateInfoView(incident)
//        getAllIncidentsAndUpdateMap()
    }
    
    func didUpdateAlarmSettings() {
        alarmSettings = SpeedieUserDefaults.getAlarmSettings()
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IncidentInfoSegue" {
            let controller = segue.destination as! IncidentInfoViewController
            if let incident =  selectedIncident {
                controller.incident = incident
                controller.delegate = self
            }
        } else if segue.identifier == "CreateIncidentSegue" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.viewControllers[0] as! CreateIncidentViewController
            controller.delegate = self
            controller.annotations = allAnnotations
        }
    }
    
    //MARK: UI Stuff
    func setupUI() {
        
        //Map Stuff
        let algorithm = KPGridClusteringAlgorithm()
        algorithm.annotationSize = CGSize(width: 38,height: 60)
        algorithm.gridSize = CGSize(width: 45, height: 60)
        algorithm.clusteringStrategy = KPGridClusteringAlgorithmStrategy.twoPhase
        
        clusteringController = KPClusteringController(mapView: self.mapView, clusteringAlgorithm: algorithm)
        clusteringController.delegate = self
        mapView.isRotateEnabled = false
        mapView.delegate = self
        
        //Nav Controller stuff
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //UI Stuff
        btnMoreInfo.layer.borderWidth = 2
        btnMoreInfo.layer.borderColor = UIColor(hexCode: 0x14213D).cgColor
        btnMoreInfo.layer.cornerRadius = 5
        
        btnAddIncident.addDropShadowToView(color : UIColor.black, radius : 3, offset : CGSize(width: 0, height: 0),opacity : 0.5)
        vwInfo.addDropShadowToView(color: UIColor.black, radius: 5, offset: CGSize.zero, opacity: 0.5)
        btnTrackLocation.addDropShadowToView(color: UIColor.black, radius: 3, offset: CGSize.zero, opacity: 0.5)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.mapDragged))
        panGestureRecognizer.delegate = self
        self.mapView .addGestureRecognizer(panGestureRecognizer)
    }
    
    func mapDragged() {
        if isTrackingUser {
            btnTrackLocation.setImage(UIImage(named: "TrackLocationDisabled"), for: UIControlState())
            self.mapView.userTrackingMode = .none
            isTrackingUser = false
        }
    }
    
    @IBAction func trackLocationClicked(_ sender: AnyObject) {
        
        if isTrackingUser {
            btnTrackLocation.setImage(UIImage(named: "TrackLocationDisabled"), for: UIControlState())
            self.mapView.userTrackingMode = .none
            isTrackingUser = false
        } else {
            if CLLocationManager.authorizationStatus()  == .authorizedWhenInUse {
                btnTrackLocation.setImage(UIImage(named: "TrackLocationEnabled"), for: UIControlState())
                self.mapView.userTrackingMode = .follow
                isTrackingUser = true
            } else {
                showLocationNotEnabled()
            }
        }
    }
    
    func showPopOver() {
        let askLocationVC = self.storyboard!.instantiateViewController(withIdentifier: "AskLocationViewController")
        let presenter = Presentr(presentationType: .popup)
        presenter.transitionType = .crossDissolve
        customPresentViewController(presenter, viewController: askLocationVC, animated: true, completion: nil)
    }
    
    func showLocationNotEnabled() {
        let okAction = UIAlertAction(title: "Aktiver", style: .default, handler:{ action in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(url!)
        })
        let cancelAction = UIAlertAction(title: "Annullér", style: .cancel, handler:nil)
        self.showAlert("Øv", message: "Lokalitets tjenester er deaktiveret. Vil du aktivere?", leftAction: cancelAction, rightAction: okAction)
    }
    
    func shouldShowInfoView(_ show : Bool) {
        if show {
            let moveY : POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            moveY.toValue = 0
            moveY.springSpeed = 12
            moveY.springBounciness = 12
            vwInfoTopContstraint.pop_add(moveY, forKey: "moveConstraint")
        } else {
            if vwInfoTopContstraint.constant != -infoViewHeight {
                let moveY =  POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                moveY?.toValue = -infoViewHeight
                vwInfoTopContstraint.pop_add(moveY, forKey: "moveConstraint")
            }
            selectedIncident = nil
        }
        showingEventInfo = show
    }
    
    func updateInfoView(_ incident : IncidentResponse) {
        txtInfoTitle.text = incident.titleForType()
        txtInfoDate.text = incident.createdDate(includeCreated: true)
        txtInfoAccepts.text = "\(incident.confirms)"
        txtInfoDismiss.text = "\(incident.denies)"
        imgvInfo.image = UIImage(named: incident.imageNameForType())
        selectedIncident = incident
    }
    
    func showAlert(_ title : String, message : String, leftAction : UIAlertAction, rightAction : UIAlertAction? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(leftAction)
        if let action = rightAction {
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clickedAlarmSetting(_ sender: AnyObject) {
        
        let alarmSettingVc = self.storyboard!.instantiateViewController(withIdentifier: "AlarmSettingViewController") as! AlarmSettingViewController
        alarmSettingVc.updatedAlarmSettingDelegate = self
        
        customPresentViewController(presenter, viewController: alarmSettingVc, animated: true, completion: nil)
    }
    
    @IBAction func zoomToSelectedIncident(_ sender: AnyObject) {
        if let incident = selectedIncident {
            forceShowInfo = true
            zoomToIncident(incident, zoomLevel: 0.005)
        }
    }
}

extension MainViewController : KPClusteringControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    //Not to interrups pan on map
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
/*    func clusteringControllerShouldClusterAnnotations(clusteringController: KPClusteringController!) -> Bool {
        return false
    }
 */
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if  let annotation = view.annotation as? KPAnnotation {
            let region : MKCoordinateRegion
            if annotation.annotations.count > 1 {
                region = MKCoordinateRegionMakeWithDistance(annotation.coordinate,
                                                            annotation.radius * 2.5,
                                                            annotation.radius * 2.5)
                mapView.setRegion(region, animated: true)
            }
            else {
                if let incident = getSpeedieAnnotation(annotation)?.incident {
                    updateInfoView(incident)
                    forceShowInfo = true
                }
                let center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                self.mapView.setCenter(center, animated: true)
            }
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    func zoomToIncident(_ incident : IncidentResponse, zoomLevel : CLLocationDegrees = 0.05) {
        let coordinate = CLLocationCoordinate2D(latitude: incident.latitude, longitude: incident.longiuted)
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel))
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if forceShowInfo {
            shouldShowInfoView(true)
        } else if selectedIncident != nil {
            shouldShowInfoView(!showingEventInfo)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusteringController.refresh(true)
        forceShowInfo = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView : MKAnnotationView!
        
        if annotation is KPAnnotation {
            let annotation = annotation as! KPAnnotation
            
            if annotation.isCluster() {
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster")
                if (annotationView == nil) {
                    annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "cluster")
                }
                
                switch annotation.annotations.count {
                case 2 : annotationView?.image = UIImage(named: "Pin2")
                case 3 : annotationView?.image = UIImage(named: "Pin3")
                case 4 : annotationView?.image = UIImage(named: "Pin4")
                case 5 : annotationView?.image = UIImage(named: "Pin5")
                case 6 : annotationView?.image = UIImage(named: "Pin6")
                case 7 : annotationView?.image = UIImage(named: "Pin7")
                case 8 : annotationView?.image = UIImage(named: "Pin8")
                case 9 : annotationView?.image = UIImage(named: "Pin9")
                default : annotationView?.image = UIImage(named: "Pin10")
                }
                annotationView.centerOffset = CGPoint(x: 0.0, y: -72/2);
            } else {
                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
                if (annotationView == nil) {
                    annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                }
                
                if let speedieAnnotation = getSpeedieAnnotation(annotation) {
                    annotationView.image = UIImage(named: speedieAnnotation.getImagePinString()!)
                }
                annotationView.centerOffset = CGPoint(x: 0.0, y: -60/2);
            }
        }
        
        return annotationView
    }
    
    func updateAllPinsOnMap(_ incidents : [IncidentResponse]?){
        if let incidents = incidents {
            
            var annotations = [SpeedieAnnotation]()
            
            for incident in incidents {
                let cord = SpeedieAnnotation()
                cord.incident = incident
                cord.coordinate = CLLocationCoordinate2D(latitude: incident.latitude, longitude: incident.longiuted)
                annotations.append(cord)
            }
            
            clusteringController.setAnnotations(annotations)
            allAnnotations = annotations
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            btnTrackLocation.setImage(UIImage(named: "TrackLocationDisabled"), for: UIControlState())
            delay(3, closure: {
                self.showPopOver()
            })
            break
        case .authorizedWhenInUse:
            btnTrackLocation.setImage(UIImage(named: "TrackLocationDisabled"), for: UIControlState())
            mapView.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 300
            locationManager.startUpdatingLocation()
            break
        case .denied:
            btnTrackLocation.setImage(UIImage(named: "Warning"), for: UIControlState())
            delay(3, closure: {
                self.showLocationNotEnabled()
            })
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if timeSinceLastCheck <= 5.seconds.ago()! {
            getNewIncidentsNearby()
            timeSinceLastCheck = Date()
        }
    }
    
    func dkCoord() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(55.15, 9.35)
    }
    
    func getSpeedieAnnotation(_ annotation : KPAnnotation) -> SpeedieAnnotation? {
        if let annotation = annotation.annotations.first as? SpeedieAnnotation {
            return annotation
        } else {
            return nil
        }
    }
}
