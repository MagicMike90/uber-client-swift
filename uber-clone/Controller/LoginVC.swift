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
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)

    }
    
}
extension UIViewController {
    
    @objc func handleScreenTap(send: UITapGestureRecognizer) -> Void {
        print("handleScreenTap")
        self.view.endEditing(true)
    }
}
