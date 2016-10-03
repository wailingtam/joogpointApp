//
//  VotersListController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 26/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import Foundation
import UIKit
import Locksmith
import Alamofire
import SwiftyJSON

class VotersListViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var voters = [(String, String)]()
    
    var track: Track? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let trackInfo = track {
            if let trackNameLabel = nameLabel {
                trackNameLabel.text = trackInfo.title
            }
            if let trackArtistLabel = artistLabel {
                trackArtistLabel.text = trackInfo.artist
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        loadVoters()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func loadVoters () {
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        print(String(track!.id))
        Alamofire.request(.GET, "https://joogpoint.herokuapp.com/tracks/" + String(track!.id) + "/", headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        self.voters.removeAll()
                        for (_, subJson):(String, JSON) in json["voters"] {
                            self.voters.append((String(subJson["profile_id"].int!), subJson["username"].string!))
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
        return (voters.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        let voter: (String, String)
        voter = voters[indexPath.row]
        cell.textLabel?.text = voter.1
        return cell
    }
    
    // MARK: - Navigation
    
    @IBAction func backToEstablishment(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowVoterProfile" {
            let nextViewController = segue.destinationViewController as! UserProfileViewController
            if let selectedUserCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedUserCell)!
                let voter = voters[indexPath.row]
                nextViewController.profileId = voter.0
            }
        }
    }

    
}