//
//  TrackTableViewCell.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 31/08/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

class TrackTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var votesCountButton: UIButton!
    @IBOutlet weak var voteButton: UIButton!
    
    @IBOutlet weak var trackImage2: UIImageView!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var artistLabel2: UILabel!
    @IBOutlet weak var votesCountButton2: UIButton!
    @IBOutlet weak var requestedButton2: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
