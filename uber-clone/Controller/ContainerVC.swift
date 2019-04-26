//
//  ContainerVC.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case collapsed
    case leftPanelExpanded
}

enum ShowWhichVC {
    case homeVC
}



class ContainerVC: UIViewController {
    var ShowVC: ShowWhichVC = .homeVC
    var homeVC: HomeVC!
    var leftVC: LeftSidePanelVC!
    var centerController: UIViewController!
    var tag: UITapGestureRecognizer!
    
    var currentState: SlideOutState = .collapsed {
        didSet {
            let shouldShowShadow = currentState != .collapsed
            
            shouldShowShadowForCenterVC(shouldShowShadow)
        }
    }
    
    var isHidden: Bool = false
    let centerPanelExpanedOffset: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initCenter(screen: ShowVC)
    }
    
    func initCenter(screen: ShowWhichVC) {
        var presentingController : UIViewController
        
        ShowVC = screen
        
        if homeVC == nil {
            homeVC = UIStoryboard.homeVC()
            homeVC.delegate = self
        }
        
        presentingController = homeVC
        
        // Make sure not adding multiple same instance
        if let con = centerController {
            con.view.removeFromSuperview()
            con.removeFromParent()
        }
        
        centerController =  presentingController
        
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
}

extension ContainerVC : CenterVCDelegate {
    func addLeftPanelViewController() {
        if leftVC == nil {
            leftVC = UIStoryboard.leftViewController()
            addChildSidePanelViewController(leftVC)
        }
    }
    
    func addChildSidePanelViewController(_ sidePanelController: LeftSidePanelVC) {
        view.insertSubview(sidePanelController.view, at: 0)
        addChild(sidePanelController)
        
        // parent is the container and move the subview into it
        sidePanelController.didMove(toParent: self)
    }
    
    @objc func animateLeftPanel(shouldexpand: Bool) {
        isHidden = !isHidden
        
        if shouldexpand {
            animateStatusBar()
            setupWhiteCoverView()
            currentState = .leftPanelExpanded
            animateCenterPanelXPosition(targetPosition: centerController.view.frame.width - centerPanelExpanedOffset)
        } else {
            animateStatusBar()
            hideWhiteCoverView()
            currentState = .collapsed
            animateCenterPanelXPosition(targetPosition: 0) { (finished) in
                if finished == true {
                    self.currentState = .collapsed
                    self.leftVC = nil
                }
            }
        }
    }
    
    func setupWhiteCoverView() {
        let whiteCoverView =  UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        whiteCoverView.alpha = 0.0
        whiteCoverView.backgroundColor =  UIColor.white
        whiteCoverView.tag = 25
        
        self.centerController.view.addSubview(whiteCoverView)
        whiteCoverView.fadeTo(alphaValue: 0.75, withDuration: 0.2)

        
        // for gesture
        tag = UITapGestureRecognizer(target: self, action: #selector(animateLeftPanel(shouldexpand:)))
        tag.numberOfTapsRequired = 1
        
        self.centerController.view.addGestureRecognizer(tag)
    }
    
    func hideWhiteCoverView() {
        centerController.view.removeGestureRecognizer(tag)
        for subview in self.centerController.view.subviews {
            if subview.tag == 25 {
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0.0
                }) { (finished) in
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    func shouldShowShadowForCenterVC(_ status: Bool) {
        centerController.view.layer.shadowOffset = CGSize(width: 5, height: 5)
        if status == true {
            centerController.view.layer.shadowOpacity = 0.6
        } else {
            centerController.view.layer.shadowOpacity = 0.0
        }
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion:((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func toggleLeftPanel() {
        let notAlreadyExpaned = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpaned {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldexpand: notAlreadyExpaned)
    }
}
private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func leftViewController() -> LeftSidePanelVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftSidePanelVC") as? LeftSidePanelVC
    }
    
    class func homeVC() -> HomeVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
    }
}
