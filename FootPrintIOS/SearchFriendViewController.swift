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
//                        DispatchQueue.main.async {
//                            self.tableview_FindUser.reloadData()
//                        }
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
        cell.lb_userId.text = friend
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        cameraLandMark = currentLocations[indexPath.row]
//        let cameraid = cu[indexPath.row]
        let storyboard = UIStoryboard(name: "HomeStoryboard", bundle: nil)
        let friend = storyboard.instantiateViewController(withIdentifier: "HomeNewsPersonalViewController") as! HomeNewsPersonalViewController
        let cameraid = cu[indexPath.row]
        friend.personalId = cameraid
        self.present(friend, animated: true, completion: nil)
//        if let controller = storyboard?.instantiateViewController(withIdentifier: "HomeNewsPersonalViewController") as? HomeNewsPersonalViewController{
//            let cameraid = cu[indexPath.row]
//            controller.news.userID = cameraid
//            navigationController?.pushViewController(controller, animated: true)
//        }
        
        
        
//        //發送通知
//        let notificationName = Notification.Name("Planlocation")
//        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["Planlocation": cameraid as Any])
//        dismiss(animated: true, completion: nil)
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
//            self.tableview_FindUser.reloadData()

        }
        self.tableview_FindUser.reloadData()
    }
}
