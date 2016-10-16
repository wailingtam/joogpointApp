//
//  SpotifySearchViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 4/10/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import Locksmith

extension SpotifySearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text!.characters.count > 3 {
            searchElements(searchController.searchBar.text!) { completed in
                if completed {
                    self.loadImages()
                }
            }
        }
    }
}

class SpotifySearchViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    var trackResults = [Track]()
    
    var trackCount = 0
    var lastTrackSearchCount = 0
    
    var playlistUrl: String?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // searchController.searchBar.delegate = self
        // Use the current view controller to update the search results.
        searchController.searchResultsUpdater = self
        
        // Not dim the view because we are not using a searchResultsController
        searchController.dimsBackgroundDuringPresentation = false
        
        // Ensure the search bar does not remain on screen if user navigates to another view controller while the UISearchController is active
        definesPresentationContext = true
        
        // Add searchBar to your table view’s tableHeaderView
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search by artist or song name"
        // searchController.searchBar.showsBookmarkButton = true
        
    }
    
    /*func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        searchElements(searchController.searchBar.text!) { completed in
            if completed {
                self.tableView.reloadData()
            }
        }
    }*/
    
    func downloadImage (imageUrl: String, completion: (UIImage) -> ()) {
        Alamofire.request(.GET, imageUrl).response() {
            (_, _, data, _) in
            if let imageData = data {
                let image = UIImage(data: imageData)
                completion(image!)
            }
        }
    }
    
    func searchElements(searchText: String, scope: String = "All", completion: (Bool) -> ()) {
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.GET, "https://joogpoint.herokuapp.com/spotify/search/", headers: headers, parameters: ["query": searchText])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        self.trackResults.removeAll()
                        let json = JSON(data)
                        //print(json)
                        self.trackCount += json["tracks"].count
                        self.lastTrackSearchCount = json["track"].count
                        for (_, subJson):(String, JSON) in json["tracks"] {
                            var artists = [String]()
                            for artist in subJson["artist"].array! {
                                artists.append(artist.string!)
                            }
                            let artistsString = artists.joinWithSeparator(", ")
                            let songCover = subJson["images"][2]["url"].string
                            self.trackResults.append(Track(title: subJson["name"].string!, artist: artistsString, spotifyUri: subJson["spotify_uri"].string!, isExplicit: subJson["explicit"].bool!, coverUri: songCover))
                        }
                    }
                    completion(true)
                
                case .Failure(let error):
                    print(error)
                    completion(false)
                }
        }
        
    }
    
    func loadImages() {
        for track in trackResults {
            if let coverUri = track.coverUri {
                self.downloadImage(coverUri) { image in
                    track.cover = image
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func showAlert(message: String, buttonTitle: String) {
        let alert = UIAlertController(title: "Song request error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!) in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Make a request of", message: trackResults[indexPath.row].title + " - " + trackResults[indexPath.row].artist, preferredStyle: UIAlertControllerStyle.Alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .Default) { (_) in
            let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
            
            let headers = [
                "Authorization": "Token " + (dictionary?["token"] as! String)
            ]
            
            let track: Track = self.trackResults[indexPath.row]
            
            let parameters : [String : AnyObject] = [
                "title": track.title,
                "artist": track.artist,
                "spotify_uri": track.spotifyUri!,
                "explicit_lyrics": String(track.isExplicit!),
                "cover_image_url": track.coverUri!
            ]
            
            Alamofire.request(.POST, self.playlistUrl! + "request-song/", headers: headers, parameters: parameters)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        let completionAlert = UIAlertController(title: "Song request done", message: "Song added to playlist", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let confirmAction = UIAlertAction(title: "Ok", style: .Default) { (_) in
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                                                
                        completionAlert.addAction(confirmAction)
                        self.presentViewController(completionAlert, animated: true, completion: nil)
                        
                    case .Failure(_):
                        var alertMessage = ""
                        if let data = response.data {
                            let errorMessage = String(data: data, encoding: NSUTF8StringEncoding)!
                            alertMessage = errorMessage
                            // TODO: Deal with other errors
                        }
                        self.showAlert(alertMessage, buttonTitle: "Try again")
                        
                        //print(error)
                        if let data = response.data {
                            let errorMessage = String(data: data, encoding: NSUTF8StringEncoding)!
                            if errorMessage.rangeOfString("{error:Explicit lyrics are not allowed.}") != nil {
                                alertMessage = "Songs with explicit lyrics are not allowed in this establishment."
                            }
                        }

                    }
                    
            }
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (_) in }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return (trackResults.count)
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TrackTableViewCell
        let track: Track
        if searchController.active && searchController.searchBar.text != "" {
            cell.explicitLyricsLabel.hidden = true
            if indexPath.row < trackResults.count {
                track = trackResults[indexPath.row]
                cell.titleLabel?.text = track.title
                cell.artistLabel?.text = track.artist
                cell.trackImage?.image = track.cover
                if let explicit = track.isExplicit {
                    if explicit == true {
                        cell.explicitLyricsLabel.hidden = false
                    }
                }
            }
        }
        return cell
    }
    
   
    
    // MARK: - Navigation
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEstablishmentProfile" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let track: Track
                if searchController.active && searchController.searchBar.text != "" {
                    track = trackResults[indexPath.row]
                    let nextViewController = segue.destinationViewController as! EstablishmentProfileViewController
                    // nextViewController.establishment = track
                    self.navigationController?.popViewControllerAnimated(true)

                }
            }
        }
    }*/
}