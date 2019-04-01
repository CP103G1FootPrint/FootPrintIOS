//
//  AddFriendListTableViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/16.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class AddFriendListTableViewController: UITableViewController {
    var list_item :[String]?
    var friendList = [CreateTripFriends]()
    let url_server = URL(string: common_url + "/FriendsServlet")
    var requestParam = [String: String]()
    
    var friendArray: [String] = Array()

    var addfriend = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
//        friendArray.append("Tom")
//        friendArray.append("Vivian")
//        friendArray.append("Sandy")
//        friendArray.append("May")

        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        tableView.delegate = self
        tableView.dataSource = self
        
        getAllFriends()
        
    }
    
    func getAllFriends(){
        let user = loadData()
        let account = user.account
        requestParam["action"] = "getAllFriends"
        requestParam["userId"] = account
        
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([CreateTripFriends].self, from: data!) {
                        self.friendList = result
                        
//                        var size = self.friendList.count
////                        let list_item = [mount]
//                        for i in 0 ..< size{
//                            if self.friendList.inviter = userId{
//                                
//                            }
//                        }
                        
                        _ = try? JSONDecoder().decode(String.self, from: data!)
                        
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return friendArray.count
        return friendList.count
    }

    //設定cell要顯示的內容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = loadData()
        let account = user.account
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendListTableViewCell
        
//        cell.friendNameLabel.text = friendArray[indexPath.row]
        cell.friendNameLabel.text = friendList[indexPath.row].inviter
        
        //抓取頭像
        let url_server = URL(string: common_url + "PicturesServlet")
        requestParam["action"] = "findUserHeadImage"
        requestParam["userId"] = account
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
                    cell.friendImageView.frame = CGRect(x:35, y:10, width:30, height:30)
                    cell.friendImageView.contentMode = .scaleAspectFill
                    cell.friendImageView.layer.masksToBounds = true
                    cell.friendImageView.layer.cornerRadius = cell.friendImageView.frame.width/2
                    cell.friendImageView.image = headImage
//                    self.view.addSubview(cell.friendImageView)
                }
                
            } else {
                print(error!.localizedDescription)
            }
        }
        
        
        
//        cell.checkboxButton.addTarget(self, action: #selector(clickCheckbox(sender:)), for: .touchUpInside)

        return cell
    }
    
    //移除勾選掉的好友
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let name = friendList[indexPath.row]
        
        
//        let name = friendArray[indexPath.row]
//        for i in 0 ..< addfriend.count{
//            if(addfriend[i].contains(name)){
//                addfriend.remove(at: i)
//                break
//            }
//        }
        
        print("friendremovw :\(addfriend)")
    }
    
    
    
    
    //點選加入行程的好友
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        addfriend.append(friendArray[indexPath.row])

//        if(a.contains(x)){
//            a.remove(at: indexPath.row)
//        }else{
//            a.append(x)
//        }

        print("friendadd :\(addfriend)")
    }
    

    
    
//    @objc func clickCheckbox (sender : UIButton){
//        print("button pressed")
//        if sender.isSelected{
//            sender.isSelected = false
//        }else{
//            sender.isSelected = true
//        }
//
//    }
    

    
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

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       let controller = segue.destination as? CreateTripViewController
        controller?.tripfriend = addfriend
        

    }
    
//    @IBAction func doneButtonPressed(_ sender: Any) {
//        if let controller = storyboard?.instantiateViewController(withIdentifier: "createTripViewController") as? CreateTripViewController{
//            controller.tripfriend = addfriend
//            present(controller,animated: true,completion: nil)
//        }
    
        
////        let mySet = Set<String>(a);
////        print("test\(mySet)")
//        self.navigationController?.popViewController(animated: true)
    
    
    
    
}
