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
    
    struct UserAuth {
        static var accountId = ""
        static var sessionId = ""
        static var firstName = ""
        static var lastName = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case validateLoginViaPOST
        case getListOfStudentLocations
        case getLoggedInUserDetails(String)
        case postStudentDetails
        case logOutUser
        
        
        var stringValue: String {
            switch self {
            case .validateLoginViaPOST: return Endpoints.base + "session"
            case .getListOfStudentLocations: return Endpoints.base + "StudentLocation?order=-updatedAt"
            case .getLoggedInUserDetails(let userKey): return Endpoints.base + "users/\(userKey)"
            case .postStudentDetails: return Endpoints.base + "StudentLocation"
            case .logOutUser: return Endpoints.base + "session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForPOSTRequest<ResponseType: Decodable>(url: URL, subsetResponseData: Bool, responseType: ResponseType.Type, body: String, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                var range: Range = Range(0..<data.count)
                var newData: Data = data
                if subsetResponseData {
                    range = Range(5..<data.count)
                    newData = data.subdata(in: range)
                }
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    class func validateLogin(userName: String, password: String, completionHandler: @escaping (Bool, LoginOutput?, Error?) -> Void) {
        var requestBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        taskForPOSTRequest(url: Endpoints.validateLoginViaPOST.url, subsetResponseData: true , responseType: LoginOutput.self, body: requestBody) { (response, error) in
            if let response = response {
                UserAuth.sessionId = response.session.sessionId
                UserAuth.accountId = response.account.userKey
                
                completionHandler(true, response, nil)
                return
            }
            completionHandler(false, nil, error)
        }
    }
    
    class func postLocation(userLocation: String, mediaURL: String, location: CLLocation, completionHandler: @escaping (Bool, StudentLocationPostResponse?, Error?) -> Void) {
        var requestBody = "{\"uniqueKey\": \"\(UserAuth.accountId)\", \"firstName\": \"\(UserAuth.firstName)\", \"lastName\": \"\(UserAuth.lastName)\",\"mapString\": \"\(userLocation)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(location.coordinate.latitude), \"longitude\": \(location.coordinate.longitude)}"
        
        taskForPOSTRequest(url: Endpoints.postStudentDetails.url, subsetResponseData: false, responseType: StudentLocationPostResponse.self, body: requestBody) { (response, error) in
            if let response = response {
                completionHandler(true, response, nil)
                return
            }
            completionHandler(false, nil, error)
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (Bool,ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                print(newData)
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(true, responseObject, nil)
                }
            } catch {
                print(error)
                completion(false, nil, error)
            }
        }
        task.resume()
    }
    
    class func getListOfStudentLocations(completionHandler: @escaping (Bool,StudentList?,Error?) -> Void) {
       taskForGETRequest(url: UdacityAPIClient.Endpoints.getListOfStudentLocations.url, responseType: StudentList.self, completion: completionHandler)
    }
    
    class func getLoggedInStudentDetails(_ userKey: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: UdacityAPIClient.Endpoints.getLoggedInUserDetails(userKey).url)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                let json = try JSONSerialization.jsonObject(with: newData, options: []) as! [String: Any]
                UserAuth.firstName = json["first_name"] as! String
                UserAuth.lastName = json["last_name"] as! String
                completionHandler(true,nil)
            } catch {
                print("Error")
                completionHandler(false,error)
            }
        }
        task.resume()
        
    }
    
    
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
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            completionHandler(true,nil)
        }
        task.resume()
    }
    
}
