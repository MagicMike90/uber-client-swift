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
    
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var destinationCircle: CircleView!
    var delegate: CenterVCDelegate?
    
    let locationManager = CLLocationManager()
    
    var ragionRadius: CLLocationDistance = 1000
    
    var tableView = UITableView()
    
   var matchingItems: [MKMapItem] = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        destinationTextField.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        DataService.instance.REF_DRIVERS.observe(.value) { (snapshot) in
            print("updated");
            self.loadDriverAnnotationFromFB()
        }
        
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "uber")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor(rgb: 0x100E17))
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
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
                                    let coordinateArray =  driverDict["coordinate"] as! NSArray
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
    
    
    func centerMapUserLocation() {
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
        centerMapUserLocation()
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
        if let annotation =  annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "driverAnnotation")
            return view;
        }
        
        return nil
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
            } else if response!.mapItems.count == 0 {
                self.showAlert(ERROR_MSG_NO_MATCHES_FOUND)
            } else {
                for mapItem in response!.mapItems {
                    self.matchingItems.append(mapItem as MKMapItem)
                    self.tableView.reloadData()
//                    self.shouldPresentLoadingView(false)
                }
            }
        }
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
//            shouldPresentLoadingView(true)
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
        
        centerMapUserLocation()
        return true;
    }
    

    
    
    func animateTableView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: 250, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            }, completion: { (finished) in
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
        return matchingItems.count;
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
