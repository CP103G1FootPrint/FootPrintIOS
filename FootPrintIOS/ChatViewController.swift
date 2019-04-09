//
//  ChatViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import Starscream

class ChatViewController: UIViewController,UITableViewDataSource {
    var friendMessages = [Message]()
    var friend: String?
    var user = loadData()
    var socket: WebSocket!
    let url_server = "ws://127.0.0.1:8080/FootPrint/ChatServer/"
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var tf_ChatMessage: UITextField!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendMessage = friendMessages[indexPath.row]
        if friendMessage.sender == user.account{
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightcell") as! RightChatTableViewCell
            cell.lb_ChatLabel.text  = friendMessage.content
            cell.lb_ChatLabel.layer.cornerRadius = 10
//            cell.lb_ChatLabel.layer.borderWidth = 1
            cell.lb_ChatLabel.layer.masksToBounds = true

            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "leftcell") as! LeftChatTableViewCell
            cell.lb_ChatLabel.text  = friendMessage.content
            
            cell.lb_ChatLabel.layer.cornerRadius = 10
            cell.lb_ChatLabel.layer.masksToBounds = true

//            cell.lb_ChatLabel.layer.borderWidth = 1
            
            //抓取頭像
            let url_server = URL(string: common_url + "PicturesServlet")
            var requestParam = [String: Any]()
            requestParam["action"] = "findUserHeadImage"
            requestParam["userId"] = friend
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
            nickNameRequestParam["id"] = friend
            executeTask(url_server!, nickNameRequestParam) { (data, response, error) in
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
            return cell
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        socket = WebSocket(url: URL(string: url_server + user.account)!)
        addSocketCallBacks()
        socket.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllChatMessage()
    }
    
    @objc func getAllChatMessage(){
        let url_server = URL(string: common_url + "FriendsMessageServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "findAllMessage"
        requestParam["senderId"] = user.account
        requestParam["receiverId"] = friend
        
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([Message].self, from: data!){
                        self.friendMessages = result
                        DispatchQueue.main.async {
                        self.chatTableView.reloadData()
                            if self.friendMessages.count != 0{
                                let index = IndexPath(row: self.friendMessages.count - 1, section: 0)
                                self.chatTableView.scrollToRow(at: index, at: .bottom, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func bt_Send(_ sender: Any) {
        let message = tf_ChatMessage.text
        // 訊息不可為nil或""
        if message == nil || message!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        let sender = loadData()
        let chatMessage = Message("chat", sender.account, friend!, message!,"text")
        
        if let jsonData = try? JSONEncoder().encode(chatMessage) {
            let text = String(data: jsonData, encoding: .utf8)
            self.socket.write(string: text!)
            // debug用
            // print("\(tag) send messages: \(text!)")
            // 將輸入的訊息清空
            self.friendMessages.insert(chatMessage, at: self.friendMessages.count)
            self.chatTableView.reloadData()
            self.chatTableView.scrollToRow(at: IndexPath(row: self.friendMessages.count - 1, section: 0), at: .bottom, animated: true)
            tf_ChatMessage.text = nil
        }
        
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "FriendsMessageServlet")
        requestParam["action"] = "insert"
        requestParam["share"] = try! String(data: JSONEncoder().encode(chatMessage), encoding: .utf8)
        executeTask(url_server!, requestParam) {(data, response, error) in
            if error == nil {
                if data != nil {
                //print("input: \(String(data: data!, encoding: .utf8)!)")
                }
            }
        }
          // 隱藏鍵盤
          // tfMessage.resignFirstResponder()
    }
    
    func addSocketCallBacks() {
        socket.onText = { (text: String) in
            if let chatMessage = try? JSONDecoder().decode(Message.self, from: text.data(using: .utf8)!) {
                let sender = chatMessage.sender
                // 接收到聊天訊息，若發送者與目前聊天對象相同，就將訊息顯示在TextView
                if sender == self.friend {
                    self.friendMessages.insert(chatMessage, at: self.friendMessages.count)
                    self.chatTableView.reloadData()
                }
            }
        }
    }
}
