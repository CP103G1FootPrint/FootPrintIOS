//
//  NearLocationTableViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/3.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class NearLocationTableViewController: UITableViewController {

    //資料
    var allLocation = [LandMark]()
    var nearLocations = [LandMark]()
    var cameraLandMark : LandMark?
    //search bar
    var searchCtrl : UISearchController!
    //GPS
    var requestParam = [String: Double]()
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
            activityIndicatorView = UIActivityIndicatorView(style: .gray)
            tableView.backgroundView = activityIndicatorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //所有地標
//        findAllLocationInfo()
        //search bar
        if let vc = storyboard?.instantiateViewController(withIdentifier: "FindLocationTableView") as? FindLocationTableViewController{
            searchCtrl = UISearchController(searchResultsController: vc)
            searchCtrl.searchResultsUpdater = vc
            
            searchCtrl.dimsBackgroundDuringPresentation = false
            tableView.tableHeaderView = searchCtrl.searchBar
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //GPS
        let latitude = requestParam["latitude"]
        let longitude = requestParam["longitude"]
        findNearLocationInfo(latitude!, longitude!)
        //run
        if nearLocations.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nearLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearLocationCell", for: indexPath) as? NearLocationTableViewCell
        
        let nearLocation = nearLocations[indexPath.row]
        cell!.nearLocationName.text = nearLocation.name
        cell!.nearLocationAddress.text = nearLocation.address
        cell!.nearLocationType.text = nearLocation.type
        findImage(nearLocation.id!,cell!)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cameraLandMark = nearLocations[indexPath.row]
//        print("123: \(String(describing: cameraLandMark?.id))")
        let notificationName = Notification.Name("locationCreate")
        //發送通知
        let locationall = LandMark(cameraLandMark!.id!,cameraLandMark!.address!)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["location":locationall])
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "camera") {
            self.present(controller, animated: true, completion: nil)
        }
//        let home = storyboard!.instantiateViewController(withIdentifier: "MainTabBarController")
//        self.present(home, animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nearLocationTableViewController = segue.destination as? CreateLocationViewController
        if requestParam["latitude"] != nil && requestParam["longitude"] != nil {
            nearLocationTableViewController!.requestCreateLocation["latitude"] = requestParam["latitude"]
            nearLocationTableViewController!.requestCreateLocation["longitude"] = requestParam["longitude"]
        }
        
        let cameraViewcontroller = segue.destination as? CameraViewController
        cameraViewcontroller?.showLandMark = cameraLandMark
        
//        let findLocationController = segue.destination as? FindLocationTableViewController
//        findLocationController?.allLandMark = allLocation
        
    }
    
    //取得地標圖片
    func findImage(_ landMarkID:Int, _ cell:NearLocationTableViewCell) {
        let url_server = URL(string: common_url + "/LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = landMarkID
        requestParam["imageSize"] = 1024
        //        requestParam["imageSize"] = "\(UIScreen.main.bounds)"
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
                    cell.naerLocationImage.image = image
                    cell.naerLocationImage.layer.cornerRadius = 34.25
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    
    //取得使用者附近地標
    func findNearLocationInfo( _ latitude:Double, _ longitude:Double) {
        let url_server = URL(string: common_url + "/LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "nearByMySelf"
        requestParam["latitude"] = latitude
        requestParam["longitude"] = longitude
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    //                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([LandMark].self, from: data!) {
                        self.nearLocations = result
                        DispatchQueue.main.async {
                            self.activityIndicatorView.stopAnimating()
                            self.tableView.reloadData()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    
    //取得所有地標
    func findAllLocationInfo() {
        let url_server = URL(string: common_url + "/LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "All"
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    //                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([LandMark].self, from: data!) {
                        self.allLocation = result
                    }
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    
    
}
