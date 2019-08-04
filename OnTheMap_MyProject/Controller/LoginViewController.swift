//
//  LoginViewController.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 7/30/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var signUpCompleteLabel: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 5
        setupSignUpLink()
        
        setLoggingIn(false)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func handleLogin(_ sender: Any) {
        print("handle login called")
        setLoggingIn(true)
        if userNameTextField.text == "" || passwordTextField.text == "" {
            setLoggingIn(false)
            displayErrorMessage(errorTitle: "Missing Credentials!!", errorMessage: "UserName/Password not entered.")
            return
        }
        UdacityAPIClient.validateLogin(userName: userNameTextField.text!, password: passwordTextField.text!, completionHandler: validateLoginResponse)
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        userNameTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signUpCompleteLabel.isEditable = !loggingIn
    }
    
    func validateLoginResponse(success: Bool, loginOutput: LoginOutput?, error: Error?) {
        if success {
            if !(loginOutput?.account.isUserRegistered)! {
                DispatchQueue.main.async {
                    self.setLoggingIn(false)
                    self.displayErrorMessage(errorTitle: "UnRegistered User", errorMessage: "User not registered")
                }
            }
            print("User successfully authenticated")
            UdacityAPIClient.getLoggedInStudentDetails(UdacityAPIClient.UserAuth.accountId, completionHandler: handleUserDetailsFetchResponse(_:error:))
            DispatchQueue.main.async {
                self.setLoggingIn(false)
                self.performSegue(withIdentifier: "loginSuccessfull", sender: nil)
            }

        } else {
            DispatchQueue.main.async {
                self.setLoggingIn(false)
                self.displayErrorMessage(errorTitle: "Error!!", errorMessage: "An unforeseen error occured. Please try again.")
            }
        }
    }
    
    func handleUserDetailsFetchResponse(_ success: Bool, error: Error?) {
        if success {
            print("User Details successfully fetched")
        } else {
            DispatchQueue.main.async {
                self.setLoggingIn(false)
                self.displayErrorMessage(errorTitle: "Error!!", errorMessage: "Unable to fetch user details")
            }
            
        }
    }
}

extension LoginViewController: UITextViewDelegate {
    
    func setupSignUpLink() {
        let displayString = "Don't have an account? Sign Up"
        let attributedString = NSMutableAttributedString(string: displayString)
        attributedString.addAttribute(.link, value: "https://www.hackingwithswift.com", range: NSRange(location: 23, length: 7))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: displayString.count))
        signUpCompleteLabel.attributedText = attributedString
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
}

