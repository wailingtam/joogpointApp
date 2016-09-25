//
//  SearchViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 7/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import Locksmith

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchElements(searchController.searchBar.text!)
    }
}

class SearchViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    var establishmentsResults = [Establishment]()
    var usersResults = [String]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Use the current view controller to update the search results.
        searchController.searchResultsUpdater = self
        
        // Not dim the view because we are not using a searchResultsController
        searchController.dimsBackgroundDuringPresentation = false
        
        // Ensure the search bar does not remain on screen if user navigates to another view controller while the UISearchController is active
        definesPresentationContext = true
        
        // Add searchBar to your table view’s tableHeaderView
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search by name or address"
        
    }
    
    func searchElements(searchText: String, scope: String = "All") {
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.GET, "https://joogpoint.herokuapp.com/establishments/search/", headers: headers, parameters: ["query": searchText])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        self.establishmentsResults.removeAll()
                        let json = JSON(data)
                        for (_, subJson):(String, JSON) in json {
                            self.establishmentsResults.append(Establishment(url: subJson["url"].string!, name: subJson["name"].string!, address: subJson["address"].string!, postcode: subJson["postcode"].string!, city: subJson["city"].string!, country: subJson["country"].string!, coordinate: CLLocationCoordinate2D(latitude: 41.387989, longitude: 2.167861), playlistUrl: subJson["establishment_playlist"].string!))
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
        
    }
    
    // TODO: when search button cliked call searchEstablishments
    
    // TODO: Add City to Address
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return (establishmentsResults.count)
            // TODO: add scope cases
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let establishment: Establishment
        if searchController.active && searchController.searchBar.text != "" {
            establishment = establishmentsResults[indexPath.row]
            cell.textLabel?.text = establishment.title
            cell.detailTextLabel?.text = establishment.address + ", " + establishment.city
        }
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEstablishmentProfile" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let establishment: Establishment
                if searchController.active && searchController.searchBar.text != "" {
                    establishment = establishmentsResults[indexPath.row]
                    let nextViewController = segue.destinationViewController as! EstablishmentProfileViewController
                    nextViewController.establishment = establishment
                }
            }
        }
    }
}