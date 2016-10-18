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
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var lineLabel2: UILabel!
    @IBOutlet weak var spotifyLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var recentVotesLabel: UILabel!
    @IBOutlet weak var favArtistsLabel: UILabel!
    @IBOutlet weak var favArtistsTextView: UITextView!
    @IBOutlet weak var favGenresTextView: UITextView!
    
    var checkIns = [Establishment]()
    var votedSongs = [Track]()
    var requestedSongs = [Track]()
    var profileId: String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let userProfileId = profileId {
            editProfileButton.hidden = true
            logOutButton.hidden = true
            backButton.hidden = false
            
            loadProfile(userProfileId)
        }
        else {
            loadProfile("me")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineLabel.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1).CGColor
        lineLabel.layer.borderWidth = 3.0
        lineLabel2.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1).CGColor
        lineLabel2.layer.borderWidth = 3.0
        favArtistsTextView.textContainerInset = UIEdgeInsetsZero;
        favGenresTextView.textContainerInset = UIEdgeInsetsZero;
    }
    
    
    func loadVotedSongs() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let coverSize = screenWidth/6
        let startYPosition = recentVotesLabel.convertPoint(spotifyLabel.center, toView: self.view)
        let endYPosition = favArtistsTextView.convertPoint(spotifyLabel.center, toView: self.view)
        let rows = (endYPosition.y - startYPosition.y - 20) / coverSize
        
        for i in 0..<Int(rows) {
            for j in 0..<6 {
                if (i*5+j < self.votedSongs.count) {
                    if let cover = self.votedSongs.reverse()[i*5+j].cover {
                        let imageView = UIImageView(image: cover)
                        imageView.frame = CGRect(x: CGFloat(j)*coverSize, y: startYPosition.y+20+CGFloat(i)*coverSize, width: coverSize, height: coverSize)
                        view.addSubview(imageView)
                    }
                }
            }
        }
    }
    
    func downloadImage (imageUrl: String, completion: (UIImage) -> ()) {
        Alamofire.request(.GET, imageUrl).response() {
            (_, _, data, _) in
            if let imageData = data {
                let image = UIImage(data: imageData)
                completion(image!)
            }
        }
    }
    
    func loadImages() {
        for track in self.votedSongs {
            if let coverUri = track.coverUri {
                self.downloadImage(coverUri) { image in
                    track.cover = image
                    self.loadVotedSongs()
                }
            }
        }
    }
    
    func loadProfile (userProfileId: String) {
        
        let defaults = NSUserDefaults.standardUserDefaults()

        if (userProfileId == "me") {
            
            if let data = defaults.objectForKey("user_profile") as? NSData {
                let savedUserProfile = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! UserProfile
                
                usernameLabel.text = savedUserProfile.username
                self.checkInsButton.setTitle(savedUserProfile.checkedIn, forState: .Normal)
                self.votedSongsButton.setTitle(savedUserProfile.voted, forState: .Normal)
                self.requestedSongsButton.setTitle(savedUserProfile.requested, forState: .Normal)
                self.favArtistsTextView.text = savedUserProfile.favArtists
                self.favGenresTextView.text = savedUserProfile.favGenres
                
                if savedUserProfile.spotifyUsername.characters.count == 0 {
                    self.spotifyLabel.text = "-"
                }
                else {
                    self.spotifyLabel.text = savedUserProfile.spotifyUsername
                }
                if savedUserProfile.twitterUsername.characters.count == 0 {
                    self.twitterLabel.text = "-"
                }
                else {
                    self.twitterLabel.text = savedUserProfile.twitterUsername
                }
                if savedUserProfile.facebookUsername.characters.count == 0 {
                    self.facebookLabel.text = "-"
                }
                else {
                    self.facebookLabel.text = savedUserProfile.facebookUsername
                }
            }
        }
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.GET, "https://joogpoint.herokuapp.com/profiles/" + userProfileId + "/", headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        
                        var pUrl = json["url"].string!
                        let index = pUrl.startIndex.advancedBy(4)
                        pUrl.insert("s", atIndex: index)
                        
                        let userProfile = UserProfile(url: pUrl, username: json["user"]["username"].string!, email: json["user"]["email"].string!, checkedIn: String(json["user"]["checked_in"].array!.count), voted: String(json["user"]["voted"].array!.count), requested: String(json["user"]["requested"].array!.count), myEstablishments: json["user"]["owner_of"].array!.count, spotifyUsername: json["spotify_username"].string!, facebookUsername: json["facebook_username"].string!, twitterUsername: json["twitter_username"].string!, favArtists: json["fav_artists"].string!, favGenres: json["fav_genres"].string!)
                        
                        if (userProfileId != "me") {
                            self.usernameLabel.text = userProfile.username
                            if userProfile.spotifyUsername.characters.count == 0 {
                                self.spotifyLabel.text = "-"
                            }
                            else {
                                self.spotifyLabel.text = userProfile.spotifyUsername
                            }
                            if userProfile.twitterUsername.characters.count == 0 {
                                self.twitterLabel.text = "-"
                            }
                            else {
                                self.twitterLabel.text = userProfile.twitterUsername
                            }
                            if userProfile.facebookUsername.characters.count == 0 {
                                self.facebookLabel.text = "-"
                            }
                            else {
                                self.facebookLabel.text = userProfile.facebookUsername
                            }
                        }
                        
                        self.checkInsButton.setTitle(userProfile.checkedIn, forState: .Normal)
                        self.votedSongsButton.setTitle(userProfile.voted, forState: .Normal)
                        self.requestedSongsButton.setTitle(userProfile.requested, forState: .Normal)
                        self.favArtistsTextView.text = userProfile.favArtists
                        self.favGenresTextView.text = userProfile.favGenres
                        
                        if (userProfileId == "me") {
                            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(userProfile)
                            defaults.removeObjectForKey("user_profile")
                            defaults.setObject(encodedData, forKey: "user_profile")
                            
                            defaults.synchronize()
                        }
                        
                        self.checkIns.removeAll()
                        self.votedSongs.removeAll()
                        self.requestedSongs.removeAll()
                        
                        for (_, subJson):(String, JSON) in json["user"]["checked_in"] {
                            self.checkIns.append(Establishment(url: subJson["url"].string!, name: subJson["name"].string!, address: subJson["address"].string!, postcode: subJson["postcode"].string!, city: subJson["city"].string!, country: subJson["country"].string!, coordinate: CLLocationCoordinate2D(latitude: subJson["latitude"].double!, longitude: subJson["longitude"].double!), playlistUrl: subJson["establishment_playlist"].string!))
                        }
                        
                        for (_, subJson):(String, JSON) in json["user"]["voted"] {
                            self.votedSongs.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!, establishment: subJson["establishment"].string!, coverUri: subJson["cover_image_url"].string!))
                        }
                        
                        for (_, subJson):(String, JSON) in json["user"]["requested"] {
                            self.requestedSongs.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!, establishment: subJson["establishment"].string!, coverUri: subJson["cover_image_url"].string!))
                        }
                        
                        self.loadImages()
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
    
    @IBAction func backToVotersOrEstablishment(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func logOut(sender: UIButton) {
        do {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.removeObjectForKey("user_profile")
            
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