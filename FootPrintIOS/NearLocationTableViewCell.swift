//
//  NearLocationTableViewCell.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/3.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class NearLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var naerLocationImage: UIImageView!
    @IBOutlet weak var nearLocationName: UILabel!
    @IBOutlet weak var nearLocationAddress: UILabel!
    @IBOutlet weak var nearLocationType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
