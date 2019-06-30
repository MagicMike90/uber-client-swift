//
//  File.swift
//  uber-clone
//
//  Created by Michael Luo on 26/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))

        // this is important to make sure the tag is working in global view
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func shouldPresentLoadingView(_ status: Bool) {
        var fadeView: UIView?

        if status == true {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadeView?.backgroundColor = UIColor.black
            fadeView?.alpha = 0.0
            fadeView?.tag = 99

            let spinner = UIActivityIndicatorView()
            spinner.color = UIColor.white
            spinner.style = .whiteLarge
            spinner.center = view.center

            view.addSubview(fadeView!)
            fadeView?.addSubview(spinner)

            spinner.startAnimating()

            fadeView?.fadeTo(alphaValue: 0.7, withDuration: 0.2)
        } else {
            for subview in view.subviews {
                if subview.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0.0
                    }, completion: { (_) in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
    }
}
