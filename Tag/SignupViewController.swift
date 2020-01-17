//
//  SignupViewController.swift
//  Tag
//
//  Created by Eugene L. on 17/1/20.
//  Copyright © 2020 ARandomDeveloper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFunctions

class SignupViewController: UIViewController {
    
    @IBOutlet weak var GradientView: UIView!
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var HeaderContainer: UIView!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ReentryTextField: UITextField!
    @IBOutlet weak var SignupContainer: UIView!
    @IBOutlet weak var SignupButton: UIButton!
    
    @IBAction func tappedOut(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func clickedSignUp(_ sender: Any) {
        
        let functions = Functions.functions()
        
        guard let username = UsernameTextField.text else {
            self.presentSimpleAlert(title: "No username", message: "Please enter a username", btnMsg: "Ok")
            return
        }
        guard let email = EmailTextField.text else {
            self.presentSimpleAlert(title: "No email", message: "Please enter a valid email address", btnMsg: "Ok")
            return
        }
        guard let password = PasswordTextField.text else {
            self.presentSimpleAlert(title: "No password", message: "Please enter a password", btnMsg: "Ok")
            return
        }
        guard let reentry = ReentryTextField.text else {
            self.presentSimpleAlert(title: "No password", message: "Please enter your password again", btnMsg: "Ok")
            return
        }
        
        if password == reentry {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error == nil {
                    // No error, proceed
                    functions.httpsCallable("giveUsername").call(["text": username]) { (result, error) in
                        if let error = error as NSError? {
                            if error.domain == FunctionsErrorDomain {
                                let code = FunctionsErrorCode(rawValue: error.code)
                                let message = error.localizedDescription
                                let details = error.userInfo[FunctionsErrorDetailsKey]
                                print(code as Any, message, details as Any)
                            }
                        }
                    }
                    let alert = UIAlertController(title: "Sign up successful!", message: "Your account has been created and is ready for use! :D", preferredStyle: .alert)
                    alert.addAction(.init(title: "Let's go!", style: .default, handler: { (result) in
                        self.signOut()
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let errorCode = error?._code {
                        if let authError = AuthErrorCode(rawValue: errorCode) {
                            self.handleAuthError(error: authError)
                        }
                    }
                }
            }
        } else {
            self.presentSimpleAlert(title: "Passwords Not Matching", message: "Both passwords should match!", btnMsg: "Ok")
            PasswordTextField.text = ""
            ReentryTextField.text = ""
            return
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Inits
        ContainerView.dropShadow(radius: 5, widthOffset: 0, heightOffset: 0)
        UsernameTextField.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        EmailTextField.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        PasswordTextField.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        ReentryTextField.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        SignupContainer.dropShadow(radius: 3, widthOffset: 0, heightOffset: 0)
        
        HeaderContainer.layer.cornerRadius = 10
        ContainerView.layer.cornerRadius = 10
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
