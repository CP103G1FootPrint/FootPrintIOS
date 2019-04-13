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
    let user = loadData()
    var imageDic = [Int : UIImage]()
    @IBOutlet weak var nv: UINavigationItem!
    
    let url_server = URL(string: common_url + "PicturesServlet")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView =  UIView()
        tableViewAddRefreshControl()
        showAllNews()
    }
    
    /** tableView加上下拉更新功能 */
    func tableViewAddRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(showAllNews), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        showAllNews()
    }
    
    @objc func showAllNews() {
        var requestParam = [String: String]()
        requestParam["action"] = "getAlls"
        requestParam["userId"] = user.account
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
//                    print("input: \(String(data: data!, encoding: .utf8)!)")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell") as! NewsTableViewCell
        let new = news[indexPath.row]
        
        let likes = Likes(user.account, new.imageID!)
//        cell.iv_NewsPicture.image = nil
//        cell.bt_HeadPicture.imageView = nil
        cell.like = likes
        cell.news = new
        cell.bt_Message.tag = indexPath.row
        cell.bt_HeadPicture.tag = indexPath.row
        cell.bt_LandMark.tag = indexPath.row
        cell.bt_NickName.tag = indexPath.row
        cell.bt_LandMark.tag = indexPath.row
        
        //存圖片
        if let image = self.imageDic[new.imageID!]{
            cell.iv_NewsPicture.image = image
        }else{
            cell.iv_NewsPicture.image = nil
        
        // 尚未取得圖片，另外開啟task請求
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = new.imageID
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
                }
                if headImage == nil {
                    headImage = UIImage(named: "album")
                }
                DispatchQueue.main.async {
                    cell.bt_HeadPicture.setImage(headImage, for: .normal)
                    //設定button圖案為圓形
                    cell.bt_HeadPicture.imageView?.layer.cornerRadius = cell.bt_HeadPicture.frame.width/2
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        }
        
        cell.lb_LikesCount.text = new.likesCount + " people likes"
        cell.bt_LandMark.setTitle(new.landMarkName, for: .normal)
        cell.bt_NickName.setTitle(new.nickName, for: .normal)
        cell.lb_description.text = new.description
        cell.bt_Message.tag = indexPath.row
        
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
    
    @IBAction func bt_Personal(_ sender: UIButton) {
         if let controller = storyboard?.instantiateViewController(withIdentifier: "HomeNewsPersonalViewController") as? HomeNewsPersonalViewController{
             let new = news[sender.tag]
             let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? NewsTableViewCell
             let image = cell?.bt_HeadPicture.image(for: .normal)
             controller.news = new
            controller.headimage = image
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    @IBAction func bt_PersonalPage(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "HomeNewsPersonalViewController") as? HomeNewsPersonalViewController{
             let new = news[sender.tag]
             let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? NewsTableViewCell
             let image = cell?.bt_HeadPicture.image(for: .normal)
             controller.news = new
             controller.headimage = image
            navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    @IBAction func bt_Comment(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "NewsCommentViewController") as? NewsCommentViewController{
//            let buttontag = sender.tag
            let new = news[sender.tag]
            controller.news = new
            let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? NewsTableViewCell
            let image = cell?.bt_HeadPicture.image(for: .normal)
            controller.headImage = image
            navigationController?.pushViewController(controller, animated: true)
//          present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func bt_LandMark(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "LandMarkDetailViewController") as? LandMarkDetailViewController{
            let new = news[sender.tag]
            let landmark = LandMark(new.landMarkName!, new.landMarkID!)
            controller.location = landmark
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
