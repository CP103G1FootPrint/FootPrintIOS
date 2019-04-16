//
//  SearchFriendViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/4/15.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class SearchFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableview_FindUser: UITableView!
    @IBOutlet weak var search_FindUserID: UISearchBar!
    
    var userId = [String]()
    var currentuserid = [String]()
    var cu : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview_FindUser.tableFooterView = UIView()
        setUpSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        findAllUserId()
//        if userId.count == 0 {
//            activityIndicatorView.startAnimating()
//        }
    }
    
    func findAllUserId(){
        let url_server = URL(string: common_url + "AccountServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "findAllUserId"
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil{
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([String].self, from: data!) {
                        self.userId = result
                        self.currentuserid = self.userId
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count \(cu)")
        return cu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "findfriendcell", for: indexPath) as! SearchFriendTableViewCell
        let friend = cu[indexPath.row]
        
        
        
        //抓使用者暱稱
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
                        cell.lb_UserNickName.text = result
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
        requestParam2["userId"] = friend
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
                    cell.iv_headpicture.image = headImage2
                    cell.iv_headpicture.layer.cornerRadius = cell.iv_headpicture.frame.width/2
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        cell.lb_userId.text = friend
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "HomeStoryboard", bundle: nil)
        let friend = storyboard.instantiateViewController(withIdentifier: "HomeNewsPersonalViewController") as! HomeNewsPersonalViewController
        let cameraid = cu[indexPath.row]
        friend.personalId = cameraid
        navigationController?.pushViewController(friend, animated: true)
    }
    
    func setUpSearchBar() {
        search_FindUserID.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        cu = userId
        cu = userId.filter({ userid -> Bool in
            if searchText.isEmpty {
                cu.removeAll()
                print("cu : \(cu)")
                self.tableview_FindUser.reloadData()
                return true
            }
            let result = userid.lowercased().contains(searchText.lowercased())
            self.tableview_FindUser.reloadData()
            return result
        })
        if searchText.isEmpty{
            cu.removeAll()
        }
        self.tableview_FindUser.reloadData()
    }
}
