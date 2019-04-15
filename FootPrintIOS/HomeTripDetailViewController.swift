//
//  HomeTripDetailViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/13.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class HomeTripDetailViewController: UIViewController,UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var uiTableView: UITableView!
    
    var currentArray = [LandMark]()
    var locationsArray = [LandMark]()
    var friendList  = [String]()
    var numberOfButtons :Int?
    var tripID :Int?
    var homeTripForDetail: Trip!
    var placeSelected: Int?
    var placeSelecteds: [LandMark]?
    var result : LandMark?
    var currentButton: Int?
    var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var mScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //run
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.uiTableView.tableFooterView = UIView()
        self.uiTableView.backgroundView = activityIndicatorView
        
        setdata()
//        print("detail \(String(describing: homeTripForDetail.days))")
//        print("detail \(String(describing: homeTripForDetail.title))")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dynamicButtonCreation()
        //run
        if currentArray.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }
    
    func dynamicButtonCreation() {
        mScrollView.delegate = self
        mScrollView.isUserInteractionEnabled = true
        // 滑動條的樣式
        mScrollView.indicatorStyle = .black
        // 是否可以滑動
        mScrollView.isScrollEnabled = true
        // 是否可以按狀態列回到最上方
        mScrollView.scrollsToTop = false
        // 是否限制滑動時只能單個方向 垂直或水平滑動
        mScrollView.isDirectionalLockEnabled = true
        // 滑動超過範圍時是否使用彈回效果
        mScrollView.bounces = true
        // 刷新
        mScrollView.subviews.forEach { (button) in
            button.removeFromSuperview()
        }
        
        var count = 0
        var px = 0
        var py = 0
        px = 0
        if count < numberOfButtons! {
            for j in 1...numberOfButtons! {
                count += 1
                let Button = UIButton()
                Button.tag = count
                Button.frame = CGRect(x: px+10, y: py, width: 80, height: 48)
                Button.backgroundColor = UIColor(red: 155.0/255.0, green: 245.0/255.0, blue: 207.0/255.0, alpha: 1.0)
                Button.setTitle("第\(j)天", for: .normal)
                Button.addTarget(self, action: #selector(scrollButtonAction), for: .touchUpInside)
                mScrollView.addSubview(Button)
                px = px + 90
            }
        }
        py =  90
        mScrollView.contentSize = CGSize(width: px, height: py)
    }
    
    @objc func scrollButtonAction(sender: UIButton) {
        changeDataLandMark(tripID!, sender.tag - 1)
        //發送通知
        let notificationName = Notification.Name("HomeTripMapChange")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["TripID": tripID as Any, "Day":sender.tag - 1 as Any])
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanDetailCell") as? PlanTableViewCell
        let location = currentArray[indexPath.row]
        cell?.planLocationName.text = location.name
        cell?.planLocationAddress.text = location.address
        cell?.planLocationType.text = location.type
        findImage(location.id!, cell!)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print("\(indexPath.row)")
        performSegue(withIdentifier: "homeUnwindsegueMapController", sender: self)
    }
    //送回地圖
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath  = uiTableView.indexPathForSelectedRow{
            placeSelected = indexPath.row
            placeSelecteds = currentArray
        }
    }
    //cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //data
    func setdata() {
        //行程天數
        numberOfButtons = homeTripForDetail.days
        //id
        tripID = homeTripForDetail.tripID
        changeDataLandMark(tripID!,0)
    }
    
    //顯示行程地標
    func changeDataLandMark(_ tripID:Int, _ day:Int) {
        var requestParam = [String: Any]()
        let url_server = URL(string: common_url + "LocationServlet")
        requestParam["action"] = "findLandMarkInSchedulePlanDay"
        requestParam["SchedulePlanDayTripId"] = tripID
        requestParam["SchedulePlanDay"] = day
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([LandMark].self, from: data!) {
                        self.currentArray = result
                        DispatchQueue.main.async {
                            self.activityIndicatorView.stopAnimating()
                            self.uiTableView.reloadData()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.uiTableView.reloadData()
                    }
                }
            }
        }
    }
    
    //取得地標圖片
    func findImage(_ landMarkID:Int, _ cell:PlanTableViewCell) {
        let url_server = URL(string: common_url + "LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = landMarkID
        requestParam["imageSize"] = 1024
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "album.png")
                }
                DispatchQueue.main.async {
                    cell.planLocationImage.image = image
                    cell.planLocationImage.layer.cornerRadius = 34.25
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    
}
