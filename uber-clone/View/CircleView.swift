//
//  CircleView.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

class CircleView: UIView {

    // Interface builder will look at this value
    @IBInspectable var borderColor : UIColor? {
        didSet {
            setupView()
        }
    }

    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = 1.5
        // set the color whatever we set in the interface
        self.layer.borderColor = borderColor?.cgColor
    }
}
