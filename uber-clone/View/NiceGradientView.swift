//
//  GradientView.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

class NiceGradientView: UIView {
    
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds

        // Set an array of Core Graphics colors (.cgColor) to create the gradient.
        // This example uses a Color Literal and a UIColor from RGB values.
        let gradient1 = UIColor(rgb: 0xff8a00)
        let gradient2 = UIColor(rgb: 0xda1b60)

        gradientLayer.colors = [gradient1.cgColor, gradient2.cgColor]
        // Rasterize this static layer to improve app performance.
//        gradientLayer.shouldRasterize = true
        
        
        self.layer.addSublayer(gradientLayer)
    }
}
