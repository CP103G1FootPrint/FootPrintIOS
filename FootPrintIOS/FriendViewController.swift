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
    let user = loadData()
    var friends = [Friends]()
//    let serialQueue: DispatchQueue = DispatchQueue(label: "serialQueue")

//    let queue = ispatch

    let myDataQueue = DispatchQueue(label: "ConcurrentQueue",
                                          qos: .background,
                                          attributes: .concurrent,
                                          autoreleaseFrequency: .workItem,
                                          target: nil)
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        getAllFriends()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewController.delegate = self
    }
    
    @objc func getAllFriends(){
        let url_server = URL(string: common_url + "FriendsServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "getAllFriends"
        requestParam["userId"] =  user.account
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil{
                if data != nil{
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([Friends].self, from: data!){
                        self.friends = result
                        
                        self.myDataQueue.async(flags: .barrier) {
                            self.friends = result
//                        self.serialQueue.sync {
//                            self.friends = result
//                            print(1)
//
//                        }
                        }
                    }
                }
            }else{
                print(error!.localizedDescription)
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination{
        case let controller as FriendsViewController:
        print(controller)
        case let controller as FriendsMessageTableViewController:
        print(controller)
        default:
            break
        }
    }
    
    
    
    
}
