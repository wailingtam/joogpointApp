//
//  EstablishmentProfileViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 22/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit

class EstablishmentProfileViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    
    var profileEstablishment: Establishment? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let profileEstablishment = profileEstablishment {
            if let nameLabel = nameLabel, addressLabel = addressLabel, cityLabel = cityLabel {
                nameLabel.text = profileEstablishment.name
                addressLabel.text = profileEstablishment.address
                cityLabel.text = profileEstablishment.postcode + " " + profileEstablishment.city
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
}