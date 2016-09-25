//
//  EditUserProfileViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 25/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
import SwiftyJSON

class EditUserProfileViewController: UIViewController {
    
    @IBAction func backToUserProfile(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
