//
//  PersonalVC.swift
//  FootPrintIOS
//
//  Created by ChiaLi Wang on 2019/3/15.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class PersonalVC: UIViewController {
    let userDefault = UserDefaults.standard
    let url_server = URL(string:common_url + "AccountServlet")
    
    @IBOutlet weak var p1: UISegmentedControl!
    @IBOutlet weak var ivSelfie: UIImageView!
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var lbPoint: UILabel!
    @IBOutlet weak var ivMoney: UIImageView!
    @IBOutlet weak var viewRecord: UIView!
    @IBOutlet weak var viewCollect: UIView!
    @IBOutlet weak var viewNotify: UIView!
    @IBOutlet weak var viewExchange: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewRecord.isHidden = false
        viewCollect.isHidden = true
        viewNotify.isHidden = true
        viewExchange.isHidden = true
    }
    
    
    
    @IBAction func segma(_ sender: UISegmentedControl) {
        switch p1.selectedSegmentIndex {
        case 0:
            viewRecord.isHidden = false
            viewCollect.isHidden = true
            viewNotify.isHidden = true
            viewExchange.isHidden = true
        case 1:
            viewRecord.isHidden = true
            viewCollect.isHidden = false
            viewNotify.isHidden = true
            viewExchange.isHidden = true
        case 2:
            viewRecord.isHidden = true
            viewCollect.isHidden = true
            viewNotify.isHidden = false
            viewExchange.isHidden = true
        case 3:
            viewRecord.isHidden = true
            viewCollect.isHidden = true
            viewNotify.isHidden = true
            viewExchange.isHidden = false
        default:
            fatalError()
        }
        
        
    }
    
    
}
