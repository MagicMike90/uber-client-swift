//
//  UIViewExt.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

extension UIView {
    func fadeTo(alphaValue: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
    }
    
//    func bindToKeyboard() {
////         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//    }
//
// 
//    @objc func keyboardWillChange(_ notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            let duration =  userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
//            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
//            let curFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//            let targetFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//            let deltaY = targetFrame.origin.y - curFrame.origin.y
//
//            print("deltaY \(deltaY)")
//            UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
//                self.frame.origin.y += deltaY
//            }, completion: nil)
//        }
//    }
    
}
