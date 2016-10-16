//
//  Track.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 31/08/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import Foundation
import UIKit

class Track {
    var id : Int?
    let title : String
    let artist : String
    var votes : Int?
    var order : Int?
    var requestUserId: Int?
    var establishment : String?
    var cover : UIImage?
    var isExplicit : Bool?
    var spotifyUri : String?
    var coverUri: String?
    
    init (id: Int? = nil, title: String, artist: String, votes: Int? = nil, order: Int? = nil, requestUserId: Int? = nil, establishment: String? = nil, cover: UIImage? = nil, isExplicit: Bool? = nil, spotifyUri: String? = nil, coverUri: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.votes = votes
        self.establishment = establishment
        self.order = order
        self.requestUserId = requestUserId
        self.cover = cover
        self.isExplicit = isExplicit
        self.spotifyUri = spotifyUri
        self.coverUri = coverUri
    }
}