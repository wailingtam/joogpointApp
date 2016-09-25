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
    var votedSongs = [Track]()
    var requestedSongs = [Track]()
    
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
                        
                        let userProfile = UserProfile(url: json["url"].string!, username: json["user"]["username"].string!, email: json["user"]["email"].string!, checkedIn: String(json["user"]["checked_in"].array!.count), voted: String(json["user"]["voted"].array!.count), requested: String(json["user"]["requested"].array!.count), myEstablishments: json["user"]["owner_of"].array!.count, spotifyUsername: json["spotify_username"].string!, facebookUsername: json["facebook_username"].string!, twitterUsername: json["twitter_username"].string!, favArtists: json["fav_artists"].string!, favGenres: json["fav_genres"].string!)
                        
                        self.checkInsButton.setTitle(userProfile.checkedIn, forState: .Normal)
                        self.votedSongsButton.setTitle(userProfile.voted, forState: .Normal)
                        self.requestedSongsButton.setTitle(userProfile.requested, forState: .Normal)
                        
                        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(userProfile)
                        defaults.setObject(encodedData, forKey: "user_profile")
                        
                        defaults.synchronize()
                        
                        self.checkIns.removeAll()
                        self.votedSongs.removeAll()
                        self.requestedSongs.removeAll()
                        
                        for (_, subJson):(String, JSON) in json["user"]["checked_in"] {
                            self.checkIns.append(Establishment(url: subJson["url"].string!, name: subJson["name"].string!, address: subJson["address"].string!, postcode: subJson["postcode"].string!, city: subJson["city"].string!, country: subJson["country"].string!, coordinate: CLLocationCoordinate2D(latitude: subJson["latitude"].double!, longitude: subJson["longitude"].double!)))
                        }
                        
                        for (_, subJson):(String, JSON) in json["user"]["voted"] {
                            self.votedSongs.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!, establishment: subJson["establishment"].string!))
                        }
                        
                        for (_, subJson):(String, JSON) in json["user"]["requested"] {
                            self.requestedSongs.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!, establishment: subJson["establishment"].string!))
                        }
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }

    }
    
    // MARK: - Navigation
    
    @IBAction func showCheckIns(sender: UIButton) {
        self.performSegueWithIdentifier("ShowCheckIns", sender: self)
    }
    
    @IBAction func showVotedSongs(sender: UIButton) {
        self.performSegueWithIdentifier("ShowVotedSongs", sender: self)
    }
    
    @IBAction func showRequestedSongs(sender: UIButton) {
        self.performSegueWithIdentifier("ShowRequestedSongs", sender: self)
    }
    
    @IBAction func editProfile(sender: UIButton) {
        self.performSegueWithIdentifier("EditUserProfile", sender: self)
    }
    
    @IBAction func logOut(sender: UIButton) {
        do {
            try Locksmith.deleteDataForUserAccount("myUserAccount")
        }
        catch {
        }
        
        self.performSegueWithIdentifier("LogOut", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCheckIns" {
            let nextViewController = segue.destinationViewController as! CheckInsViewController
            nextViewController.checkIns = self.checkIns
        }
        else if segue.identifier == "ShowVotedSongs" {
            let nextViewController = segue.destinationViewController as! VotedSongsViewController
            nextViewController.votedSongs = self.votedSongs
        }
        else if segue.identifier == "ShowRequestedSongs" {
            let nextViewController = segue.destinationViewController as! RequestedSongsViewController
            nextViewController.requestedSongs = self.requestedSongs
        }
    }
}