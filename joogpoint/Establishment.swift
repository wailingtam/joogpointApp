//
//  Establishment.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 21/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import Foundation
import MapKit

class Establishment: NSObject, MKAnnotation {
    let url : String
    let title : String?
    let address : String
    let postcode : String
    let city : String
    let coordinate: CLLocationCoordinate2D
    var playlistUrl : String?
    
    init(url: String, name: String, address: String, postcode: String, city: String, coordinate: CLLocationCoordinate2D, playlistUrl: String? = nil) {
        self.url = url
        self.title = name
        self.address = address
        self.postcode = postcode
        self.city = city
        self.coordinate = coordinate
        
        if let pUrl = playlistUrl {
            var url = pUrl
            let index = url.startIndex.advancedBy(4)
            url.insert("s", atIndex: index)
            self.playlistUrl = url
        }
        else {
           self.playlistUrl = playlistUrl
        }
        
        super.init()
    }
    
    var subtitle: String? {
        return address
    }


}
 