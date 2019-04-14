//
//  PlanTableViewCell.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/12.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class PlanTableViewCell: UITableViewCell {

    @IBOutlet weak var planLocationImage: UIImageView!
    
    @IBOutlet weak var planLocationName: UILabel!
    
    @IBOutlet weak var planLocationAddress: UILabel!
    
    @IBOutlet weak var planLocationType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
