//
//  SegmentGroupTableViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/31.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class SegmentGroupTableViewController: UITableViewController {
    
    
    var activityIndicatorView: UIActivityIndicatorView!
    var trips = [Trip]()
    let url_server = URL(string: common_url + "/TripServlet")
    
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
        refreshControl.addTarget(self, action: #selector(showGroupTrips), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showGroupTrips()
        if trips.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }
    @objc func showGroupTrips() {
        let user = loadData()
        let account = user.account
        
        var requestParam = [String: String]()
        
        requestParam["action"] = "Group"
        requestParam["type"] = "Group"
        requestParam["createID"] = account
        
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    
                    if let result = try? JSONDecoder().decode([Trip].self, from: data!) {
                        self.trips = result
                      
//                        self.trips.reverse()
//                        _ = try? JSONDecoder().decode(String.self, from: data!)
//                        if result.isEmpty{
//                            self.tableView.setEmptyView(title: "You don't have any trip.", message: "Start creating your trip", messageImage: UIImage(named: "airplane1")!)
//                        }
                        
    
                        DispatchQueue.main.async {
                            if let control = self.tableView.refreshControl {
                                self.activityIndicatorView.stopAnimating()
                                
                                self.tableView.setEmptyView(title: "You don't have any trip.", message: "Start creating your trip", messageImage: UIImage(named: "airplane1")!)
                                
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if trips.count == 0 {
//            activityIndicatorView.startAnimating()
//
//        }
//        else {
//            tableView.restore()
//        }
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
        //        cell.trips = trip
        // 尚未取得圖片，另外開啟task請求
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = trip.tripID
        // 圖片寬度為tableViewCell的1/4，ImageView的寬度也建議在storyboard加上比例設定的constraint
        requestParam["imageSize"] = cell.frame.width
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "noimage.jpg")
                }
                DispatchQueue.main.async { cell.photoImageView.image = image }
            } else {
                print(error!.localizedDescription)
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
        
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupplanDetail" {
            /* indexPath(for:)可以取得UITableViewCell的indexPath */
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            let trip = trips[indexPath!.row]
            let detailVC = segue.destination as! PlanViewController
            detailVC.trip = trip
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
//客制tableView 往左滑UIView
//extension UIView {
//    func image() -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
//        guard let context = UIGraphicsGetCurrentContext() else {
//            return UIImage()
//        }
//        layer.render(in: context)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image!
//    }
//
//}

//extension UITableView {
//    
//    func setEmptyView(title: String, message: String, messageImage: UIImage) {
//        
//        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
//        
//        let messageImageView = UIImageView()
//        let titleLabel = UILabel()
//        let messageLabel = UILabel()
//        
//        messageImageView.backgroundColor = .clear
//        
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        messageImageView.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        titleLabel.textColor = UIColor.black
//        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
//        
//        messageLabel.textColor = UIColor.lightGray
//        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
//        
//        emptyView.addSubview(titleLabel)
//        emptyView.addSubview(messageImageView)
//        emptyView.addSubview(messageLabel)
//        
//        messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
//        messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20).isActive = true
//        messageImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
//        messageImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
//        
//        titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 10).isActive = true
//        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
//        
//        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
//        messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
//        
//        messageImageView.image = messageImage
//        titleLabel.text = title
//        messageLabel.text = message
//        messageLabel.numberOfLines = 0
//        messageLabel.textAlignment = .center
//        
//        UIView.animate(withDuration: 1, animations: {
//            
//            messageImageView.transform = CGAffineTransform(rotationAngle: .pi / 10)
//        }, completion: { (finish) in
//            UIView.animate(withDuration: 1, animations: {
//                messageImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 10))
//            }, completion: { (finishh) in
//                UIView.animate(withDuration: 1, animations: {
//                    messageImageView.transform = CGAffineTransform.identity
//                })
//            })
//            
//        })
//        
//        self.backgroundView = emptyView
//        self.separatorStyle = .none
//    }
//    
//    func restore() {
//        
//        self.backgroundView = nil
//        self.separatorStyle = .singleLine
//        
//    }
//    
//}
