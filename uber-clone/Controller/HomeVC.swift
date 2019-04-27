//
//  ViewController.swift
//  uber-clone
//
//  Created by Michael Luo on 24/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var actionBtn: RoundedShadowButton!
    
    var delegate: CenterVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        
//        let gradient1 = UIColor(rgb: 0xff8a00)
//        let gradient2 = UIColor(rgb: 0xda1b60)
//        self.actionBtn.applyGradient(withColours: [gradient1,gradient2], locations: nil)
    }
    
    // This has to do with the constraints in your storyboard not being applied until the subviews are laid out. At viewDidLoad() the view has a
    // fixed size from the storyboard. If you move the code that sets the layer's frame to viewDidLayoutSubviews() the constraints have been
    // applied to topView and it then has the correct frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let gradient1 = UIColor(rgb: 0xff8a00)
//                let gradient2 = UIColor(rgb: 0xda1b60)
//        self.actionBt.layer.applyGradient(withColours: [gradient1,gradient2], locations: nil)
        //        self.actionBtn.applyGradient(withColours: [UIColor.yellow, UIColor.blue], locations: nil)
//        self.view.applyGradient(withColours: [UIColor.yellow, UIColor.blue, UIColor.red], gradientOrientation: GradientOrientation.horizontal)
    }

    @IBAction func actionButtonWasPressed(_ sender: Any) {
        actionBtn.animateButton(shouldLoad: true, withMessage: nil)
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
}

