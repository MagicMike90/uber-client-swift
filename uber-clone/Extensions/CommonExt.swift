//
//  CommonExt.swift
//  uber-clone
//
//  Created by Michael Luo on 26/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

extension Notification {
    
    var keyboardSize: CGSize? {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
    }
    
    var keyboardAnimationDuration: Double? {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    }
    
}
