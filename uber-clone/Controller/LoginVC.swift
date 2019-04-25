//
//  LoginVC.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.bindToKeyboard()
        
        self.hideKeyboardWhenTappedAround()
//
//        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.handleScreenTap(send:)))
//        tapGesture.numberOfTapsRequired = 1
//        tapGesture.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(tapGesture)
    }
//    override func touchesBegan(_ touches: Set<UITouch>,
//                               with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension UIViewController {
    
    @objc func handleScreenTap(send: UITapGestureRecognizer) -> Void {
        print("handleScreenTap")
        self.view.endEditing(true)
    }
}
