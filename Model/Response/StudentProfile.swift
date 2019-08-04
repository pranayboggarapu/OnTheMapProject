//
//  StudentProfile.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/3/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import Foundation

struct StudentProfile: Codable {
    let firstName: String
    let lastName: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
    }
    
}
