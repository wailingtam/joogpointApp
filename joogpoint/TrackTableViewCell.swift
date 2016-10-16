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
    @IBOutlet weak var requestedButton: UIButton!
    @IBOutlet weak var explicitLyricsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
