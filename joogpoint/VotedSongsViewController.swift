//
//  CheckInsViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 18/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Alamofire

class VotedSongsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var votedSongs: [Track]? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, -12, 0, 0);
    }
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (votedSongs!.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell", forIndexPath: indexPath) as! TrackTableViewCell
        let track: Track
        track = votedSongs![indexPath.row]
        cell.titleLabel?.text = track.title
        cell.artistLabel?.text = track.artist
        cell.trackImage?.image = track.cover
        return cell
    }
    
    // MARK: - Navigation
    
    @IBAction func backToUserProfile(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
}