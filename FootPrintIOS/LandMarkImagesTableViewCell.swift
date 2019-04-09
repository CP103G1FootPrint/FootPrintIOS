//
//  LandMarkImagesTableViewCell.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class LandMarkImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameUILabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
