//
//  LoginVC.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var emailField: RoundedConnerTextField!
    @IBOutlet weak var passwordField: RoundedConnerTextField!
    @IBOutlet weak var segementedControl: UISegmentedControl!
    @IBOutlet weak var authBtn: RoundedShadowButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
        
    }
    
    private func createNewUser(user: User) {
        var userData:[String:Any] = [:];
        
        if self.segementedControl.selectedSegmentIndex == 0 {
            userData = ["provider": user.providerID] as [String:Any]
            
            DataService.instance.createFirebase(uid: user.uid, userData: userData, isDriver: false)
        } else {
            userData = ["provider": user.providerID, "userIsDriver": true, "isPickupModeEnable": false, "drvierIsOnTrip": false] as [String: Any]
            DataService.instance.createFirebase(uid: user.uid, userData: userData, isDriver: true)
        }
        
    }
    
    @IBAction func authBtnPressed(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else {return}
        
        
        authBtn.animateButton(shouldLoad: true, withMessage: nil)
        self.view.endEditing(true)
        
        
        Auth.auth().signIn(withEmail: email, password: password) {  result, error in
            
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case AuthErrorCode.invalidEmail:
                        print("Email invalid. Please try again")
                    case AuthErrorCode.wrongPassword:
                        print("The password is a wrong password!")
                    default:
                        print("Unexpeced error")
                    }
                }
            }
            
            
            guard let user = result?.user else {
                // if there is user then create one
                return Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
                    
                    if error != nil {
                        if let errorCode = AuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case AuthErrorCode.emailAlreadyInUse:
                                print("This email is already in use.")
                            case AuthErrorCode.invalidEmail:
                                print("Email invalid. Please try again")
                            default:
                                print("Unexpeced error")
                            }
                        }
                    } else {
                        if let user = result?.user {
                            self.createNewUser(user: user)
                            print("Create user successfully")
                        }
                        
                    }
                })
            }
            
            
            self.createNewUser(user: user)
            
            print("Email user authenicated successfully")
            return self.dismiss(animated: true, completion: nil)
        }
    }
}
extension UIViewController {
    
    @objc func handleScreenTap(send: UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
    }
}
