//
//  Extensions.swift
//  Tag
//
//  Created by Eugene L. on 7/1/20.
//  Copyright © 2020 ARandomDeveloper. All rights reserved.
//

import UIKit
import Firebase

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
    
    // From Robin Vinod 23/11/19, YouthHacks
    func addGradientBackground(firstColor: UIColor, secondColor: UIColor, width: Double, height: Double){
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.35)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

extension UIViewController {
    
    func presentSimpleAlert(title: String, message: String, btnMsg: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                   alert.addAction(.init(title: btnMsg, style: .cancel, handler: nil))
                   self.present(alert, animated: true, completion: nil)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print(signOutError)
        }
    }
    
    func handleAuthError(error: AuthErrorCode) {
        
        switch error {
            
        case .emailAlreadyInUse:
            self.presentSimpleAlert(title: "Email Not Available",
                                    message: "The email you tried to sign up with is already in use. Would you like to log in instead?",
                                    btnMsg: "Continue")
            
        case .invalidEmail:
            self.presentSimpleAlert(title: "Invalid Email",
                                    message: "The email you keyed in was not valid. It should follow the format xxx@xxx.xxx",
                                    btnMsg: "Continue")
            
        case .wrongPassword:
            self.presentSimpleAlert(title: "Wrong Password",
                                    message: "The password you keyed in was incorrect. Try again maybe?",
                                    btnMsg: "Continue")
            
        case .tooManyRequests:
            self.presentSimpleAlert(title: "Too Many Requests",
                                    message: "You keyed in your password incorrectly too many times. Try again in a moment.",
                                    btnMsg: "Continue")
            
        case .userNotFound:
            self.presentSimpleAlert(title: "User Not Found",
                                    message: "We couldn't find the email you tried to log in with. Would you like to sign up instead?",
                                    btnMsg: "Continue")
            
        case .networkError:
            self.presentSimpleAlert(title: "Network Error",
                                    message: "We can't communicate with our servers at the moment. :(",
                                    btnMsg: "Continue")
            
        case .weakPassword:
            self.presentSimpleAlert(title: "Password too weak",
                                    message: "Your password should be at least 6 characters long.",
                                    btnMsg: "Continue")
            
        default: return
        }
    }
    
}
