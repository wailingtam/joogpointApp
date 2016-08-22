//
//  Establishment.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 21/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import Foundation

class Establishment {
    var id : Int
    var name : String
    var address : String
    var postcode : String
    var city : String
    
    init(id: Int, name: String, address: String, postcode: String, city: String) {
        self.id = id
        self.name = name
        self.address = address
        self.postcode = postcode
        self.city = city
    }
}