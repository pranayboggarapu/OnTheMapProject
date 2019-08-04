//
//  AddLocationViewController.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/2/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//


import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    
    //MARK:- Outlets
    @IBOutlet weak var activityViewIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var studentNameTextField: UITextField!
    
    @IBOutlet weak var findLocationButton: UIButton!
    
    //MARK:- Variables
    var geocoder = CLGeocoder()
    
    var userLocation = CLLocation()
    
    let annotation = MKPointAnnotation()
    
    //MARK:- View didload
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Location"
        addCancelNavBarButton()
        findLocationButton.layer.cornerRadius = 5
        setPosting(false)
    }
    
    //MARK: Add Nav button
    func addCancelNavBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed))
        self.navigationController?.navigationBar.tintColor = UIColor(red: 30/255, green: 180/255, blue: 226/255, alpha: 1)
    }
    
    //MARK: Handle find location
    @IBAction func findLocationPressed(_ sender: Any) {
        if validateAllDetailsEntered() {
            geoCodeUserLocation()
        }
    }
    
    //MARK: Geocoding the value
    func geoCodeUserLocation() {
        setPosting(true)
        geocoder.geocodeAddressString(studentNameTextField.text!) {(placemarks, error) in
            if self.processResponse(withPlacemarks: placemarks, error: error) {
                DispatchQueue.main.async {
                    self.setPosting(false)
                    let mapViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
                    mapViewController.location = self.userLocation
                    mapViewController.userLocationEntered = self.studentNameTextField.text!
                    mapViewController.userURLEntered = self.urlTextField.text!
                    mapViewController.annotations.append(self.annotation)
                    self.navigationController?.pushViewController(mapViewController, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.setPosting(false)
                    self.displayErrorMessage(errorTitle: "Error", errorMessage: "Unable to find the place you entered!!")
                }
            }
        }
    }
    
    //MARK: Client side error messaging for missing values
    func validateAllDetailsEntered() -> Bool {
        if studentNameTextField.text! == "" || urlTextField.text! == "" {
            displayErrorMessage(errorTitle: "Missing Details", errorMessage: "Location/URL details missing, please re-enter")
            return false
        }
        return true
    }
    
    //MARK:- Process the Forward geocode response
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) -> Bool {
        if let _ = error {
            displayErrorMessage(errorTitle: "Error", errorMessage: "Unable to find the place you entered!!")
            return false
            
        } else {
            var location: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                annotation.coordinate = coordinate
                annotation.title = studentNameTextField.text!
                self.userLocation = location
                return true
            }
            return false
        }
    }
    
    //MARK:- Cancel button functionality
    @objc func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Animating
    func setPosting(_ isPosting: Bool) {
        if isPosting {
            activityViewIndicator.startAnimating()
        } else {
            activityViewIndicator.stopAnimating()
        }
        urlTextField.isEnabled = !isPosting
        studentNameTextField.isEnabled = !isPosting
        findLocationButton.isEnabled = !isPosting
    }
}
