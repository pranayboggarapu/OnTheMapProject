//
//  NavBarExtension.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/1/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addNavBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: .done, target: self, action: #selector(logOutButtonPressed))
        self.navigationController?.navigationBar.tintColor = UIColor(red: 30/255, green: 180/255, blue: 226/255, alpha: 1)
        let refreshButtonItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "icon_refresh"), style: .done, target: self, action: #selector(refreshButtonPressed))
        let addButtonItem = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "icon_addpin"), style: .done, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButtonItem, refreshButtonItem]
    }
    
    @objc func logOutButtonPressed() {
        print("Logout Button Pressed")
    }
    
    @objc func refreshButtonPressed() {
        print("Logout Button Pressed")
    }
    
    @objc func addButtonPressed() {
        performSegue(withIdentifier: "addLocationFromMap", sender: nil)
    }
}
