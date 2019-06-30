//
//  ViewController.swift
//  uber-clone
//
//  Created by Michael Luo on 24/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit
import RevealingSplashView
import Lottie
import MapKit
import CoreLocation
import Firebase

class HomeVC: UIViewController, Alertable {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionBtn: RoundedShadowButton!
    @IBOutlet weak var centerMapBtn: UIButton!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var destinationCircle: CircleView!
    var delegate: CenterVCDelegate?

    let locationManager = CLLocationManager()

    var currentUserId: String?

    var ragionRadius: CLLocationDistance = 1000

    var tableView = UITableView()

    var matchingItems: [MKMapItem] = [MKMapItem]()

    var route: MKRoute?

    var selectedItemPlacemark: MKPlacemark?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView.delegate = self
        destinationTextField.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        DataService.instance.REF_DRIVERS.observe(.value) { (_) in
            self.loadDriverAnnotationFromFB()
        }

        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()

        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "uber")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor(rgb: 0x100E17))
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true

        currentUserId = Auth.auth().currentUser?.uid
    }

    override func viewWillAppear(_ animated: Bool) {
        checkLocationAuthStatus()
    }

    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    // get the coordinate from Firebase
    // and display on the map
    func loadDriverAnnotationFromFB() {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.hasChild("userIsDriver") {
                        if  driver.hasChild("coordinate") {
                            if driver.childSnapshot(forPath: ACCOUNT_PICKUP_MODE_ENABLED).value as? Bool == true {
                                // Pull down all the value from firease
                                if let driverDict =  driver.value as? Dictionary<String, AnyObject> {
                                    
                                    guard let coordinateArray = driverDict["coordinate"] as? NSArray else {
                                        return;
                                    }
//                                    let coordinateArray =  driverDict["coordinate"] as! NSArray
                                    let driverCoordinate =  CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)

                                    let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driver.key)

                                    var driverIsVisible: Bool {
                                        return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                            if let driverAnnotation = annotation as? DriverAnnotation {
                                                if driverAnnotation.key == driver.key {
                                                    print(driverCoordinate)
                                                    driverAnnotation.update(AnnotationPosition: driverAnnotation, withCoordinate: driverCoordinate)
                                                    return true
                                                }
                                            }
                                            return false
                                        })
                                    }

                                    if !driverIsVisible {
                                        self.mapView.addAnnotation(annotation)
                                    }
                                }
                            } else {
                                for annotation in self.mapView.annotations {
                                    if annotation.isKind(of: DriverAnnotation.self) {
                                        if let annotation =  annotation as? DriverAnnotation {
                                            if annotation.key == driver.key {
                                                self.mapView.removeAnnotation(annotation)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
    }

    func centerMapOnUserLocation() {
        let coordinateRegion =  MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: ragionRadius * 2.0, longitudinalMeters: ragionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func actionButtonWasPressed(_ sender: Any) {
        actionBtn.animateButton(shouldLoad: true, withMessage: nil)
    }

    @IBAction func menuBtnPressed(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }

    @IBAction func centerMapBtnPressed(_ sender: Any) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == self.currentUserId! {
                        if user.hasChild(TRIP_COORDINATE) {
                            self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: false, withKey: nil)
                            self.centerMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                        } else {
                            self.centerMapOnUserLocation()
                            self.centerMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                        }
                    }
                }
            }
        })
    }
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
}

extension HomeVC: MKMapViewDelegate {
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("mapViewDidFailLoadingMap \(error)")
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
        UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
    }

    // tell where to replace the image
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView?

        if let annotation =  annotation as? DriverAnnotation {
            let identifier = "driver"

            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.image = UIImage(named: ANNO_DRIVER)
            return view
        } else if let annotation = annotation as? PassengerAnnotation {
            let identifier = "passenger"
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.image = UIImage(named: ANNO_PICKUP)
            return view
        } else if let annotation = annotation as? MKPointAnnotation {
            let identifier = "destination"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named: ANNO_DESTINATION)
            return annotationView
        }

        return view
    }

    // render and custom route style
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRenderer = MKPolylineRenderer(overlay: (self.route?.polyline)!)
        lineRenderer.strokeColor = UIColor(red: 216/255, green: 71/255, blue: 30/255, alpha: 0.75)
        lineRenderer.lineWidth = 3

        shouldPresentLoadingView(false)

        return lineRenderer
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        centerMapBtn.fadeTo(alphaValue: 1.0, withDuration: 0.2)
    }

    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = destinationTextField.text
        request.region = mapView.region

        let search = MKLocalSearch(request: request)

        search.start { (response, error) in
            if error != nil {
                self.showAlert(ERROR_MSG_UNEXPECTED_ERROR)
                self.shouldPresentLoadingView(false)
            } else if response!.mapItems.count == 0 {
                self.showAlert(ERROR_MSG_NO_MATCHES_FOUND)
            } else {
                for mapItem in response!.mapItems {
                    self.matchingItems.append(mapItem as MKMapItem)
                    self.tableView.reloadData()
                    self.shouldPresentLoadingView(false)
                }
            }
        }
    }

    func dropPinFor(placemark: MKPlacemark) {
        selectedItemPlacemark = placemark

        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }

        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }

    func searchMapKitForResultsWithPolyline(forOriginMapItem originMapItem: MKMapItem?, withDestinationMapItem destinationMapItem: MKMapItem) {
        let request = MKDirections.Request()

        if originMapItem == nil {
            request.source = MKMapItem.forCurrentLocation()
        } else {
            request.source = originMapItem
        }

        request.destination = destinationMapItem
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = true

        let directions = MKDirections(request: request)

        directions.calculate { (response, error) in
            guard let response = response else {
                self.showAlert(error.debugDescription)
                return
            }
            self.route = response.routes[0]

            self.mapView.addOverlay(self.route!.polyline)

            self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: false, withKey: nil)

            self.shouldPresentLoadingView(false)
        }
    }

    // zoom between the route
    func zoom(toFitAnnotationsFromMapView mapView: MKMapView, forActiveTripWithDriver: Bool, withKey key: String?) {
        if mapView.annotations.count == 0 {
            return
        }

        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)

        if forActiveTripWithDriver {
            for annotation in mapView.annotations {
                if let annotation = annotation as? DriverAnnotation {
                    if annotation.key == key {
                        topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                        topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                        bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                        bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                    }
                } else {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                }
            }
        }

        // for any annotation that is not driver
        for annotation in mapView.annotations where !annotation.isKind(of: DriverAnnotation.self) {
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
        }

        var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 2.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 2.0))

        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }

}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == destinationTextField {
            tableView.frame = CGRect(x: 20, y: view.frame.height, width: view.frame.width - 40, height: view.frame.height - 170)
            tableView.layer.cornerRadius = 5.0
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_LOCATION)

            tableView.delegate = self
            tableView.dataSource = self

            tableView.tag = 18
            tableView.rowHeight = 60

            view.addSubview(tableView)
            animateTableView(shouldShow: true)

            UIView.animate(withDuration: 0.2, animations: {
                self.destinationCircle.backgroundColor = UIColor.red
                self.destinationCircle.borderColor = UIColor.init(red: 199/255, green: 0/255, blue: 0/255, alpha: 1.0)
            })
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == destinationTextField {
            performSearch()
            shouldPresentLoadingView(true)
            view.endEditing(true)
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == destinationTextField {
            if destinationTextField.text == "" {
                UIView.animate(withDuration: 0.2, animations: {
                    self.destinationCircle.backgroundColor = UIColor.lightGray
                    self.destinationCircle.borderColor = UIColor.darkGray
                })
            }
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        matchingItems = []
        tableView.reloadData()

        // Clean save location
        DataService.instance.REF_USERS.child(currentUserId!).child(TRIP_COORDINATE).removeValue()

        // remove any annotations
        mapView.removeOverlays(mapView.overlays)
        for annotation in mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            } else if annotation.isKind(of: PassengerAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }

        centerMapOnUserLocation()
        return true
    }

    // create and animate search table
    func animateTableView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: 250, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            }, completion: { (_) in
                for subview in self.view.subviews {
                    if subview.tag == 18 {
                        subview.removeFromSuperview()
                    }
                }
            })
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldPresentLoadingView(true)
      
        if let id = currentUserId {
            // update text filed by using selected text
            destinationTextField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
            
            let passengerCoordinate = locationManager.location?.coordinate
            
            let passengerAnnotation = PassengerAnnotation(coordinate: passengerCoordinate!, key: id)
            mapView.addAnnotation(passengerAnnotation)
            let selectedMapItem = matchingItems[indexPath.row]

            DataService.instance.REF_USERS.child(id).updateChildValues([TRIP_COORDINATE: [selectedMapItem.placemark.coordinate.latitude, selectedMapItem.placemark.coordinate.longitude]])
            dropPinFor(placemark: selectedMapItem.placemark)

            // draw the route line
            searchMapKitForResultsWithPolyline(forOriginMapItem: nil, withDestinationMapItem: selectedMapItem)
        }
        
        shouldPresentLoadingView(false)
        animateTableView(shouldShow: false)
        return self.showAlert(ERROR_MSG_NOT_LOGIN_ERROR)
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: CELL_LOCATION)
        let mapItem = matchingItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title
        return cell
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if destinationTextField.text == "" {
            animateTableView(shouldShow: false)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
