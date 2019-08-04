//
//  UdacityEndPoints.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/4/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import Foundation

enum Endpoints {
    static let base = "https://onthemap-api.udacity.com/v1/"
    
    case validateLoginViaPOST
    case getListOfStudentLocations
    case getLoggedInUserDetails(String)
    case postStudentDetails
    case logOutUser
    case signupUser
    
    
    var stringValue: String {
        switch self {
        case .validateLoginViaPOST: return Endpoints.base + "session"
        case .getListOfStudentLocations: return Endpoints.base + "StudentLocation?order=-updatedAt"
        case .getLoggedInUserDetails(let userKey): return Endpoints.base + "users/\(userKey)"
        case .postStudentDetails: return Endpoints.base + "StudentLocation"
        case .logOutUser: return Endpoints.base + "session"
        case .signupUser: return "https://www.udacity.com/account/auth#!/signup"
        }
    }
    
    var url: URL {
        return URL(string: stringValue)!
    }
}
