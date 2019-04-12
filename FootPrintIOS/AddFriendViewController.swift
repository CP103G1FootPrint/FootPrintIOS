//
//  AddFriendViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import Starscream

class AddFriendViewController: UIViewController {
    var friend: String?
    var headimage: UIImage!
    var socket: WebSocket!
    var user = loadData()
    let url_server = "ws://127.0.0.1:8080/FootPrint/FriendShipServer/"

    @IBOutlet weak var iv_HeadPicture: UIImageView!
    @IBOutlet weak var tf_Message: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("friendname\(friend!)")
        iv_HeadPicture.image = headimage
        iv_HeadPicture.layer.cornerRadius = iv_HeadPicture.frame.width/2
        socket = WebSocket(url: URL(string: url_server + user.account)!)
        socket.connect()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func bt_Send(_ sender: Any) {
        let message = tf_Message.text
        if message == nil || message!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        let sender = loadData()
        let addfriendMessage = Friends("chat", sender.account, friend!, message!, "text")
        let addfriend = Friends(sender.account,friend!,message!)

        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "FriendsServlet")
        requestParam["action"] = "insert"
        requestParam["share"] = try! String(data: JSONEncoder().encode(addfriend), encoding: .utf8)
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                }
            }
        }
        if let jsonData = try? JSONEncoder().encode(addfriendMessage) {
           let text = String(data: jsonData, encoding: .utf8)
           self.socket.write(string: text!)
           tf_Message.text = nil
       }
    }
}
