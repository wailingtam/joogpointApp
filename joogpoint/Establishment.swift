//
//  Establishment.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 21/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import Locksmith
import SwiftyJSON

class Establishment: NSObject, MKAnnotation {
    let url : String
    var title : String?
    var address : String
    var postcode : String
    var city : String
    var country : String
    var coordinate: CLLocationCoordinate2D
    var spotify : String?
    var lastfm : String?
    var playlistUrl : String?
    
    init(url: String, name: String, address: String, postcode: String, city: String, country: String, coordinate: CLLocationCoordinate2D, spotify: String? = nil, lastfm: String? = nil, playlistUrl: String? = nil) {
        self.title = name
        self.address = address
        self.postcode = postcode
        self.city = city
        self.country = country
        self.coordinate = coordinate
        self.spotify = spotify
        self.lastfm = lastfm
        
        var eUrl = url
        let index = eUrl.startIndex.advancedBy(4)
        eUrl.insert("s", atIndex: index)
        self.url = eUrl
        
        if var pUrl = playlistUrl {
            let index = pUrl.startIndex.advancedBy(4)
            pUrl.insert("s", atIndex: index)
            self.playlistUrl = pUrl
        }
        else {
           self.playlistUrl = playlistUrl
        }
        
        super.init()
    }
    
    var subtitle: String? {
        return address
    }
    
    func loadEstablishment() {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]

        Alamofire.request(.GET, self.url, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        self.title = json["name"].string!
                        self.address = json["address"].string!
                        self.postcode = json["postcode"].string!
                        self.city = json["city"].string!
                        self.country = json["country"].string!
                        self.coordinate = CLLocationCoordinate2D(latitude: json["latitude"].double!, longitude: json["longitude"].double!)
                        self.spotify = json["spotify_username"].string!
                        self.lastfm = json["lastfm_username"].string!

                    }
                    
                case .Failure(let error):
                    print(error)
                }
                
        }

    }


}
 