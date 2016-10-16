//
//  MyEstablishmentViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 19/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
import SwiftyJSON


struct Playlist {
    var url = ""
    var spotifyUrl =  ""
    var originalCreator = ""
    var originalSpotifyUrl = ""
    var explicitLyrics = false
}

class MyEstablishmentViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var establishmentNameLabel: UILabel!
    @IBOutlet weak var explicitLyricsButton: UIButton!
    
    var playlist: Playlist = Playlist();
    
    var establishment: Establishment? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let establishmentProfile = establishment {
            if let establishmentNameLabel = establishmentNameLabel {
                establishmentNameLabel.text = establishmentProfile.title
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        establishment?.loadEstablishment()
        configureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.explicitLyricsButton.titleLabel?.textAlignment = NSTextAlignment.Center;
        self.explicitLyricsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        loadPlaylistInfo()
    }
    
    func loadPlaylistInfo() {
        
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
                        let json = JSON(data)
                        self.playlist.url = json["url"].string!
                        self.playlist.spotifyUrl = json["spotify_url"].string!
                        self.playlist.originalCreator = json["original_creator"].string!
                        self.playlist.originalSpotifyUrl = json["original_spotify_url"].string!
                        self.playlist.explicitLyrics = json["explicit_lyrics"].bool!
                        
                        if self.playlist.explicitLyrics {
                            self.explicitLyricsButton.setTitle("Explicit lyrics:\nALLOWED", forState: .Normal)
                        }
                        else {
                            self.explicitLyricsButton.setTitle("Explicit lyrics:\nNOT ALLOWED", forState: .Normal)
                        }
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }

    }
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!) in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func setPlaylist(sender: UIButton) {
        let alert = UIAlertController(title: "Set Playlist", message: "Complete the following fields.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let urlField = alert.textFields?[0], let creatorField = alert.textFields?[1] {
                let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
                
                let headers = [
                    "Authorization": "Token " + (dictionary?["token"] as! String),
                    "Content-Type": "application/json"
                ]
                
                print(urlField.text! + creatorField.text!)
                print(self.establishment!.playlistUrl! + "set-playlist/")
                
                Alamofire.request(.POST, self.establishment!.playlistUrl! + "set-playlist/", headers: headers, parameters: ["spotify_url": urlField.text!, "owner": creatorField.text!], encoding: ParameterEncoding.JSON)
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .Success:
                            if let data = response.result.value {
                                let json = JSON(data)
                                self.playlist.spotifyUrl = json["spotify_url"].string!
                                self.playlist.originalCreator = json["original_creator"].string!
                                self.playlist.originalSpotifyUrl = json["original_spotify_url"].string!
                            }
                            self.showAlert("Set Playlist", message: "New playlist set successfully", buttonTitle: "Ok")
                        case .Failure(let error):
                            print(error)
                        }
                }
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Spotify playlist url"
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Creator's Spotify username"
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
    
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func resetPlaylist(sender: UIButton) {
        
        if self.playlist.spotifyUrl == "" {
            self.showAlert("Reset Playlist", message: "You don't have a playlist set.", buttonTitle: "Ok")
        }
        else {
            let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
            
            let headers = [
                "Authorization": "Token " + (dictionary?["token"] as! String)
            ]
            
            Alamofire.request(.PUT, establishment!.playlistUrl! + "reset-playlist/", headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        self.showAlert("Reset Playlist", message: "Original tracks, votes and order have been reset.", buttonTitle: "Ok")
                        
                    case .Failure(let error):
                        print(error)
                        self.showAlert("Reset Playlist", message: "You don't have a playlist set.", buttonTitle: "Ok")
                    }
            }
        }
    }
    
    @IBAction func clearVotes(sender: UIButton) {
        
        if self.playlist.spotifyUrl == "" {
            self.showAlert("Clear Votes", message: "You don't have a playlist set.", buttonTitle: "Ok")
        }
        else {
            let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
            
            let headers = [
                "Authorization": "Token " + (dictionary?["token"] as! String)
            ]
            
            Alamofire.request(.PUT, establishment!.playlistUrl! + "reset-votes/", headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        self.showAlert("Clear Votes", message: "All song votes have been set to zero!", buttonTitle: "Ok")
                                            
                    case .Failure(let error):
                        print(error)
                        self.showAlert("Clear Votes", message: "You don't have a playlist set.", buttonTitle: "Ok")
                    }
            }
        }
    }
    
    @IBAction func setExplicitLyrics(sender: UIButton) {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        self.playlist.explicitLyrics = !self.playlist.explicitLyrics
        
        Alamofire.request(.PATCH, establishment!.playlistUrl!, headers: headers, parameters: ["explicit_lyrics": self.playlist.explicitLyrics])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if self.playlist.explicitLyrics {
                        self.explicitLyricsButton.setTitle("Explicit lyrics:\nALLOWED", forState: .Normal)
                    }
                    else {
                        self.explicitLyricsButton.setTitle("Explicit lyrics:\nNOT ALLOWED", forState: .Normal)
                    }
                case .Failure(let error):
                    print(error)
                }
        }
        
    }
    
    @IBAction func removePlaylist(sender: UIButton) {
        
        if self.playlist.spotifyUrl == "" {
            self.showAlert("Remove Playlist", message: "You don't have a playlist set.", buttonTitle: "Ok")
        }
        else {
            let alert = UIAlertController(title: "Remove playlist", message: "Are you completely sure?", preferredStyle: UIAlertControllerStyle.Alert)
            
            let confirmAction = UIAlertAction(title: "Yes", style: .Default) { (_) in
                let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
                
                let headers = [
                    "Authorization": "Token " + (dictionary?["token"] as! String)
                ]
                
                Alamofire.request(.PUT, self.establishment!.playlistUrl! + "clear/", headers: headers)
                    .validate(statusCode: 200..<300)
                    .response { response in
                        // check if there is a playlist set
                        
                        self.playlist.spotifyUrl = ""
                        self.playlist.originalCreator = ""
                        self.playlist.originalSpotifyUrl = ""
                        
                        self.showAlert("Remove Playlist", message: "Playlist removed! Go set a new one!🎵", buttonTitle: "Ok")
                }
            }
            
            let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (_) in }
            
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    
    // MARK: - Navigation
    
    @IBAction func backToMyJoogpoints(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func segueToEstablishmentProfile(sender: UIButton) {
        self.performSegueWithIdentifier("ShowEstablishmentProfile", sender: self)
    }
    
    @IBAction func segueToEditProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("EditEstablishmentProfile", sender: self)
    }
    
    @IBAction func segueToPlaylist(sender: UIButton) {
        if self.playlist.spotifyUrl == "" {
            self.showAlert("Current Playlist", message: "You don't have a playlist set.", buttonTitle: "Ok")
        }
        else {
            self.performSegueWithIdentifier("ShowPlaylist", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEstablishmentProfile" {
            let nextViewController = segue.destinationViewController as! EstablishmentProfileViewController
            nextViewController.establishment = establishment
        }
        else if segue.identifier == "ShowPlaylist" {
            let nextViewController = segue.destinationViewController as! PlaylistViewController
            nextViewController.playlistUrl = establishment!.playlistUrl!
            nextViewController.establishmentName = establishment!.title
        }
        else if segue.identifier == "EditEstablishmentProfile" {
            let nextViewController = segue.destinationViewController as! EditEstablishmentViewController
            nextViewController.establishment = establishment
        }
    }

}