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
    
    @IBOutlet weak var tableView: UITableView!
    
    var tracks = [Track]()

    var establishment: Establishment? {
        didSet {
            configureView()
        }
    }
    /*
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    */
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
        
        configureView()
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, -12, 0, 0);
        
        getCurrentSong()
        
        loadPlaylist()
        
    }
    
    func getCurrentSong() {
        
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
                        if (!json["now_playing"]) {
                            self.currentSongLabel.text = json["name"].string!
                            self.currentArtistLabel.text = json["artist"].string!
                        }
                    }
                    
                case .Failure(let error):
                    print(error)
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
    
    // MARK: - Actions
    
    @IBAction func checkIn(sender: UIButton) {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        var establishmentUrl = establishment!.url
        let index = establishmentUrl.startIndex.advancedBy(4)
        establishmentUrl.insert("s", atIndex: index)
        
        Alamofire.request(.PUT, establishmentUrl + "check-in/", headers: headers)
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
        cell.titleLabel.text = track.title
        cell.artistLabel.text = track.artist
        cell.votesCountButton.setTitle(String(track.votes!), forState: .Normal)
        cell.idLabel.text = String(track.id)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //let indexPath = self.tableView.indexPathForSelectedRow()
        
        let currentCell = self.tableView.cellForRowAtIndexPath(indexPath) as! TrackTableViewCell
        
        print(currentCell.idLabel!.text)
        
    }
    
    // MARK: - Navigation
    
    @IBAction func backToMapOrSearch(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func requestSong(sender: UIButton) {
    }
    
    @IBAction func showEstablishmentInMap(sender: UIButton) {
//        self.performSegueWithIdentifier("ShowEstablishmentInMap", sender: self)
    }
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEstablishmentInMap" {
                let nextViewController = segue.destinationViewController as! MapViewController
                nextViewController.focusEstablishment = establishment
        }
    }
     */
    
}