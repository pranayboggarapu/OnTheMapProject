//
//  Account.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 7/31/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import Foundation

struct Account: Codable {
    
    var isUserRegistered: Bool
    var userKey: String
    
    enum CodingKeys: String, CodingKey {
        case isUserRegistered = "registered"
        case userKey = "key"
    }
}
