//
//  FriendsViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/1.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tv_TableView: UITableView!
    @IBOutlet weak var lb_FriendsCounter: UILabel!
    let user = loadData()
    var friend:String?
    var friends = [Friends]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tv_TableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let friendViewController = parent as? FriendViewController
        friends = friendViewController!.friends
        self.lb_FriendsCounter.text = "好友數量:\(self.friends.count)人"
        tv_TableView.reloadData()

//        if friends.count == 0 {
//            tv_TableView.reloadData()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "frinedShipList") as! FriendShipListTableViewCell
        let friendship = friends[indexPath.row]
        
        if friendship.invitee == user.account{
             friend = friendship.inviter
        }else{
             friend = friendship.invitee
        }
        //抓取好友暱稱
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "PicturesServlet")
        requestParam["action"] = "findUserNickName"
        requestParam["id"] = friend
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    let result = String(data: data!, encoding: .utf8)!
                    DispatchQueue.main.async {
                        cell.lb_NickName.text = result
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    
        //抓取好友頭像
        let url_imageServer = URL(string: common_url + "PicturesServlet")
        var requsetParam2 = [String: Any]()
        requsetParam2["action"] = "findUserHeadImage"
        requsetParam2["userId"] = friend
        requsetParam2["imageSize"] = cell.frame.width / 10
        var headImage: UIImage?
        executeTask(url_imageServer!, requsetParam2) { (data, response, error) in
            if error == nil {
                if data != nil {
                    headImage = UIImage(data: data!)
                }
                if headImage == nil{
                   headImage = UIImage(named: "album")
                }
                DispatchQueue.main.async {
                    cell.iv_HeadPicture.image = headImage
                    cell.iv_HeadPicture.layer.cornerRadius = cell.iv_HeadPicture.frame.width/2
                }
            }
        }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendchat"{
            let indexPath = self.tv_TableView.indexPath(for: sender as! UITableViewCell)
            let friend = friends[indexPath!.row]
            
            let friendId:String
            if friend.inviter == user.account{
                friendId = friend.invitee!
            }else{
                friendId = friend.inviter!
            }
            let destination = segue.destination as! ChatViewController
            let cell = tv_TableView.cellForRow(at: indexPath!) as? FriendShipListTableViewCell
            destination.friend = friendId
            destination.ng_Item.title = cell?.lb_NickName.text
        }
    }
}
