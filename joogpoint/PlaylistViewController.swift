//
//  PlaylistTableViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 31/08/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith

class PlaylistViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var establishmentNameLabel: UILabel!
    
    var tracks = [Track]()
    
    var playlistUrl: String = ""
    
    var establishmentName: String? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let name = establishmentName {
            if let establishmentNameLabel = establishmentNameLabel {
                establishmentNameLabel.text = name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()

        self.tableView.contentInset = UIEdgeInsetsMake(0, -12, 0, 0);
        
        loadPlaylist()
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
                print (coverUri)
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
        
        Alamofire.request(.GET, playlistUrl, headers: headers)
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
    
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tracks.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell", forIndexPath: indexPath) as! TrackTableViewCell
        let track: Track
        track = tracks[indexPath.row]
        cell.titleLabel.text = track.title
        cell.artistLabel.text = track.artist
        cell.votesCountButton.tag = indexPath.row
        cell.votesCountButton.setTitle(String(track.votes!), forState: .Normal)
        cell.votesCountButton.addTarget(self, action: #selector(showVoters), forControlEvents: .TouchUpInside)
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
    
    // MARK: - Navigation
    
    @IBAction func backToMyEstablishment(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowVoters" {
            let nextViewController = segue.destinationViewController as! VotersListViewController
            nextViewController.track = tracks[sender!.tag]
        }
        else if segue.identifier == "ShowRequestUserProfile" {
            let nextViewController = segue.destinationViewController as! UserProfileViewController
            let track = tracks[sender!.tag]
            nextViewController.profileId = String(track.requestUserId!)
        }
    }

    
}
