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
    var list_item = [String]()//ㄑ全部朋友
    var trip_item = [String]()
    var addfriend = [String]()
    var oldFriend = [String]()
    
    var final = [String]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        getTripFriends()
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
                        for itemFirst in self.friendList{
                            if itemFirst.invitee != account{
                                //                                x.app[itemFirst.invitee]
                                self.list_item.append(itemFirst.invitee!)
                            }else{
                                //                                x.app[itemFirst.inviter]
                                self.list_item.append(itemFirst.inviter!)
                            }
                        }
                        
                        print("5555 \(self.list_item)")
                        
        
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
        
        let url_trip = URL(string: common_url + "/TripServlet")
        requestParam["action"] = "getTripFriends"
        requestParam["tripId"] = trips.tripID
        executeTask(url_trip!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([String].self, from: data!) {
                        self.oldFriend = result
//                        for itemSe in self.oldFriend{
//                            if itemSe != account{
//                                self.trip_item.append(itemSe)
//                            }else{
//                                break
//                            }
//                        }
                        
                        self.trip_item = [self.oldFriend.remove(at: 1)]
                        
                        
                        print("rrr \(self.trip_item)")
                        
                        let all = self.list_item + self.trip_item
                        print("222 \(all)")
                        self.final = all.removingDuplicates()
                        print("0000 \(self.final)")
                        
                        
                        
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
    
    
//    func getTripFriends(){
//        //        //抓取已加入行程好友
//        let user = loadData()
//        let account = user.account
//
//    }
    
    

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return final.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendListTableViewCell
        let finally = final[indexPath.row]
//        friendList.removeAll { (friendlist) -> Bool in
//            let friend = friendlist.invitee == user.account
//            return friend
//        }
        
       
//        print("321\(indexPath.row)")
//        print("123\(list_item[indexPath.row])")
//
//
//
//        let b = list_item.filter{$0 != oldFriend[indexPath.row].invitee }
//        less = b.joined(separator:",")
//        let friend = final.
    
        //抓取好友暱稱
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "PicturesServlet")
        requestParam["action"] = "findUserNickName"
        requestParam["id"] = finally
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
        requestParam["userId"] = finally
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
    
    //....
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
    
    @IBAction func doneButton(_ sender: Any) {
        //新增好友到行程
        let user = loadData()
        let account = user.account
        var tripPlanFriendss = [TripPlanFriend]()
        for i in 0 ..< addfriend.count{
            let items = addfriend[i]
            let tripPlanFriends = TripPlanFriend(account,items,trips.tripID!)
            tripPlanFriendss.append(tripPlanFriends)
        }
        let url_trip = URL(string: common_url + "/TripServlet")
        requestParam["action"] = "tripPlanFriendInsert"
        requestParam["tripPlanFriends"] = try! String(data: JSONEncoder().encode(tripPlanFriendss), encoding: .utf8)
        executeTask(url_trip!, requestParam
            , completionHandler: { (data, response, error) in
                if error == nil {
                    if data != nil {
                        if let result = String(data: data!, encoding: .utf8) {
                            if let count = Int(result) {
                                DispatchQueue.main.async {
                                    // 新增成功則回前頁
                                    if count != 0 {                                            self.navigationController?.popViewController(animated: true)
                                    } else {
                                        let alertController = UIAlertController(title: "insert fail",
                                                                                message: nil, preferredStyle: .alert)
                                        self.present(alertController, animated: true, completion: nil)
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                            self.presentedViewController?.dismiss(animated: false, completion: nil)
                                        }
                                    }
                                }
                        }
                    }
                } else {
                    print(error!.localizedDescription)
                }
        }
        
    }
    
   ) }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
