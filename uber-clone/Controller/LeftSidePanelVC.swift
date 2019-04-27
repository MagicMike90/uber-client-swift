//
//  LeftSidePanelVCViewController.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

class LeftSidePanelVC: UIViewController {

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userAccountType: UILabel!
    @IBOutlet weak var userImage: RoundImageView!
    @IBOutlet weak var authBtn: UIButton!
    @IBOutlet weak var pickupModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func SignUpBtnPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let loginVC =  storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        
        present(loginVC!,animated: true, completion: nil)
    }
}
