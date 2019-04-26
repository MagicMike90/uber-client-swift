//
//  GradientView.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    //    let gradient =  CAGradientLayer()
    //
    //    // setup anycode when the interface change
    //    override func awakeFromNib() {
    //        setupGradientView()
    //    }
    //
    //
    //    func setupGradientView() {
    //        gradient.frame = self.bounds
    //        gradient.colors = [UIColor.white.cgColor, UIColor.init(white:1.0, alpha: 0.0).cgColor]
    //        gradient.startPoint = CGPoint.zero
    //        gradient.endPoint = CGPoint(x: 0, y: 1)
    //        gradient.locations = [0.8, 1.0]
    //        self.layer.addSublayer(gradient)
    //    }
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        
        gradientLayer.colors = [
            UIColor.black.cgColor, UIColor.init(white:0.0, alpha: 0.0).cgColor
        ]
        gradientLayer.locations = [0.8, 1.0]
        gradientLayer.startPoint = CGPoint.zero
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    }
}
