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
//        let chatMessage = Friends(type:"chat", inviter:sender.account, invitee: friend!, message: message!, messageType: "text")
        let chatMessage = Friends("chat", sender.account, friend!, message!, "text")
//        let chatMessage = Friends("chat", sender.account, friend!, message!, "text")
        if let jsonData = try? JSONEncoder().encode(chatMessage) {
           let text = String(data: jsonData, encoding: .utf8)
           self.socket.write(string: text!)
           tf_Message.text = nil
       }
    }
}
