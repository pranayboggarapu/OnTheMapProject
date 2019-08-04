//
//  StudentLocationTableViewController.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/1/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import UIKit

class StudentLocationTableViewController: UITableViewController {
    
    //MARK:- Variables declaration
    var students: StudentList?

    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    
    //MARK:- View load and appear methods
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.color = UIColor.darkGray
        navigationItem.title = "On the Map"
        addNavBarButtons()
        setLoadingScreen()
        fetchListOfStudents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchListOfStudents()
        tableView.reloadData()
    }
    
    //MARK:- Handle students service response
    func handleFetchStudentsListResponse(success: Bool, students: StudentList?, error: Error?) {
        //when success
        if success {
            self.students = students
            tableView.reloadData()
            self.removeLoadingScreen()
        } else {
            //if fails, display the error
            displayErrorMessage(errorTitle: "Error!!", errorMessage: "An unforeseen error occured. Please try again.")
        }
        
    }
    
    //MARK:- Refresh Button Pressed`
    override func refreshButtonPressed() {
        setLoadingScreen()
        fetchListOfStudents()
        tableView.reloadData()
    }
    
    //MARK:- Get List of students
    func fetchListOfStudents() {
        UdacityAPIClient.getListOfStudentLocations(completionHandler: handleFetchStudentsListResponse)
    }
    
    //MARK:- Logout
    override func logOutButtonPressed() {
        UdacityAPIClient.logOutUser { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                //show error when service call fails
                DispatchQueue.main.async {
                    self.displayErrorMessage(errorTitle: "Error", errorMessage: "Unable to logout. Please try again!!")
                }
                
            }
        }
    }
    
    //MARK:- Set the activity indicator into the main view
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
    
}

//MARK:- TableView Controller to display the data
extension StudentLocationTableViewController {
    
    //number of rows in each setction
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let students = students {
            return students.studentsList.count
        }
        return 0
    }
    
    //height of each row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //cell in each row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userLocationCell", for: indexPath) as! StudentLocationsCell
        
        let firstName = students?.studentsList[indexPath.row].firstName ?? ""
        let lastName = students?.studentsList[indexPath.row].lastName ?? ""
        
        cell.studentName.text =  firstName + lastName
        cell.studentWebsite.text = students?.studentsList[indexPath.row].mediaURL
        cell.studentImageView.image = UIImage(imageLiteralResourceName: "icon_pin")
        return cell
    }
    
    //tap functionality of each cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let toOpen = students?.studentsList[indexPath.row].mediaURL {
            openExternalLink(toOpen)
        }
    }
}
