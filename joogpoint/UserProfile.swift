//
//  UserProfile.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 18/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import Foundation

class UserProfile:  NSObject, NSCoding {
    let url : String
    let username : String
    let checkedIn : String
    let voted : String
    let requested : String
    let spotifyUsername : String
    let facebookUsername : String
    let twitterUsername : String
    let favArtists : String
    let favGenres : String
    
    init(url: String, username: String, checkedIn: String, voted: String, requested: String, spotifyUsername: String, facebookUsername: String, twitterUsername: String, favArtists: String, favGenres: String) {
        self.url = url
        self.username = username
        self.checkedIn = checkedIn
        self.voted = voted
        self.requested = requested
        self.spotifyUsername = spotifyUsername
        self.facebookUsername = facebookUsername
        self.twitterUsername = twitterUsername
        self.favArtists = favArtists
        self.favGenres = favGenres
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let url = aDecoder.decodeObjectForKey("url") as! String
        let username = aDecoder.decodeObjectForKey("username") as! String
        let checkedIn = aDecoder.decodeObjectForKey("checkedIn") as! String
        let voted = aDecoder.decodeObjectForKey("voted") as! String
        let requested = aDecoder.decodeObjectForKey("requested") as! String
        let spotifyUsername = aDecoder.decodeObjectForKey("spotifyUsername") as! String
        let facebookUsername = aDecoder.decodeObjectForKey("facebookUsername") as! String
        let twitterUsername = aDecoder.decodeObjectForKey("twitterUsername") as! String
        let favArtists = aDecoder.decodeObjectForKey("favArtists") as! String
        let favGenres = aDecoder.decodeObjectForKey("favGenres") as! String
        
        self.init(url: url, username: username, checkedIn: checkedIn, voted: voted, requested: requested, spotifyUsername: spotifyUsername, facebookUsername: facebookUsername, twitterUsername: twitterUsername, favArtists: favArtists, favGenres: favGenres)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(url, forKey: "url")
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(checkedIn, forKey: "checkedIn")
        aCoder.encodeObject(voted, forKey: "voted")
        aCoder.encodeObject(requested, forKey: "requested")
        aCoder.encodeObject(spotifyUsername, forKey: "spotifyUsername")
        aCoder.encodeObject(facebookUsername, forKey: "facebookUsername")
        aCoder.encodeObject(twitterUsername, forKey: "twitterUsername")
        aCoder.encodeObject(favArtists, forKey: "favArtists")
        aCoder.encodeObject(favGenres, forKey: "favGenres")
    }
    
    
}