//
//  GroupMessageViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/4/2.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class GroupMessageViewController: UIViewController,UITableViewDataSource {

    var trips: Trip!
    var chatmessages = [ChatMessage]()
    var headImage: UIImage?
    let user = loadData()
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tv_tableView: UITableView!
   
    @IBOutlet weak var userImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tv_tableView.tableFooterView = UIView()
        let user = loadHead()
        userImageView.image = UIImage(data : user)
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        showAllMessages()
    }
    
    func showAllMessages(){
        let url_server = URL(string: common_url + "ChatMessageServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "findAllMessage"
        requestParam["tripId"] = trips.tripID
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([ChatMessage].self, from: data!){
                        self.chatmessages = result
                        DispatchQueue.main.async {
                            /* 抓到資料後重刷table view */
                            self.tv_tableView.reloadData()
                            /* 捲動到最下面 */
                            if self.chatmessages.count != 0{
                                let index = IndexPath(row: self.chatmessages.count - 1, section: 0)
                                self.tv_tableView.scrollToRow(at: index, at: .bottom, animated: true)
                            }
                            
                        }
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    @IBAction func sendButton(_ sender: Any) {
        let message = messageTextField.text
        if message == nil || message!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
            
        }
            let chatmessage = ChatMessage(0,user.account,message!,trips.tripID!)
            chatmessages.insert(chatmessage, at: chatmessages.count)
            self.tv_tableView.reloadData()
            
            var requestParam = [String: String]()
            let url_server = URL(string: common_url + "ChatMessageServlet")
            requestParam["action"] = "insert"
            requestParam["share"] = try! String(data: JSONEncoder().encode(chatmessage), encoding: .utf8)
            executeTask(url_server!, requestParam) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        // 將輸入資料列印出來除錯用
                        print("input: \(String(data: data!, encoding: .utf8)!)")
                        DispatchQueue.main.async {
                            self.tv_tableView.scrollToRow(at: IndexPath(row: self.chatmessages.count - 1, section: 0), at: .bottom, animated: true)
                        }
                    }
                } else {
                    print(error!.localizedDescription)
                }
            }
            messageTextField.text = nil
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatmessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupmessagecell") as! GroupMessageTableViewCell
        let chatmessage = chatmessages[indexPath.row]
        cell.messageLabel.text = chatmessage.message
        
        //抓使用者暱稱
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "PicturesServlet")
        requestParam["action"] = "findUserNickName"
        requestParam["id"] = chatmessage.userId
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    let result = String(data: data!, encoding: .utf8)!
                    DispatchQueue.main.async {
                        cell.nameButton.setTitle(result, for: .normal)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        //抓留言者頭像
        let url_server2 = URL(string: common_url + "PicturesServlet")
        var requestParam2 = [String: Any]()
        requestParam2["action"] = "findUserHeadImage"
        requestParam2["userId"] = chatmessage.userId
        requestParam2["imageSize"] = cell.frame.width / 10
        var headImage2: UIImage?
        executeTask(url_server2!, requestParam2) { (data, response, error) in
            if error == nil {
                if data != nil {
                    headImage2 = UIImage(data: data!)
                }
                if headImage2 == nil {
                    headImage2 = UIImage(named: "album")
                }
                DispatchQueue.main.async {
                    cell.imageButton.setImage(headImage2, for: .normal)
                    cell.imageButton.imageView?.layer.cornerRadius = cell.imageButton.frame.width/2
                }
                //設定button為圓形
            } else {
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
