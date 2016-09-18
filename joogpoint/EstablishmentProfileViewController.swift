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
        
        loadPlaylist()
    }
    
    func loadPlaylist() {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        var playlistUrl = establishment!.playlistUrl
        let index = playlistUrl!.startIndex.advancedBy(4)
        playlistUrl!.insert("s", atIndex: index)
        
        Alamofire.request(.GET, playlistUrl!, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        self.tracks.removeAll()
                        let json = JSON(data)
                        for (_, subJson):(String, JSON) in json["playlist_of"] {
                            self.tracks.append(Track(id: subJson["id"].int!, title: subJson["title"].string!, artist: subJson["artist"].string!, votes: subJson["votes"].int!))
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let track: Track
        track = tracks[indexPath.row]
        cell.textLabel?.text = track.title
        cell.detailTextLabel?.text = track.artist
        return cell
    }
    
    
    // MARK: - Navigation
    
    @IBAction func backToMapOrSearch(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func requestSong(sender: UIButton) {
    }
    
    @IBAction func showEstablishmentInMap(sender: UIButton) {
//        self.performSegueWithIdentifier("showEstablishmentInMap", sender: self)
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