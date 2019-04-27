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

class HomeVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionBtn: RoundedShadowButton!
    
    var delegate: CenterVCDelegate?
    
    var locationManager: CLLocationManager?;
    
    var ragionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.delegate = self
        
        checkLocationAuthStatus()

        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "uber")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor(rgb: 0x100E17))
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
    }
    
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        } else {
            locationManager?.requestAlwaysAuthorization()
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
        if status == .authorizedAlways {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
}

extension HomeVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
        UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
    }
}
