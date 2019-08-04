//
//  StudentDetails.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/3/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import Foundation

struct StudentDetails: Codable {
    var createdAt: String
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectId: String
    var userKey: String
    var updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case userKey = "uniqueKey"
        case createdAt
        case firstName
        case lastName
        case latitude
        case longitude
        case mapString
        case mediaURL
        case objectId
        case updatedAt
    }
}
