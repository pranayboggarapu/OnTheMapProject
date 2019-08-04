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
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    var annotations: [MKPointAnnotation] = []
    
    var students: StudentList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchListOfStudents()
        navigationItem.title = "On the Map"
        addNavBarButtons()
        print("Student Location Map View Controller loaded")
        mkMapView.showsUserLocation = true
        mkMapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
            refreshButtonPressed()
    }
    
    func fetchListOfStudents() {
        UdacityAPIClient.getListOfStudentLocations(completionHandler: handleFetchStudentsListResponse)
        
    }
    
    func handleFetchStudentsListResponse(success: Bool, students: StudentList?, error: Error?) {
        if success {
            self.students = students
            generateAnnotations()
            self.mkMapView.addAnnotations(annotations)
            
        } else {
            displayErrorMessage(errorTitle: "Error!!", errorMessage: "An unforeseen error occured. Please try again.")
        }
        
    }
    
    func generateAnnotations() {
        annotations = []
        for dictionary in (students?.studentsList)! {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(dictionary.latitude as! Double)
            let long = CLLocationDegrees(dictionary.longitude as! Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.firstName as! String
            let last = dictionary.lastName as! String
            let mediaURL = dictionary.mediaURL as! String
            print("Value \(dictionary.mediaURL)")
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                openExternalLink(toOpen)
            }
        }
    }
    
    override func refreshButtonPressed() {
        fetchListOfStudents()
    }
    
    override func logOutButtonPressed() {
        UdacityAPIClient.logOutUser { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                DispatchQueue.main.async {
                    self.displayErrorMessage(errorTitle: "Error", errorMessage: "Unable to logout. Please try again!!")
                }
                
            }
        }
    }
    
    override func addButtonPressed() {
        print("Add button Pressed in Student Table View Location controller")
        let addStudentLocationViewController = AddLocationViewController()
        performSegue(withIdentifier: "addLocationFromMap", sender: nil)
    }
    
}
