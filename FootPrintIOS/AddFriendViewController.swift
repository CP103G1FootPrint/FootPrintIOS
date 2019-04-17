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
        addKeyboardObserver()
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
        let addfriendMessage = Friends("notify", sender.account, friend!, message!, "text")
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
//        if let controller = storyboard?.instantiateViewController(withIdentifier: "HomeNewsPersonalViewController") as? HomeNewsPersonalViewController{
//            navigationController?.pushViewController(controller, animated: true)
//        }
        let friendcontroller = storyboard?.instantiateViewController(withIdentifier: "HomeNewsPersonalViewController") as! HomeNewsPersonalViewController
        friendcontroller.personalId = friend
        self.navigationController?.popViewController(animated: true)
        
        // 隱藏鍵盤
        tf_Message.resignFirstResponder()

    }
        override func viewWillDisappear(_ animated: Bool) {
            if socket.isConnected{
                socket.disconnect()
            }
        }
    
    @IBAction func tap(_ sender: Any) {
        hideKeyboard()
    }
}
extension AddFriendViewController{
    func hideKeyboard() {
        tf_Message.resignFirstResponder()
    }
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        // 能取得鍵盤高度就讓view上移鍵盤高度，否則上移view的1/3高度
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height / 3
            view.frame.origin.y = -keyboardHeight
        } else {
            view.frame.origin.y = -view.frame.height / 3
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
