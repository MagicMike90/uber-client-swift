//
//  RoundedConnerTextField.swift
//  uber-clone
//
//  Created by Michael Luo on 25/4/19.
//  Copyright © 2019 Michael Luo. All rights reserved.
//

import UIKit

class RoundedConnerTextField: UITextField {

    var textRectOffset: CGFloat = 20

    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + textRectOffset, y: bounds.origin.y, width: bounds.width - textRectOffset, height: bounds.height )
    }

    // it is compulsory
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
           return CGRect(x: bounds.origin.x + textRectOffset, y: bounds.origin.y, width: bounds.width - textRectOffset, height: bounds.height )
    }
}
