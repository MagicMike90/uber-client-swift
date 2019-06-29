//
//  LoginVC.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController , UITextFieldDelegate ,Alertable{
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
        
    }
    // create user account
    private func createNewAccount(email:String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
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
                
                return
            }
            
            if let user = result?.user {
                self.createNewUser(user: user)
                log.info("Create user successfully !")
                self.signIn(email: email, password: password)
                log.info("Auto signin user")
            }
            
        })
    }
    
    // create a new user
    private func createNewUser(user: User) {
        var userData:[String:Any] = [:];
        
        if self.segementedControl.selectedSegmentIndex == 0 {
            userData = ["provider": user.providerID] as [String:Any]
            
            DataService.instance.createFirebase(uid: user.uid, userData: userData, isDriver: false)
        } else {
            userData = ["provider": user.providerID, "userIsDriver": true, ACCOUNT_PICKUP_MODE_ENABLED: false, "drvierIsOnTrip": false] as [String: Any]
            DataService.instance.createFirebase(uid: user.uid, userData: userData, isDriver: true)
        }
        
    }
    
    // sign in user
    private func signIn(email:String, password: String ) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            
            guard user != nil else {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case AuthErrorCode.invalidEmail:
                        self?.showAlert(ERROR_MSG_INVALID_EMAIL)
                        log.error("Email invalid. Please try again")
                    case AuthErrorCode.wrongPassword:
                        self?.showAlert(ERROR_MSG_WRONG_PASSWORD)
                        log.error("The password is a wrong password!")
                    case AuthErrorCode.userNotFound:
                        self?.createNewAccount(email: email, password: password);
                        log.info("The user not found and create one!")
                    default:
                        self?.showAlert(ERROR_MSG_UNEXPECTED_ERROR)
                        log.error("Unexpeced error")
                    }
                    
                    self?.authBtn.animateButton(shouldLoad: false, withMessage: MSG_SIGN_UP_SIGN_IN)
                }
                return
            }
            
            log.info("Email user authenicated successfully")
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func authBtnPressed(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else {return}
        
        authBtn.animateButton(shouldLoad: true, withMessage: nil)
        self.view.endEditing(true)
        
        self.signIn(email: email, password: password)
//        print("Email user authenicated successfully")
//        self.dismiss(animated: true, completion: nil)
        
    }
}
extension UIViewController {
    
    @objc func handleScreenTap(send: UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
    }
}
