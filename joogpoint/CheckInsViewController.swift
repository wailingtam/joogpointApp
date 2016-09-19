//
//  CheckInsViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 18/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit

class CheckInsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var checkIns: [Establishment]? {
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
        return (checkIns!.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EstablishmentCell", forIndexPath: indexPath)
        let establishment: Establishment
        establishment = checkIns![indexPath.row]
        cell.textLabel?.text = establishment.title
        cell.detailTextLabel?.text = establishment.address + ", " + establishment.city
        return cell
    }
    
    // MARK: - Navigation
    
    @IBAction func backToUserProfile(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
}