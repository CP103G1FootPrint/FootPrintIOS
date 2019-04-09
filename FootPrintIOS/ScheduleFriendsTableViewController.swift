//
//  ScheduleFriendsTableViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/4/6.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class ScheduleFriendsTableViewController: UITableViewController {
    var trips: Trip!
    var friend:String?
    var less:String?
    var requestParam = [String: Any]()
    
    var friendList = [Friends]()
    var list_item = [String]()
    var addfriend = [String]()
    var oldFriend = [TripPlanFriend]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getTripFriends()
        getAllFriends()
        
        
        self.tableView.reloadData()
    }
    
    func getAllFriends(){
        let user = loadData()
        let account = user.account
        let url_server = URL(string: common_url + "/FriendsServlet")
        requestParam["action"] = "getAllFriends"
        requestParam["userId"] = account
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([Friends].self, from: data!) {
                        
                        self.friendList = result
                        
        
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
    
    
    func getTripFriends(){
        //        //抓取已加入行程好友
        let url_server = URL(string: common_url + "/TripServlet")
        requestParam["action"] = "getTripFriends"
        requestParam["tripId"] = trips.tripID
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([TripPlanFriend].self, from: data!) {
                        self.oldFriend = result
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
    
    

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = loadData()
        //        let account = user.account
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendListTableViewCell
        
//        friendList.removeAll { (friendlist) -> Bool in
//            let friend = friendlist.invitee == user.account
//            return friend
//        }
        
       
        print("321\(indexPath.row)")
        print("123\(list_item[indexPath.row])")
        
        
        
        let b = list_item.filter{$0 != oldFriend[indexPath.row].invitee }
        less = b.joined(separator:",")
        
    
        //抓取好友暱稱
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "PicturesServlet")
        requestParam["action"] = "findUserNickName"
        requestParam["id"] = less
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    let result = String(data: data!, encoding: .utf8)!
                    DispatchQueue.main.async {
                        cell.friendNameLabel.text = result
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        
        //抓取頭像
        requestParam["action"] = "findUserHeadImage"
        requestParam["userId"] = less
        requestParam["imageSize"] = "30"
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
                    //圓形大頭照
                    cell.friendImageView.frame = CGRect(x:12, y:10, width:30, height:30)
                    cell.friendImageView.contentMode = .scaleAspectFill
                    cell.friendImageView.layer.masksToBounds = true
                    cell.friendImageView.layer.cornerRadius = cell.friendImageView.frame.width/2
                    cell.friendImageView.image = headImage
                   
                }
                
            } else {
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    //移除勾選掉的好友
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("a8")
        let name = list_item[indexPath.row]
        //        let name = friendArray[indexPath.row]
        for i in 0 ..< addfriend.count{
            if(addfriend[i].contains(name)){
                addfriend.remove(at: i)
                break
            }
        }
        print("friendremovw :\(addfriend)")
    }
    
    
    //點選加入行程的好友
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("a9\(list_item[indexPath.row])")
        addfriend.append(list_item[indexPath.row])
        
        //        if(a.contains(x)){
        //            a.remove(at: indexPath.row)
        //        }else{
        //            a.append(x)
        //        }
        
        print("friendadd :\(addfriend)")
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
