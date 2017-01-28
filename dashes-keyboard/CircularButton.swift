//
//  CircularButton.swift
//  d-a-s-h-e-s
//
//  Created by Kacy James on 1/23/17.
//  Copyright © 2017 Student Driver. All rights reserved.
//

import UIKit

@IBDesignable class CircularButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 50.0 {
        didSet {
            setupView()
        }
    }
}

extension CircularButton {
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView() {
        layer.cornerRadius = cornerRadius
        // layer.borderWidth = 5.0
        // layer.borderColor = UIColor.black.cgColor
    }
}