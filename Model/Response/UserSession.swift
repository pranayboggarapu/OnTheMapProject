//
//  UserSession.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 7/31/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import Foundation

struct UserSession: Codable {
    var sessionId: String
    var expirationTime: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "id"
        case expirationTime = "expiration"
    }
}
