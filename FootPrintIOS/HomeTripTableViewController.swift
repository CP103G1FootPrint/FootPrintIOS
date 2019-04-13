//
//  HomeTripTableViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/20.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class HomeTripTableViewController: UITableViewController {
    var trips = [Trip]()
    let url_server = URL(string: common_url + "/TripServlet")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView =  UIView()
        tableViewAddRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showAllTrips()
    }
    
    func tableViewAddRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(showAllTrips), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func showAllTrips(){
        var requestParam = [String: String]()
        requestParam["action"] = "stroke"
        requestParam["type"] = "open"
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
//                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    
                    if let result = try? JSONDecoder().decode([Trip].self, from: data!) {
                        self.trips = result
                        print(self.trips)
//                        _ = try? JSONDecoder().decode(String.self, from: data!)
                        
                        DispatchQueue.main.async {
                            if let control = self.tableView.refreshControl {
                                if control.isRefreshing {
                                    // 停止下拉更新動作
                                    control.endRefreshing()
                                }
                            }
                            /* 抓到資料後重刷table view */
                            self.tableView.reloadData()
                        }
                    }}
                
                
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return trips.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "tripcell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! TripPlansTableViewCell
        let trip = trips[indexPath.row]
        
        //找trip封面圖
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = trip.tripID
        // 圖片寬度為tableViewCell的1/4，ImageView的寬度也建議在storyboard加上比例設定的constraint
        requestParam["imageSize"] = cell.frame.width / 4
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "noImage.jpg")
                }
                DispatchQueue.main.async {cell.iv_TripPicture.image = image }
            } else {
                print(error!.localizedDescription)
            }
        }
        //找使用者圖頭像
        let url_server2 = URL(string: common_url + "PicturesServlet")
        requestParam["action"] = "findUserHeadImage"
        requestParam["userId"] = trip.createID
        requestParam["imageSize"] = cell.frame.width
        var headImage: UIImage?
        executeTask(url_server2!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    headImage = UIImage(data: data!)
                }
                if headImage == nil {
                    headImage = UIImage(named: "album")
                }
                DispatchQueue.main.async {
                    cell.iv_HeadPicture.image = headImage
                    cell.iv_HeadPicture.layer.cornerRadius = cell.iv_HeadPicture.frame.width/2
                }
                //設定button為圓形
            } else {
                print(error!.localizedDescription)
            }
        }
        //找使用者暱稱
        var requestParamNickName = [String: String]()
//        let url_server2 = URL(string: common_url + "PicturesServlet")
        requestParamNickName["action"] = "findUserNickName"
        requestParamNickName["id"] = trip.createID
        executeTask(url_server2!, requestParamNickName) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
//                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    let resultNickeName = String(data: data!, encoding: .utf8)!
//                    print ("nicekname\(resultNickeName)")
                    DispatchQueue.main.async {
                        cell.lb_NickName.text = resultNickeName
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        cell.lb_TripTitle.text = trip.title
        cell.lb_TripDate.text = trip.date
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeTrip" {
            /* indexPath(for:)可以取得UITableViewCell的indexPath */
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            let trip = trips[indexPath!.row]
            print("a1 \(trip.title)")
            let detailVC = segue.destination as! HomeTripMapViewController
            detailVC.tripMap = trip
        }
    }
}
