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
}
