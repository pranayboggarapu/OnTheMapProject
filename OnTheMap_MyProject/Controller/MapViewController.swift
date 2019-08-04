//
//  MapViewController.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/3/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var finishButton: UIButton!
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var userLocationEntered: String = ""
    
    var userURLEntered: String = ""
    
    var location: CLLocation = CLLocation()
    
    var annotations: [MKPointAnnotation] = []
    
    
    override func viewDidLoad() {
        print("Map View Controller loaded")
        super.viewDidLoad()
        finishButton.layer.cornerRadius = 5
        mkMapView.showsUserLocation = true
        mkMapView.delegate = self
        
        self.mkMapView.addAnnotations(annotations)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)

        mkMapView.setRegion(region, animated: true)
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mkMapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
//            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func finishLocationCreation(_ sender: Any){
    
        //IMPLEMENT POST CALL
        UdacityAPIClient.postLocation(userLocation: userLocationEntered, mediaURL: userURLEntered, location: location, completionHandler: handlePostLocationResponse(_:_:_:))
        
    }
    
    func handlePostLocationResponse(_ successFul: Bool, _ response: StudentLocationPostResponse?, _ error: Error?) {
        if !successFul {
            DispatchQueue.main.async {
                
                self.displayErrorMessage(errorTitle: "Error", errorMessage: "Unable to post user's location, Please try again after sometime!!")
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
   
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
//            if let toOpen = view.annotation?.subtitle! {
//                app.openURL(URL(string: toOpen)!)
//            }
            print("Im tapped")
        }
    }
    
    
}
