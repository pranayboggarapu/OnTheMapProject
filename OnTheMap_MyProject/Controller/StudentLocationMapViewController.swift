//
//  StudentLocationMapViewController.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/1/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationMapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    //MARK:- Variables
    var annotations: [MKPointAnnotation] = []
    
    var students: StudentList?
    
    
    //MARK:- View load and appear
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchListOfStudents()
        navigationItem.title = "On the Map"
        addNavBarButtons()
        mkMapView.showsUserLocation = true
        mkMapView.delegate = self
        setLoading(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshButtonPressed()
    }
    
    //MARK:- Get List of students
    func fetchListOfStudents() {
        UdacityAPIClient.getListOfStudentLocations(completionHandler: handleFetchStudentsListResponse)
    }
    
    //MARK:- handle Fetch students list response
    func handleFetchStudentsListResponse(success: Bool, students: StudentList?, error: Error?) {
        if success {
            self.students = students
            generateAnnotations()
            DispatchQueue.main.async {
                self.setLoading(false)
                self.mkMapView.addAnnotations(self.annotations)
            }
            
            
        } else {
            DispatchQueue.main.async {
                self.setLoading(false)
                self.displayErrorMessage(errorTitle: "Error!!", errorMessage: "An unforeseen error occured. Please try again.")
            }
        }
        
    }
    
    //MARK:- Generate Annotations
    func generateAnnotations() {
        annotations = []
        for dictionary in (students?.studentsList)! {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(dictionary.latitude )
            let long = CLLocationDegrees(dictionary.longitude )
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //MARK:- MapView tap functionality
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                openExternalLink(toOpen)
            }
        }
    }
    
    //MARK:- Refresh button press
    override func refreshButtonPressed() {
        setLoading(true)
        fetchListOfStudents()
    }
    
    //MARK:- Logout functionality
    override func logOutButtonPressed() {
        setLoading(true)
        UdacityAPIClient.logOutUser { (success, error) in
            if success {
                //if success, dismiss the window
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                DispatchQueue.main.async {
                    //if failed, show the error
                    self.setLoading(false)
                    self.displayErrorMessage(errorTitle: "Error", errorMessage: "Unable to logout. Please try again!!")
                }
                
            }
        }
    }
    
    //MARK:- Spinner functionality
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
    
}
