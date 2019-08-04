//
//  StudentList.swift
//  OnTheMap_MyProject
//
//  Created by Pranay Boggarapu on 8/2/19.
//  Copyright © 2019 Pranay Boggarapu. All rights reserved.
//

import Foundation

struct StudentList : Codable {
    var studentsList: [StudentDetails]
    enum CodingKeys: String, CodingKey {
        case studentsList = "results"
    }
}


