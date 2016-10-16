//
//  EstablishmentProfileViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 22/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
import SwiftyJSON


class EstablishmentProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var currentArtistLabel: UILabel!
    @IBOutlet weak var songPlayingImage: UIImageView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var explicitPlaylistLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tracks = [Track]()

    var currentSongOrder = -1
    
    var establishment: Establishment? {
        didSet {
            configureView()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
 
    func configureView() {
        if let profileEstablishment = establishment {
            if let nameLabel = nameLabel, addressLabel = addressLabel, cityLabel = cityLabel {
                nameLabel.text = profileEstablishment.title
                addressLabel.text = profileEstablishment.address
                cityLabel.text = profileEstablishment.postcode + " " + profileEstablishment.city
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        configureView()
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, -12, 0, -20);
        
        getCurrentSong() { current in
            self.loadPlaylist()
        }
        
        
        
    }
    
    func getCurrentSong(completion: (Bool) -> ()) {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.GET, establishment!.playlistUrl! + "current-song/", headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        if (json["now_playing"]) {
                            self.currentSongLabel.text = json["name"].string!
                            self.currentArtistLabel.text = json["artist"].string!
                            
                            if (json["spotify_uri"].string!.characters.count == 0) {
                                self.requestButton.enabled = false
                            }
                            else {
                                self.currentSongOrder = json["order"].int!
                            }
                        }
                        else {
                            self.currentSongLabel.text = "No song is currently playing"
                            self.currentArtistLabel.text = "-"
                            self.songPlayingImage.image = UIImage(named: "No song playing")!
                            self.requestButton.enabled = false
                        }
                    }
                    completion(true)
                    
                case .Failure(let error):
                    print(error)
                    completion(false)
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
        for track in tracks {
            if let coverUri = track.coverUri {
                self.downloadImage(coverUri) { image in
                    track.cover = image
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func loadPlaylist() {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.GET, establishment!.playlistUrl!, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        self.tracks.removeAll()
                        let json = JSON(data)
                        if json["explicit_lyrics"].bool! {
                            self.explicitPlaylistLabel.hidden = false
                        }
                        for (_, subJson):(String, JSON) in json["playlist_of"] {
                            if (subJson["in_playlist"].boolValue) {
                                self.tracks.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!, votes: subJson["votes"].int!, order: subJson["order"].int!, requestUserId: subJson["request_user_id"].int!, coverUri: subJson["cover_image_url"].string!))
                            }
                        }
                        self.tracks.sortInPlace({ $0.order < $1.order })
                        
                        /*if self.tracks.count >= 100 {
                            self.requestButton.enabled = false
                        }*/
                    }
                    
                    self.tableView.reloadData()
                    self.loadImages()
                    
                case .Failure(let error):
                    print(error)
                }
        }

    }
    
    // MARK: - Actions
    
    @IBAction func checkIn(sender: UIButton) {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.PUT, establishment!.url + "check-in/", headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        print(json)
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tracks.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell", forIndexPath: indexPath) as! TrackTableViewCell
        let track: Track
        track = tracks[indexPath.row]
        
        // reset default values for reuse
        cell.voteButton.hidden = false
        cell.voteButton.setImage(UIImage(named: "Thumb Up")!, forState: .Normal)
        cell.voteButton.removeTarget(self, action: #selector(showVoters), forControlEvents: .TouchUpInside)
        
        cell.titleLabel.text = track.title
        cell.artistLabel.text = track.artist
        cell.votesCountButton.setTitle(String(track.votes!), forState: .Normal)
        cell.votesCountButton.tag = indexPath.row
        cell.votesCountButton.addTarget(self, action: #selector(showVoters), forControlEvents: .TouchUpInside)
        cell.voteButton.tag = indexPath.row
        if (currentSongOrder == -1) {
            cell.voteButton.enabled = false
        }
        else {
            if (track.order! < currentSongOrder) {
                cell.voteButton.hidden = true
            }
            else if (track.order! == currentSongOrder) {
                cell.voteButton.setImage(UIImage(named: "currentSongPlaylist")!, forState: .Normal)
            }
            else {
                cell.voteButton.addTarget(self, action: #selector(voteSong), forControlEvents: .TouchUpInside)
            }
        }
        cell.requestedButton.tag = indexPath.row
        if track.requestUserId == -1 {
            cell.requestedButton.hidden = true
        }
        else {
            cell.requestedButton.addTarget(self, action: #selector(showRequestUserProfile), forControlEvents: .TouchUpInside)
        }
        
        cell.trackImage?.image = track.cover
        
        return cell
    }
    
    func showVoters (sender: UIButton) {
        self.performSegueWithIdentifier("ShowVoters", sender: sender)
    }
    
    func showRequestUserProfile (sender: UIButton) {
        self.performSegueWithIdentifier("ShowRequestUserProfile", sender: sender)
    }
    
    func voteSong (sender: UIButton) {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        //print("Selected track id: " + String(tracks[sender.tag].id!))
        Alamofire.request(.PUT, "https://joogpoint.herokuapp.com/tracks/" + String(tracks[sender.tag].id!) + "/vote/", headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        self.tracks.removeAll()
                        let json = JSON(data)
                        for (_, subJson):(String, JSON) in json["playlist_of"] {
                            if (subJson["in_playlist"].boolValue) {
                                self.tracks.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!, votes: subJson["votes"].int!, order: subJson["order"].int!, requestUserId: subJson["request_user_id"].int!, coverUri: subJson["cover_image_url"].string!))
                            }
                        }
                        self.tracks.sortInPlace({ $0.order < $1.order })
                    }
                    
                    self.tableView.reloadData()
                    self.loadImages()
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }

    
    // MARK: - Navigation
    
    @IBAction func backToMapOrSearch(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func requestSong(sender: UIButton) {
        self.performSegueWithIdentifier("SearchRequestSong", sender: self)
    }
    
    @IBAction func showEstablishmentInMap(sender: UIButton) {
//        self.performSegueWithIdentifier("ShowEstablishmentInMap", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showEstablishmentInMap" {
//                let nextViewController = segue.destinationViewController as! MapViewController
//                nextViewController.focusEstablishment = establishment
//        }
        if segue.identifier == "ShowVoters" {
            let nextViewController = segue.destinationViewController as! VotersListViewController
            nextViewController.track = tracks[sender!.tag]
        }
        else if segue.identifier == "ShowRequestUserProfile" {
            let nextViewController = segue.destinationViewController as! UserProfileViewController
            let track = tracks[sender!.tag]
            nextViewController.profileId = String(track.requestUserId!)
        }
        else if segue.identifier == "SearchRequestSong" {
            let nextViewController = segue.destinationViewController as! SpotifySearchViewController
            nextViewController.playlistUrl = establishment?.playlistUrl
        }
    }
}