//
//  AuthViewController.swift
//  Tag
//
//  Created by Eugene L. on 13/1/20.
//  Copyright © 2020 ARandomDeveloper. All rights reserved.
//

import UIKit
import Firebase

class AuthViewController: UIViewController {

    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var SignInHeader: UIView!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var LoginContainer: UIView!
    @IBOutlet weak var SignupContainer: UIView!
    @IBOutlet weak var GradientView: UIView!
    
    @IBAction func tappedOut(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func pressedLogIn(_ sender: Any) {
        
        guard let email = EmailTextField.text else {
            self.presentSimpleAlert(title: "No email", message: "Please enter a valid email address", btnMsg: "Ok")
            return
        }
        guard let password = PasswordTextField.text else {
            self.presentSimpleAlert(title: "No password", message: "Please enter your password", btnMsg: "Ok")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error == nil {
                // No error, proceed
                Auth.auth().currentUser?.getIDTokenResult(completion: { (result, error) in
                    if let role = result?.claims["role"] as? String {
                        if role == "cashier" || role == "company" {
                            self.presentSimpleAlert(title: "Invalid Account", message: "Please sign in with your personal user account and not your work account.", btnMsg: "Continue")
                            self.signOut()
                        }
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            } else {
                if let errorCode = error?._code {
                    if let authError = AuthErrorCode(rawValue: errorCode) {
                        self.handleAuthError(error: authError)
                    }
                }
            }
        }
        
    }
    @IBAction func pressedSignUp(_ sender: Any) {
        self.performSegue(withIdentifier: "presentSignup", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Inits
        ContainerView.dropShadow(radius: 5, widthOffset: 0, heightOffset: 0)
        EmailTextField.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        PasswordTextField.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        LoginContainer.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        SignupContainer.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        
        SignInHeader.layer.cornerRadius = 10
        ContainerView.layer.cornerRadius = 10
        LoginContainer.layer.cornerRadius = 10
        SignupContainer.layer.cornerRadius = 10
        
        GradientView.addGradientBackground(firstColor: .systemPink, secondColor: .white, width: Double(GradientView.bounds.width), height: Double(GradientView.bounds.height))

        // Do any additional setup after loading the view.
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
