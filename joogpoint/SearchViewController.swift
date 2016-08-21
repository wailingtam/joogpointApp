//
//  SearchViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 7/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchElements(searchController.searchBar.text!)
    }
}

class SearchViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    // MARK: Properties
    
    
    let searchController = UISearchController(searchResultsController: nil)
    var establishmentsResults:[(name: String, address: String)] = []
    var usersResults = [String]()
    
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
        
        
    }
    
    func searchElements(searchText: String, scope: String = "All") {
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        Alamofire.request(.GET, "https://joogpoint.herokuapp.com/establishments/search/", headers: headers, parameters: ["name": searchText])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        print(json)
                        self.establishmentsResults.removeAll()
                        
                        for (_, subJson):(String, JSON) in json["results"] {
                            print(subJson["name"].string)
                            print(subJson["address"].string)
                            print(subJson["city"].string)
                            self.establishmentsResults.append((name: subJson["name"].string!, address: subJson["address"].string!))
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
        
    }
    
    // Handle changes to the search string
    // TODO: when search button cliked call searchEstablishments
    /*
    func searchController(controller: UISearchController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.searchEstablishments(searchString)
        return true
    }
    */
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return (establishmentsResults.count)
            // TODO: add scope cases
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let establishment: (name: String, address: String)
        if searchController.active && searchController.searchBar.text != "" {
            establishment = (establishmentsResults[indexPath.row])
            cell.textLabel?.text = establishment.name
            cell.detailTextLabel?.text = establishment.address
        }
        return cell
    }
}