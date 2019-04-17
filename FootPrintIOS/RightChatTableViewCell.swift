//
//  RightChatTableViewCell.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/16.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class RightChatTableViewCell: UITableViewCell {
    @IBOutlet weak var lb_RightMessage: UILabel!
    
    @IBOutlet weak var chatimageview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
