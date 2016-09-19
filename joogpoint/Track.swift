//
//  Track.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 31/08/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import Foundation

class Track {
    let id: Int
    let title : String
    let artist : String
    var votes : Int?
    var establishment : String?
    
    init(id: Int, title: String, artist: String, votes: Int? = nil, establishment: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.votes = votes
        self.establishment = establishment
    }
}