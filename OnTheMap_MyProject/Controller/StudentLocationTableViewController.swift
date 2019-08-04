//
//  StudentLocationTableViewController.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/1/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import UIKit

class StudentLocationTableViewController: UITableViewController {
    
    var students: StudentList?
    
//    var loadingView: UIView = UIView()
    
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    
    override func viewDidLoad() {
        spinner.color = UIColor.darkGray
        super.viewDidLoad()
        tableView.reloadData()
        navigationItem.title = "On the Map"
        addNavBarButtons()
        print("Student Location Table View Controller loaded")
        setLoadingScreen()
        fetchListOfStudents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchListOfStudents()
        tableView.reloadData()
    }
    
    func fetchListOfStudents() {
        
        UdacityAPIClient.getListOfStudentLocations(completionHandler: handleFetchStudentsListResponse)
    }
    
    func handleFetchStudentsListResponse(success: Bool, students: StudentList?, error: Error?) {
        if success {
            self.students = students
            tableView.reloadData()
            self.removeLoadingScreen()
        } else {
            displayErrorMessage(errorTitle: "Error!!", errorMessage: "An unforeseen error occured. Please try again.")
        }
        
    }
    
    override func refreshButtonPressed() {
        setLoadingScreen()
        fetchListOfStudents()
        tableView.reloadData()
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
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 120, height:120))
        spinner.style = .whiteLarge
        spinner.color = UIColor.darkGray
        
        self.spinner.center = CGPoint(x:self.view.center.x, y:self.view.center.y)
    
        spinner.contentMode = .scaleAspectFit
        
        spinner.startAnimating()
        
        
        tableView.addSubview(spinner)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
    }
    
    override func addButtonPressed() {
        print("Add button Pressed in Student Table View Location controller")
        let addStudentLocationViewController = AddLocationViewController()
        performSegue(withIdentifier: "addLocation", sender: nil)
    }
    
}

extension StudentLocationTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let students = students {
            return students.studentsList.count
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userLocationCell", for: indexPath) as! StudentLocationsCell
        
        let firstName = students?.studentsList[indexPath.row].firstName ?? ""
        let lastName = students?.studentsList[indexPath.row].lastName ?? ""
        
        cell.studentName.text =  firstName + lastName
        cell.studentWebsite.text = students?.studentsList[indexPath.row].mediaURL
        cell.studentImageView.image = UIImage(imageLiteralResourceName: "icon_pin")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let toOpen = students?.studentsList[indexPath.row].mediaURL {
            openExternalLink(toOpen)
        }
    }
}
