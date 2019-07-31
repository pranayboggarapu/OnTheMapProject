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
    
    @IBOutlet weak var signUpCompleteLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        setupSignUpLink()
        // Do any additional setup after loading the view, typically from a nib.
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

