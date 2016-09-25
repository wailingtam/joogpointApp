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
                                self.tracks.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!, votes: subJson["votes"].int!))
                            }
                        }
                    }
                    
                    self.tableView.reloadData()
                    
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
        cell.titleLabel2.text = track.title
        cell.artistLabel2.text = track.artist
        cell.votesCountButton2.setTitle(String(track.votes!), forState: .Normal)
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    @IBAction func backToMyEstablishment(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
}
