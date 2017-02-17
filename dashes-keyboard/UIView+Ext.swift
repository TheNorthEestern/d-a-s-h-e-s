//
//  UIView+Ext.swift
//  d-a-s-h-e-s
//
//  Created by Kacy James on 2/14/17.
//  Copyright © 2017 Student Driver. All rights reserved.
//

import UIKit

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        UIView.animate(withDuration: 1.0) {
            let originalBgColor = self.backgroundColor
            self.backgroundColor = UIColor.red
            self.backgroundColor = originalBgColor
        }
        layer.add(animation, forKey: "shake")
        
    }
}
