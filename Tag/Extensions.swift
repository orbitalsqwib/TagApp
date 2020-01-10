//
//  Extensions.swift
//  Tag
//
//  Created by Eugene L. on 7/1/20.
//  Copyright © 2020 ARandomDeveloper. All rights reserved.
//

import UIKit

extension UIView {

    func dropShadow(radius: Int, widthOffset: Int, heightOffset: Int) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: widthOffset, height: heightOffset)
        self.layer.shadowRadius = CGFloat(radius)
        //self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale

    }
    
    func constraint(withIdentifier: String) -> NSLayoutConstraint? {
        return self.constraints.filter { $0.identifier == withIdentifier }.first
    }
}
