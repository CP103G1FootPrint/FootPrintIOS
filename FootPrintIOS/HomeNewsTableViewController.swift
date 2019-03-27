//
//  HomeNewsTableViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/14.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class HomeNewsTableViewController: UITableViewController {
    var news = [News]()
    let url_server = URL(string: common_url + "PicturesServlet")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewAddRefreshControl()
    }
    
    /** tableView加上下拉更新功能 */
    func tableViewAddRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(showAllNews), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showAllNews()
    }
    
    @objc func showAllNews() {
        var requestParam = [String: String]()
        requestParam["action"] = "getAlls"
        requestParam["userId"] = "123"
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    
                    if let result = try? JSONDecoder().decode([News].self, from: data!) {
                        self.news = result
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
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func bt_Like(_ sender: Any) {
        
    }
    
    
    /* UITableViewDataSource的方法，定義表格的區塊數，預設值為1 */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "newsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NewsTableViewCell
        let new = news[indexPath.row]
        
        cell.news = new
        // 尚未取得圖片，另外開啟task請求
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = new.imageID
        //requestParam["findUserHeadImage"] = new.userID
        // 圖片寬度為tableViewCell的1/4，ImageView的寬度也建議在storyboard加上比例設定的constraint
        requestParam["imageSize"] = cell.frame.width
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "noImage.jpg")
                }
                DispatchQueue.main.async { cell.iv_NewsPicture.image = image }
                
            } else {
                print(error!.localizedDescription)
            }
        }
        
        //抓取頭像
        requestParam["action"] = "findUserHeadImage"
        requestParam["userId"] = new.userID
        requestParam["imageSize"] = cell.frame.width
        var headImage: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    headImage = UIImage(data: data!)
                    //                    print("get head image", indexPath.row)
                }
                if headImage == nil {
                    headImage = UIImage(named: "album")
                }
                DispatchQueue.main.async {
                    cell.bt_HeadPicture.setImage(headImage, for: .normal)
                    cell.bt_HeadPicture.imageView?.layer.cornerRadius = cell.bt_HeadPicture.frame.width/2
                    
                }
                //設定button為圓形
            } else {
                print(error!.localizedDescription)
            }
        }
        
        
        cell.lb_LikesCount.text = new.likesCount + " people likes"
        cell.bt_LandMark.setTitle(new.landMarkName, for: .normal)
        cell.bt_NickName.setTitle(new.nickName, for: .normal)
        cell.lb_description.text = new.description
        
        if new.likeId == 0{
            cell.bt_Like.isSelected = false
            cell.bt_Like.setImage(UIImage(named: "like-1"), for: .normal)
            
        }else{
            cell.bt_Like.isSelected = true
            cell.bt_Like.setImage(UIImage(named: "like-2"), for: .normal)
            
        }
        
        if new.collectionId == 0{
            cell.bt_Collection.isSelected = false
            cell.bt_Collection.setImage(UIImage(named: "collection2"), for: .normal)
        }else{
            cell.bt_Collection.isSelected = true
            cell.bt_Collection.setImage(UIImage(named: "collection"), for: .normal)
        }
        return cell
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

