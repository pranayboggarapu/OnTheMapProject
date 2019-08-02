//
//  UdacityAPIClient.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 7/31/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import Foundation

class UdacityAPIClient {
    
    struct UserAuth {
        static var accountId = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case validateLoginViaPOST
        
        var stringValue: String {
            switch self {
            case .validateLoginViaPOST: return Endpoints.base + "session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForPOSTRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: String, completion: @escaping (ResponseType?, Error?) -> Void) {
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
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
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
        print(requestBody)
        taskForPOSTRequest(url: Endpoints.validateLoginViaPOST.url, responseType: LoginOutput.self, body: requestBody) { (response, error) in
            if let response = response {
                completionHandler(true, response, nil)
                return
            }
            completionHandler(false, nil, error)
        }
    }
    
}
