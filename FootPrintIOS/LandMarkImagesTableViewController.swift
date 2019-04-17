//
//  LandMarkImagesTableViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class LandMarkImagesTableViewController: UITableViewController {

    var locationinfo = [LandMark]()
    var currentIndex : Int?
    var locationId : Int?
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        tableView.backgroundView = activityIndicatorView

    }

    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {

        findAllLocationInfo(locationId!)
        //run
        if locationinfo.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationinfo.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LandMarkImagesTableViewCell", for: indexPath) as! LandMarkImagesTableViewCell
        
        let location = locationinfo[indexPath.row]
        cell.userNameUILabel.text = location.nickName
        findLocationImage(location.imageID!, cell)
        
            findImageHead(location.account!, cell)
        
        return cell
    }
    
    //取得所有地標
    func findAllLocationInfo(_ locationId:Int) {
        let url_server = URL(string: common_url + "LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "findImageAndUserNickName"
        requestParam["id"] = locationId
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    //                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([LandMark].self, from: data!) {
                        self.locationinfo = result
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

    //取得頭像圖片
    func findImageHead(_ landMarkID:String, _ cell:LandMarkImagesTableViewCell) {
        let url_server3 = URL(string: common_url + "AccountServlet")
        var requestParam3 = [String: Any]()
        requestParam3["action"] = "headImage"
        requestParam3["userId"] = landMarkID
        requestParam3["imageSize"] = 512
        //        requestParam["imageSize"] = "\(UIScreen.main.bounds)"
        var image: UIImage?
        cell.userImageView.image = nil
        executeTask(url_server3!, requestParam3) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "user.png")
                }
                DispatchQueue.main.async {
                    cell.userImageView.image = image
                    cell.userImageView.layer.cornerRadius = 30
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    
    //取得圖片
    func findLocationImage(_ landMarkID:Int, _ cell:LandMarkImagesTableViewCell) {
        let url_server2 = URL(string: common_url + "LocationServlet")
        var requestParam2 = [String: Any]()
        requestParam2["action"] = "getInfoImage"
        requestParam2["id"] = landMarkID
        requestParam2["imageSize"] = 512
        //        requestParam["imageSize"] = "\(UIScreen.main.bounds)"
        var image: UIImage?
        cell.locationImageView.image = nil
        executeTask(url_server2!, requestParam2) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "album.png")
                }
                DispatchQueue.main.async {
                    cell.locationImageView.image = image

                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
