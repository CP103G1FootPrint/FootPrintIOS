//
//  FindLocationViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/10.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class FindLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    
    
    @IBOutlet weak var findLocationTableView: UITableView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    
    //資料
    var allLocation = [LandMark]()
    var nearLocations = [LandMark]()
    var currentLocations = [LandMark]() // update table
    var cameraLandMark : LandMark?
    
    
    //GPS
    var requestParam = [String: Double]()
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //run
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.findLocationTableView.tableFooterView = UIView()
        self.findLocationTableView.backgroundView = activityIndicatorView
        
        //searchBar
        setUpSearchBar()
        alterLayout()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //GPS
        let latitude = requestParam["latitude"]
        let longitude = requestParam["longitude"]
        findNearLocationInfo(latitude!, longitude!)
        findAllLocationInfo()
        //run
        if nearLocations.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearLocationCell", for: indexPath) as? NearLocationTableViewCell else {
            return UITableViewCell()
        }
        
        let nearLocation = currentLocations[indexPath.row]
        cell.nearLocationName.text = nearLocation.name
        cell.nearLocationAddress.text = nearLocation.address
        cell.nearLocationType.text = nearLocation.type
        findImage(nearLocation.id!,cell)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cameraLandMark = currentLocations[indexPath.row]

        //發送通知
        let notificationName = Notification.Name("locationCreate")
        let locationall = LandMark(cameraLandMark!.id!,cameraLandMark!.address!)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["location":locationall])
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "camera") {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return locationSearchBar
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let sourceController = segue.destination as? CameraViewController
        

    }
    
    //取得地標圖片
    func findImage(_ landMarkID:Int, _ cell:NearLocationTableViewCell) {
        let url_server = URL(string: common_url + "LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = landMarkID
        requestParam["imageSize"] = 1024
        //        requestParam["imageSize"] = "\(UIScreen.main.bounds)"
        var image: UIImage?
        cell.naerLocationImage.image = nil
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
        let url_server = URL(string: common_url + "LocationServlet")
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
                        self.currentLocations = self.nearLocations
                        DispatchQueue.main.async {
                            self.activityIndicatorView.stopAnimating()
                            self.findLocationTableView.reloadData()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.findLocationTableView.reloadData()
                    }
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    
    //取得所有地標
    func findAllLocationInfo() {
        let url_server = URL(string: common_url + "LocationServlet")
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

    func setUpSearchBar() {
        locationSearchBar.delegate = self
//       let myColor : UIColor = UIColor(red: 75.0/255.0, green: 187.0/255.0, blue: 164.0/255.0, alpha: 1.0) locationSearchBar.setScopeBarButtonTitleTextAttributes(myColor, for: .normal)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
//        guard !searchText.isEmpty else {
//            currentLocations = allLocation
//            self.findLocationTableView.reloadData()
//            return
//        }
        switch searchBar.selectedScopeButtonIndex {
            case 0:
                currentLocations = nearLocations.filter({ landMark -> Bool in
                    if searchText.isEmpty {
                        self.currentLocations = self.nearLocations
                        self.findLocationTableView.reloadData()
                        return true
                    }
                    let result = landMark.address!.lowercased().contains(searchText.lowercased())
                    self.findLocationTableView.reloadData()
                    return result
                })
                break
            case 1:
                currentLocations = allLocation.filter({ landMark -> Bool in
                    if searchText.isEmpty { return true }
                    let result = landMark.address!.lowercased().contains(searchText.lowercased())
                    self.findLocationTableView.reloadData()
                    return result
                })
                break
            default:
                break
            }
        
        self.findLocationTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        switch selectedScope {
        case 0:
            currentLocations = nearLocations
            self.findLocationTableView.reloadData()
            break
        case 1:
            currentLocations = allLocation
            self.findLocationTableView.reloadData()
            break
        default:
            break
        }
        self.findLocationTableView.reloadData()
    }
    
    func alterLayout() {
//        findLocationTableView.tableHeaderView = UIView()
//        findLocationTableView.estimatedSectionHeaderHeight = 50
//        locationSearchBar.placeholder = "Address"
    }
    
    
}
