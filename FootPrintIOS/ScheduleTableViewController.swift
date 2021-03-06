//
//  ScheduleTableViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/6.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController {
    var imageDic = [Int: UIImage]()
    
    var activityIndicatorView: UIActivityIndicatorView!
    var trips = [Trip]()
    let url_server = URL(string: common_url + "/TripServlet")
    var emptyView: UIView!
    
    override func loadView() {
        super.loadView()
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        tableView.backgroundView = activityIndicatorView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewAddRefreshControl()
        
    }
    /** tableView加上下拉更新功能 */
    func tableViewAddRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(showAllTrips), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    override func viewWillAppear(_ animated: Bool) {
        showAllTrips()
        if trips.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }
    @objc func showAllTrips() {
        
        let user = loadData()
        let account = user.account
        
        var requestParam = [String: String]()
        
        requestParam["action"] = "All"
        requestParam["createID"] = account
        

        
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
//                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    
                    if let result = try? JSONDecoder().decode([Trip].self, from: data!) {
                        self.trips = result
//                        self.trips.reverse()
//                        _ = try? JSONDecoder().decode(String.self, from: data!)
//                        
              
                        DispatchQueue.main.async {
                            if let control = self.tableView.refreshControl {
                                self.activityIndicatorView.stopAnimating()
                                // if emptyview is empty
                                if self.emptyView == nil {
                                    self.emptyView = self.tableView.setEmptyView(title: "You don't have any trip.", message: "Start creating your trip", messageImage: UIImage(named: "airplane1")!)
                                }
                                
                                if self.trips.count > 0 || !self.trips.isEmpty {
                                    if self.emptyView != nil {
                                       
                                        self.emptyView.isHidden = true
                                    }
                                }
                                
                                if control.isRefreshing {
                                    // 停止下拉更新動作
                                    control.endRefreshing()
                                    
                                }
                            }
                            print("reloadData")

                            /* 抓到資料後重刷table view */
                            self.tableView.reloadData()
                        }
                        }}
                
                
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    

    /* UITableViewDataSource的方法，定義表格的區塊數，預設值為1 */
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "tripCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ScheduleTableViewCell
        let trip = trips[indexPath.row]
        cell.photoButton.tag = indexPath.row
        cell.messageButton.tag = indexPath.row
        cell.shareButton.tag = indexPath.row
        cell.friendButton.tag = indexPath.row
//        cell.photoButton.addTarget(self, action:#selector(albumButton), for: .touchUpInside)
        
//        cell.trips = trip
        // 尚未取得圖片，另外開啟task請求
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = trip.tripID
        // 圖片寬度為tableViewCell的1/4，ImageView的寬度也建議在storyboard加上比例設定的constraint
        requestParam["imageSize"] = cell.frame.width 
        var image: UIImage?
        
        if let image = self.imageDic[trip.tripID!] {
            cell.photoImageView.image = image
        } else {
            cell.photoImageView.image = nil
            
            executeTask(url_server!, requestParam) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        image = UIImage(data: data!)
                        self.imageDic[trip.tripID!] = image
                    }
                    if image == nil {
                        image = UIImage(named: "noimage.jpg")
                    }
                    DispatchQueue.main.async { cell.photoImageView.image = image }
                } else {
                    print(error!.localizedDescription)
                }
            }
        }
       
        cell.tripNameLabel.text = trip.title
        cell.dateLabel.text = trip.date
        return cell
    }
    

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
     //左滑修改與刪除資料
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        // 左滑時顯示Delete按鈕
        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Delete", handler: { (action, indexPath) in
            //Alert確認是否刪除資料
            let alert = UIAlertController(title: "note", message: "確定要刪除行程嗎？", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default,handler: { action in
            
            // 尚未刪除server資料
            var requestParam = [String: Any]()
            requestParam["action"] = "tripDelete"
            requestParam["tripId"] = self.trips[indexPath.row].tripID
            executeTask(self.url_server!, requestParam
                , completionHandler: { (data, response, error) in
                    if error == nil {
                        if data != nil {
                            if let result = String(data: data!, encoding: .utf8) {
                                if let count = Int(result) {
                                    // 確定server端刪除資料後，才將client端資料刪除
                                    if count != 0 {
                                        self.trips.remove(at: indexPath.row)
                                        DispatchQueue.main.async {
                                            tableView.deleteRows(at: [indexPath], with: .fade)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
            })})
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        })
        
        
        
        //設定往左滑刪除的樣式
        let view = UIView(frame: CGRect(x: tableView.frame.size.width-70, y: 20, width: 200, height: 200))
        //側滑匡的底色
        view.backgroundColor = UIColor(red: 155.0/255.0, green: 245.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        //圖片大小
        let imageView = UIImageView(frame: CGRect(x: 10,
                                                  y: 100,
                                                  width: 60,
                                                  height: 60))
        //圖片來源
        imageView.image = UIImage(named: "delete")
        //圖片加入側滑的刪除匡
        view.addSubview(imageView)
        let image = view.image()
        //加入到 UITableViewRowAction
        delete.backgroundColor = UIColor(patternImage: image)
        delete.title = ""
    return [delete]

    }
    
    //分享至動態
    @IBAction func shareButton(_ sender: UIButton) {
        let buttontag = sender.tag
        let trip = trips[buttontag]
       
        let actionSheet = UIAlertController.init(title: "", message: trip.date, preferredStyle: .actionSheet)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: trip.title!, attributes: titleAttributes)
        actionSheet.setValue(titleString, forKey: "attributedTitle")
        

        
        actionSheet.addAction(UIAlertAction.init(title: "分享至動態", style: .default,handler: { action in
            
            var requestParam = [String: Any]()
            requestParam["action"] = "tripShare"
            requestParam["openState"] = "open"
            requestParam["tripId"] = trip.tripID
            executeTask(self.url_server!, requestParam
                , completionHandler: { (data, response, error) in
                    if error == nil {
                        if data != nil {
                            if let result = String(data: data!, encoding: .utf8) {
                                if let count = Int(result) {
                                    // 確定server端刪除資料後，才將client端資料刪除
                                    if count != 0 {
                                        let alertController = UIAlertController(title: "Share success",
                                                                                message: nil, preferredStyle: .alert)
                                        
                                        self.present(alertController, animated: true, completion: nil)
                                        DispatchQueue.main.async {
                                            self.presentedViewController?.dismiss(animated: false, completion: nil)
                                           
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
            })
            
        }))
        
        
        actionSheet.view.tintColor = .orange
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
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

    
    /* 因為拉UITableViewCell與detail頁面連結，所以sender是UITableViewCell */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "planDetail" {
            /* indexPath(for:)可以取得UITableViewCell的indexPath */
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            let trip = trips[indexPath!.row]
            let detailVC = segue.destination as! PlanViewController
            detailVC.trip = trip
        }
    }
   
    
    
    @IBAction func albumButton(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "groupAlbum") as? GroupAlbumCollectionViewController{
            let buttontag = sender.tag
            let trip = trips[buttontag]
            controller.trips = trip
       navigationController?.pushViewController(controller, animated: true)
//            present(controller,animated: true,completion: nil)
    }
    
    }
    
    @IBAction func messageButtonClick(_ sender:UIButton) {
        
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "groupMessage") as? GroupMessageViewController{
            let buttontag = sender.tag
            let trip = trips[buttontag]
            controller.trips = trip
            navigationController?.pushViewController(controller, animated: true)
        }
    }
   
    
    @IBAction func tripFriendButtonClick(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "shedulefriend") as? ScheduleFriendsTableViewController{
            let buttontag = sender.tag
            let trip = trips[buttontag]
            controller.trips = trip
            navigationController?.pushViewController(controller, animated: true)
        }
        
        
//        func clickButton (sender : UIButton){
//                    print("button pressed")
//                    if sender.isSelected{
//                        sender.isSelected = false
//                    }else{
//                        sender.isSelected = true
//                    }
//
//                }
        
        
        
//        let tableViewController = FriendsAlertViewTableViewController()
//        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
//        alertController.setValue(tableViewController, forKey: "contentViewController")
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
//        alertController.addAction(cancelAction)
//        self.present(alertController, animated: true, completion: nil)
//
//        alertController.setValue(tableViewController, forKey: "contentViewController")
        
        
//        let actionSheet = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
//        var view = UITableView(frame: CGRect(x: 8.0, y: 8.0, width: actionSheet.view.bounds.size.width - 8.0 * 4.5, height: 120.0))
//        view.backgroundColor = UIColor.green
//        actionSheet.view.addSubview(view)
//        actionSheet.addAction(UIAlertAction(title: "將好友加入群組", style: .default,handler: { action in
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
}
//客制tableView 往左滑UIView
extension UIView {
    func image() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


