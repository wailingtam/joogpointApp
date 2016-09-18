//
//  ProfileViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 7/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
import SwiftyJSON
import MapKit

class UserProfileViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var checkInsButton: UIButton!
    @IBOutlet weak var votedSongsButton: UIButton!
    @IBOutlet weak var requestedSongsButton: UIButton!
    
    var checkIns = [Establishment]()
    var votedTracks = [Track]()
    var requestedTracks = [Track]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func loadProfile() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let data = defaults.objectForKey("user_profile") as? NSData {
            let savedUserProfile = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! UserProfile
            
            usernameLabel.text = savedUserProfile.username
            self.checkInsButton.setTitle(savedUserProfile.checkedIn, forState: .Normal)
            self.votedSongsButton.setTitle(savedUserProfile.voted, forState: .Normal)
            self.requestedSongsButton.setTitle(savedUserProfile.requested, forState: .Normal)
        }
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.GET, "https://joogpoint.herokuapp.com/profiles/me/", headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        
                        let userProfile = UserProfile(url: json["url"].string!, username: json["user"]["username"].string!, checkedIn: String(json["user"]["checked_in"].array!.count), voted: String(json["user"]["voted"].array!.count), requested: String(json["user"]["requested"].array!.count), spotifyUsername: json["spotify_username"].string!, facebookUsername: json["facebook_username"].string!, twitterUsername: json["twitter_username"].string!, favArtists: json["fav_artists"].string!, favGenres: json["fav_genres"].string!)
                        
                        self.checkInsButton.setTitle(userProfile.checkedIn, forState: .Normal)
                        self.votedSongsButton.setTitle(userProfile.voted, forState: .Normal)
                        self.requestedSongsButton.setTitle(userProfile.requested, forState: .Normal)
                        
                        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(userProfile)
                        defaults.setObject(encodedData, forKey: "user_profile")
                        
                        defaults.synchronize()
                        
                        
                        for (_, subJson):(String, JSON) in json["user"]["checked_in"] {
                            self.checkIns.append(Establishment(url: subJson["url"].string!, name: subJson["name"].string!, address: subJson["address"].string!, postcode: subJson["postcode"].string!, city: subJson["city"].string!, coordinate: CLLocationCoordinate2D(latitude: subJson["latitude"].double!, longitude: subJson["longitude"].double!)))
                        }
                        
                        for (_, subJson):(String, JSON) in json["user"]["voted"] {
                            self.votedTracks.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!))
                        }
                        
                        for (_, subJson):(String, JSON) in json["user"]["requested"] {
                            self.requestedTracks.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!))
                        }
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }

    }
}