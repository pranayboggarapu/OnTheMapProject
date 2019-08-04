//
//  LoginViewController.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 7/30/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    //MARK:- Outlets declaration
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var signUpCompleteLabel: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //for curved buttons
        loginButton.layer.cornerRadius = 5
        setupSignUpLink()
        
        setLoggingIn(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //an extra check to ensure logged out user wont see the details again
        userNameTextField.text = ""
        passwordTextField.text = ""
    }
    //MARK:- Login method
    @IBAction func handleLogin(_ sender: Any) {
        setLoggingIn(true)
        //details missing
        if userNameTextField.text == "" || passwordTextField.text == "" {
            setLoggingIn(false)
            displayErrorMessage(errorTitle: "Missing Credentials!!", errorMessage: "UserName/Password not entered.")
            return
        }
        //call the service to validate login details
        UdacityAPIClient.validateLogin(userName: userNameTextField.text!, password: passwordTextField.text!, completionHandler: validateLoginResponse)
    }
    
    //MARK:- showing/hiding the activity view
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        userNameTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
    }
    
    //MARK:- Method to handle the login service response
    func validateLoginResponse(success: Bool, loginOutput: LoginOutput?, error: Error?) {
        //service success
        if success {
            //If user isn't registered
            if !(loginOutput?.account.isUserRegistered)! {
                DispatchQueue.main.async {
                    self.setLoggingIn(false)
                    self.displayErrorMessage(errorTitle: "UnRegistered User", errorMessage: "User not registered")
                }
            }
            //User authenticated successfully, so getting the user details
            UdacityAPIClient.getLoggedInStudentDetails(UdacityAPIClient.UserAuth.accountId, completionHandler: handleUserDetailsFetchResponse(_:error:))
            DispatchQueue.main.async {
                self.setLoggingIn(false)
                self.userNameTextField.text = ""
                self.passwordTextField.text = ""
                //redirect to next screen
                self.performSegue(withIdentifier: "loginSuccessfull", sender: nil)
            }

        } else if error != nil && !success  {
            //service failure
            DispatchQueue.main.async {
                self.setLoggingIn(false)
                self.displayErrorMessage(errorTitle: "Error!!", errorMessage: "A network error occured. Please try again!!")
            }
        } else {
            DispatchQueue.main.async {
                self.setLoggingIn(false)
                self.displayErrorMessage(errorTitle: "Error!!", errorMessage: "Username/password incorrect. Please try again!!")
            }
        }
    }
    //MARK:- Method to handle Fetching the user details response
    func handleUserDetailsFetchResponse(_ success: Bool, error: Error?) {
        if !success {
            DispatchQueue.main.async {
                self.setLoggingIn(false)
                self.displayErrorMessage(errorTitle: "Error!!", errorMessage: "Unable to fetch user details")
            }
            
        }
    }
}

//MARK:- TextViewDelegate extension to support Sign UP
extension LoginViewController: UITextViewDelegate {
    
    //setting up the sign up link
    func setupSignUpLink() {
        let displayString = "Don't have an account? Sign Up"
        let attributedString = NSMutableAttributedString(string: displayString)
        attributedString.addAttribute(.link, value: Endpoints.signupUser.stringValue, range: NSRange(location: 23, length: 7))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: displayString.count))
        signUpCompleteLabel.attributedText = attributedString
    }
    
    //tapping functionality
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
}

