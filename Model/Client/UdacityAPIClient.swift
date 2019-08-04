//
//  UdacityAPIClient.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 7/31/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import Foundation
import MapKit

class UdacityAPIClient {
    
    //MARK:- User specific details
    
    struct UserAuth {
        static var accountId = ""
        static var sessionId = ""
        static var firstName = ""
        static var lastName = ""
    }
    
    //MARK:- Generic method for Post request
    class func taskForPOSTRequest<ResponseType: Decodable>(url: URL, subsetResponseData: Bool, responseType: ResponseType.Type, body: String, completion: @escaping (ResponseType?, Error?) -> Void) {
        //creating the request body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //making the network call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            //decoding the response
            let decoder = JSONDecoder()
            do {
                var range: Range = Range(0..<data.count)
                var newData: Data = data
                
                //If i have to ignore the first few characters
                if subsetResponseData {
                    range = Range(5..<data.count)
                    newData = data.subdata(in: range)
                }
                
                //decoding the response after success
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                //failure case
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    //MARK: Validate student login details
    class func validateLogin(userName: String, password: String, completionHandler: @escaping (Bool, LoginOutput?, Error?) -> Void) {
        let requestBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        taskForPOSTRequest(url: Endpoints.validateLoginViaPOST.url, subsetResponseData: true , responseType: LoginOutput.self, body: requestBody) { (response, error) in
            if let response = response {
                UserAuth.sessionId = response.session.sessionId
                UserAuth.accountId = response.account.userKey
                
                completionHandler(true, response, nil)
                return
            } else if let errorVar = error {
                //network failure
                guard !errorVar.localizedDescription.contains("Internet connection appears to be offline") else {
                    completionHandler(false,nil,errorVar)
                    return
                }
            }
            completionHandler(false, nil, nil)
        }
    }
    
    //MARK: Post the student's location
    class func postLocation(userLocation: String, mediaURL: String, location: CLLocation, completionHandler: @escaping (Bool, StudentLocationPostResponse?, Error?) -> Void) {
        let requestBody = "{\"uniqueKey\": \"\(UserAuth.accountId)\", \"firstName\": \"\(UserAuth.firstName)\", \"lastName\": \"\(UserAuth.lastName)\",\"mapString\": \"\(userLocation)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(location.coordinate.latitude), \"longitude\": \(location.coordinate.longitude)}"
        
        taskForPOSTRequest(url: Endpoints.postStudentDetails.url, subsetResponseData: false, responseType: StudentLocationPostResponse.self, body: requestBody) { (response, error) in
            if let response = response {
                completionHandler(true, response, nil)
                return
            }
            completionHandler(false, nil, error)
        }
    }
    
    //MARK:- Generic Get Request method
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (Bool,ResponseType?, Error?) -> Void) {
        //creating the task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
                return
            }
            //starting to decode the response
            let decoder = JSONDecoder()
            do {
                //decode the response
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(true, responseObject, nil)
                }
            } catch {
                //in case of failure
                completion(false, nil, error)
            }
        }
        task.resume()
    }
    
    //MARK: Get List of student locations
    class func getListOfStudentLocations(completionHandler: @escaping (Bool,StudentList?,Error?) -> Void) {
       taskForGETRequest(url: Endpoints.getListOfStudentLocations.url, responseType: StudentList.self, completion: completionHandler)
    }
    
    //MARK: Get Logged In Student Details
    class func getLoggedInStudentDetails(_ userKey: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        let request = URLRequest(url: Endpoints.getLoggedInUserDetails(userKey).url)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                let json = try JSONSerialization.jsonObject(with: newData, options: []) as! [String: Any]
                
                //initialize the user firstname and last name.
                UserAuth.firstName = json["first_name"] as! String
                UserAuth.lastName = json["last_name"] as! String
                completionHandler(true,nil)
            } catch {
                completionHandler(false,error)
            }
        }
        task.resume()
        
    }
    
    //MARK:- Logout User.
    class func logOutUser(completionHandler: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.logOutUser.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {// Handle error…
                completionHandler(false,error)
                return
            }
            completionHandler(true,nil)
        }
        task.resume()
    }
    
}
