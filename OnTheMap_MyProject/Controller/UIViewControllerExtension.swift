//
//  UIViewControllerExtension.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/2/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import UIKit

extension UIViewController {
    func displayErrorMessage(errorTitle: String, errorMessage: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openExternalLink(_ url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            displayErrorMessage(errorTitle: "Error", errorMessage: "Not a valid website/URL")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
}
