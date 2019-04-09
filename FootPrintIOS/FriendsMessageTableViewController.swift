//
//  FriendsMessageTableViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/1.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import Starscream


class FriendsMessageTableViewController: UITableViewController {
    var friends = [Friends]()
    var user = loadData()
    var friendship = [String]()
    var friendsMessage = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let friendViewController = parent as? FriendViewController
//        friends = friendViewController!.friends
//        for i in 0 ..< friends.count{
//            if(friends[i].invitee == user.account){
//                friendship.insert(friends[i].inviter!, at: i)
//            }else{
//                friendship.insert(friends[i].invitee!, at: i)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        getAllFriendsMessage()
    }

    override func viewDidAppear(_ animated: Bool) {
        let friendViewController = parent as? FriendViewController
        friends = friendViewController!.friends
        getAllFriendsMessage()
    }
    
    @objc func getAllFriendsMessage(){
        let url_server = URL(string: common_url + "FriendsMessageServlet")
        var requestParam = [String: String]()
        friendship = []
        for i in 0 ..< friends.count{
            if(friends[i].invitee == user.account){
                friendship.insert(friends[i].inviter!, at: i)
            }else{
                friendship.insert(friends[i].invitee!, at: i)
            }
        }
        requestParam["action"] = "findMessageList"
        requestParam["userId"] = user.account
        requestParam["friendList"] = try! String(data: JSONEncoder().encode(friendship), encoding: .utf8)
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil{
                if data != nil {
//                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([Message].self, from: data!){
                        self.friendsMessage = result
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsMessage.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsmessagecell") as! FriendsMessageListTableViewCell
        let friend = friendsMessage[indexPath.row]
        
        let friendId:String
        if friend.sender == user.account{
            friendId = friend.receiver!
        }else{
            friendId = friend.sender!
        }
        
        let url_server = URL(string: common_url + "PicturesServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "findUserHeadImage"
        requestParam["userId"] = friendId
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
                    cell.iv_HeadImage.image = headImage
                    cell.iv_HeadImage.layer.cornerRadius = cell.iv_HeadImage.frame.width/2
                }
                //設定button為圓形
            } else {
                print(error!.localizedDescription)
            }
        }
        
        var nickNamerequestParam = [String: String]()
        let nicknameUrl_server = URL(string: common_url + "PicturesServlet")
        nickNamerequestParam["action"] = "findUserNickName"
        nickNamerequestParam["id"] = friendId
        executeTask(nicknameUrl_server!, nickNamerequestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
//                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    let result = String(data: data!, encoding: .utf8)!
                    DispatchQueue.main.async {
                        cell.lb_UserNickName.text = result
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        cell.lb_Message.text = friend.content
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat"{
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
                let friend = friendsMessage[indexPath!.row]
            
                let friendId:String
                if friend.sender == user.account{
                   friendId = friend.receiver!
                }else{
                   friendId = friend.sender!
                }
            
                let destination = segue.destination as! ChatViewController
                destination.friend = friendId
//              destination.socket = socket
        }
    }
}
