//
//  LeftSidePanelVCViewController.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit
import Firebase

class LeftSidePanelVC: UIViewController {
    
    let appDelegate = AppDelegate.getAppDelegate()
    
    let currentUserId =  Auth.auth().currentUser?.uid;
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userAccountType: UILabel!
    @IBOutlet weak var userImageView: RoundImageView!
    @IBOutlet weak var authBtn: UIButton!
    @IBOutlet weak var pickupModeSwitch: UISwitch!
    @IBOutlet weak var pickupModeSection: UIView!
    @IBOutlet weak var pickupModeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pickupModeSwitch.isOn = false
        pickupModeSection.isHidden = true
        
        self.observePassengersAndDrivers()
        
        if Auth.auth().currentUser == nil {
            reset()
        } else {
            userEmailLabel.text = Auth.auth().currentUser?.email
            userAccountType.text = ""
            authBtn.setTitle("Logout", for: .normal)
        }
    }
    
    func observePassengersAndDrivers() {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key  == Auth.auth().currentUser?.uid {
                        self.userAccountType.text = "PASSENGER"
                    }
                }
            }
        }
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key  == Auth.auth().currentUser?.uid {
                        self.userAccountType.text = "DRIVER"
                        self.pickupModeSection.isHidden = false
                        
                        let switchStatus = snap.childSnapshot(forPath: PICKUP_MODE).value as! Bool
                        self.pickupModeSwitch.isOn = switchStatus
                    }
                }
            }
        }
    }
    
    func reset() -> Void {
        userEmailLabel.text = ""
        userAccountType.text = ""
        authBtn.setTitle("Sign Up / Login", for: .normal)
    }
    
    @IBAction func togglePickupMode(_ sender: Any) {
        
        if pickupModeSwitch == nil {
            return
        }

        if pickupModeSwitch.isOn {
            pickupModeLabel.text = "Disable Pick-up Mode"
            
        } else {
            pickupModeLabel.text = "Enable Pick-up Mode"
        }
        
        appDelegate.MenuContainerVC.toggleLeftPanel()
        DataService.instance.REF_DRIVERS.child(currentUserId!).updateChildValues(["isPickupModeEnabled": pickupModeSwitch.isOn])
        
    }
    
    @IBAction func SignUpBtnPressed(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC =  storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            
            present(loginVC!,animated: true, completion: nil)
        } else {
            do {
                try Auth.auth().signOut()
                reset()
            } catch {
                print (error)
            }
        }
        
    }
}
