//
//  MyJoogpointsViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 19/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
import SwiftyJSON
import MapKit

class MyJoogpointsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    var joogpoints: [Establishment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, -12, 0, 0);
        
        loadJoogpoints()
    }
    
    func loadJoogpoints() {
    
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.GET, "https://joogpoint.herokuapp.com/profiles/me/", headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        
                        for (_, subJson):(String, JSON) in json["user"]["owner_of"] {
                            self.joogpoints.append(Establishment(url: subJson["url"].string!, name: subJson["name"].string!, address: subJson["address"].string!, postcode: subJson["postcode"].string!, city: subJson["city"].string!, coordinate: CLLocationCoordinate2D(latitude: subJson["latitude"].double!, longitude: subJson["longitude"].double!), playlistUrl: subJson["establishment_playlist"].string!))
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }

    
    }
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.joogpoints.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JoogpointCell", forIndexPath: indexPath)
        let joogpoint: Establishment
        joogpoint = self.joogpoints[indexPath.row]
        cell.textLabel?.text = joogpoint.title
        cell.detailTextLabel?.text = joogpoint.address + ", " + joogpoint.city
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMyJoogpoint" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let establishment: Establishment
                establishment = joogpoints[indexPath.row]
                let nextViewController = segue.destinationViewController as! MyEstablishmentViewController
                nextViewController.establishment = establishment
            }
        }
    }
}