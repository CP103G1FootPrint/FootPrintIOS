//
//  ExchangeTVCell.swift
//  FootPrintIOS
//
//  Created by ChiaLi Wang on 2019/3/22.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class ExchangeTVCell: UITableViewCell {
    
    @IBOutlet weak var productPic: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productScr: UILabel!
    @IBOutlet weak var integral: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
}

