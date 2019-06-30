//
//  PassengerAnnotation.swift
//  uber-clone
//
//  Created by Michael Luo on 27/6/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import Foundation
import MapKit

class PassengerAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String

    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
}
