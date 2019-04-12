//
//  ScheduleTableViewCell.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/10.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    var trips: Trip!
        
//    @IBAction func albumButton(_ sender: Any) {
//        let x = trips.tripID
//        print("test : \(x)")
//        
//    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
