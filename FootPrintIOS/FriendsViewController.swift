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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
            getAllFriends()
    }
    
    @objc func getAllFriends(){
        let url_server = URL(string: common_url + "FriendsServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "getAllFriends"
        requestParam["userId"] =  user.account
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil{
                if data != nil{
//                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([Friends].self, from: data!){
                        print(result)
                        self.friends = result
                    }
                    DispatchQueue.main.async {
                        self.lb_FriendsCounter.text = "好友數量:\(self.friends.count)人"
                    }
                }
            }else{
                print(error!.localizedDescription)
            }
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}