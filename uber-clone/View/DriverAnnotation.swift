//
//  Driverannotation.swift
//  uber-clone
//
//  Created by Michael Luo on 3/5/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import Foundation
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    // it requires objective c compile for mapview
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate:CLLocationCoordinate2D, withKey key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
    
    func update(AnnotationPosition annotation: DriverAnnotation, withCoordinate:CLLocationCoordinate2D){
        var location =  self.coordinate
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        UIView.animate(withDuration: 0.2) {
            self.coordinate = location
        }
    }
}
