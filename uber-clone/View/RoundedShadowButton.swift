//
//  RoundedShadowButton.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

@IBDesignable class RoundedShadowButton: UIButton {
    
    private static let ANIMATED_DURATION = 0.3
    
    var originalSize: CGRect?
    
    override init(frame: CGRect) {
      super.init(frame: frame)
         setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         setupView()
    }
//    override func awakeFromNib() {
//        setupView()
//    }
//
    func setupView() -> Void {
        originalSize = self.frame
        self.layer.cornerRadius = 5.0
        self.layer.shadowRadius = 10.0
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
    }
    
    func animateButton(shouldLoad:Bool, withMessage message:String?) {
        let spinnerTag = 21
        
 
        if shouldLoad {
           
            
            let spinner = UIActivityIndicatorView()
            spinner.style = .white
            spinner.color = UIColor.darkGray
            spinner.alpha = 0.0
            spinner.tag = spinnerTag
            spinner.hidesWhenStopped = true
            
            self.setTitle("", for: .normal)
            self.addSubview(spinner)
            
            UIView.animate(withDuration: RoundedShadowButton.ANIMATED_DURATION, animations: {
                self.layer.cornerRadius = self.frame.height / 2
                print("before")
                print("originalSize \(self.originalSize!)")
                print("self.frame \(self.frame)")
                 print("center \(self.center)")
                print("````````````````````")
                self.frame = CGRect(x: self.frame.midX - (self.frame.height / 2), y: self.frame.origin.y, width: self.frame.height, height: self.frame.height)
            }, completion: {(finish) in
                if finish == true {
                    spinner.startAnimating()
                    spinner.center = CGPoint(x: self.frame.width / 2, y: self.frame.width / 2)
                    spinner.fadeTo(alphaValue: 1.0, withDuration:RoundedShadowButton.ANIMATED_DURATION)
                    
                    print("after")
                    print("originalSize \(self.originalSize!)")
                    print("self.frame \(self.frame)")
                    print("````````````````````")
                }
            })
            self.isUserInteractionEnabled = false
        } else {
            self.isUserInteractionEnabled = true
            // remove spinner
            for subView in self.subviews {
                // why 21?
                if subView.tag == spinnerTag {
                    subView.removeFromSuperview()
                }
            }
            
            print("````````````````````\(shouldLoad)")
            print("originalSize \(self.originalSize!)")
            print("self.frame \(self.frame)")
            print("````````````````````")
            
            UIView.animate(withDuration: RoundedShadowButton.ANIMATED_DURATION, animations: {
                self.layer.cornerRadius = 5.0
                self.frame = self.originalSize!
                self.setTitle(message, for: .normal)
                self.setNeedsLayout()
            })
//            self.frame = self.originalSize!
        }
    }
    
}
