//
//  PersonalNotifyVC.swift
//  FootPrintIOS
//
//  Created by ChiaLi Wang on 2019/3/18.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import Starscream

class PersonalNotifyVC: UIViewController,UITableViewDataSource {
    var notifies = [Friends]()
    var user = loadData()
    var socket: WebSocket!
    let url_server = "ws://127.0.0.1:8080/FootPrint/FriendShipServer/"
//    let url_server = "ws://192.168.50.4:8080/FootPrint/FriendShipServer/"
//    let url_server = "ws://192.168.196.217:8080/FootPrint/FriendShipServer/"
    @IBOutlet weak var notifyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = WebSocket(url: URL(string: url_server + user.account)!)
        //取消多餘的格線
        self.notifyTableView.tableFooterView = UIView()
        addSocketCallBacks()
        socket.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllNotify()
    }
    
    func addSocketCallBacks() {
        socket.onText = { (text: String) in
            if let chatMessage = try? JSONDecoder().decode(Friends.self, from: text.data(using: .utf8)!) {
                let invitee = chatMessage.invitee
                // 接收到聊天訊息，若發送者與目前聊天對象相同，就將訊息顯示在TextView
                if invitee == self.user.account {
                    self.notifies.insert(chatMessage, at: self.notifies.count)
                    self.notifyTableView.reloadData()
                }
            }
        }
    }
    
    @objc func getAllNotify(){
        let url_server = URL(string: common_url + "FriendsServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "getAllFriendsNotify"
        requestParam["userId"] = user.account

        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([Friends].self, from: data!){
                        self.notifies = result
                        DispatchQueue.main.async {
                            self.notifyTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
                    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(notifies)
        return notifies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifycell") as! NotifyTableViewCell
        let notify = notifies[indexPath.row]
        cell.lb_Message.text = notify.message
        cell.bt_Agree.tag = indexPath.row
        cell.bt_DissAgree.tag = indexPath.row
        
        //抓取頭像
        let url_server = URL(string: common_url + "PicturesServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "findUserHeadImage"
        requestParam["userId"] = notify.inviter
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
                    cell.iv_HeadPicture.image = headImage
                    cell.iv_HeadPicture.layer.cornerRadius = cell.iv_HeadPicture.frame.width/2
                }
                //設定button為圓形
            } else {
                print(error!.localizedDescription)
            }
        }
        
        //抓使用者暱稱
        var nickNameRequestParam = [String: String]()
        nickNameRequestParam["action"] = "findUserNickName"
        nickNameRequestParam["id"] = notify.inviter
        executeTask(url_server!, nickNameRequestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    let result = String(data: data!, encoding: .utf8)!
                    DispatchQueue.main.async {
                        cell.lb_UserNickName.text = result + " 想加你為好友"
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    @IBAction func bt_Agree(_ sender: UIButton) {
        let buttontag = sender.tag
        let notify = notifies[buttontag]
        let friend = Friends(notify.inviter!, notify.invitee!)
        let url_server = URL(string: common_url + "FriendsServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "update"
        requestParam["update"] = try! String(data: JSONEncoder().encode(friend), encoding: .utf8)
        executeTask(url_server!, requestParam) { (data, response, error) in
            // 將輸入資料列印出來除錯用
            // print("input: \(String(data: data!, encoding: .utf8)!)")
        }
        notifies.remove(at: buttontag)
        self.notifyTableView.reloadData()
    }
    
    @IBAction func bt_DissAgree(_ sender: UIButton) {
        let buttontag = sender.tag
        let notify = notifies[buttontag]
        let friend = Friends(notify.inviter!, notify.invitee!)
        let url_server = URL(string: common_url + "FriendsServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "delete"
        requestParam["delete"] = try! String(data: JSONEncoder().encode(friend), encoding: .utf8)
         executeTask(url_server!, requestParam) { (data, response, error) in
            // 將輸入資料列印出來除錯用
            // print("input: \(String(data: data!, encoding: .utf8)!)")
        }
        notifies.remove(at: buttontag)
        self.notifyTableView.reloadData()
    }
}
