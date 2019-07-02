//
//  RoundMapView.swift
//  uber-clone
//
//  Created by Michael Luo on 3/7/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit
import MapKit

class RoundMapView: MKMapView {

    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 10.0
    }
}
