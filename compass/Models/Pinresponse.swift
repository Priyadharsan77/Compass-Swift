//
//  Pinresponse.swift
//  compass
//
//  Created by Dhars on 2021-04-09.
//  Copyright © 2021 Dhars. All rights reserved.
//

import Foundation

struct Pinresponse: Codable{
    let success: Bool?
    let count: Int?
    let data: [Pin]?
}
