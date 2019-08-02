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
            displayErrorMessage(errorTitle: "Missing Credentials!!", errorMessage: "UserName/Password not entered.")
            setLoggingIn(false)
            return
        }
        UdacityAPIClient.validateLogin(userName: userNameTextField.text!, password: passwordTextField.text!, completionHandler: validateLoginResponse)
    }
    
    func displayErrorMessage(errorTitle: String, errorMessage: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        setLoggingIn(false)
        if success {
            if !(loginOutput?.account.isUserRegistered)! {
                displayErrorMessage(errorTitle: "UnRegistered User", errorMessage: "User not registered")
            }
            UdacityAPIClient.UserAuth.accountId = (loginOutput?.account.userKey)!
            UdacityAPIClient.UserAuth.sessionId = (loginOutput?.session.sessionId)!
            print("User successfully authenticated")
        } else {
            displayErrorMessage(errorTitle: "Error", errorMessage: "An unforeseen error occured. Please try again!!")
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

