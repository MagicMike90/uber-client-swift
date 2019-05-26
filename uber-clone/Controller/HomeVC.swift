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

class HomeVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionBtn: RoundedShadowButton!
    
    var delegate: CenterVCDelegate?
    
    let locationManager = CLLocationManager()
    
    var ragionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        loadDriverAnnotationFromFB()
        
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
                    if  driver.hasChild("coordinate") {
                        if driver.childSnapshot(forPath: IS_PICKUP_MODE).value as? Bool == true {
                            // Pull down all the value from firease
                            if let driverDict =  driver.value as? Dictionary<String, AnyObject> {
                                let coordinateArray =  driverDict["coordinate"] as! NSArray
                                let driverCoordinate =  CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                
                                let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driver.key)
                                self.mapView.addAnnotation(annotation)
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
}
