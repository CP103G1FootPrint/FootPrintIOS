//
//  TripTabViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/20.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class TripTabViewController: UIViewController {
    var scheduleTableViewController: ScheduleTableViewController!

    @IBOutlet weak var test: UIView!
    @IBOutlet weak var scheduletableview: UIView!
    
    @IBOutlet weak var sgment: UISegmentedControl!
    
    @IBAction func switchCustom(_ sender: UISegmentedControl) {
        let getIndex = sgment.selectedSegmentIndex
        print(getIndex)
        switch (getIndex) {
        case 0:
            test.isHidden = true
            scheduletableview.isHidden = false
        case 1:
            test.isHidden = false
            scheduletableview.isHidden = true
        default:
            break
//            test.isHidden = true
//            scheduletableview.isHidden = false
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleMain" {
            scheduleTableViewController = segue.destination as? ScheduleTableViewController
    }
    }}


