//
//  FriendViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/1.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var scrollViewController: UIScrollView!
    @IBOutlet weak var container_Friends: UIView!
    @IBOutlet weak var container_Message: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewController.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        segment.selectedSegmentIndex = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        scrollView.isPagingEnabled = true
    }

    @IBAction func segmentController(_ sender: UISegmentedControl) {
        switch segment.selectedSegmentIndex
        {
        case 0:
            scrollViewController.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
        case 1:
            scrollViewController.setContentOffset(CGPoint(x : scrollViewController.bounds.size.width, y: 0), animated: true)
        default:
            break
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
