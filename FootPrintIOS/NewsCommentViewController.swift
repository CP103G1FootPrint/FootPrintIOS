//
//  NewsCommentViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/27.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class NewsCommentViewController: UIViewController,UITableViewDataSource{
    @IBOutlet weak var lb_userNickName: UIButton!
    @IBOutlet weak var lb_description: UILabel!
    @IBOutlet weak var bt_HeadImage: UIButton!
    @IBOutlet weak var tv_TableView: UITableView!
    @IBOutlet weak var tf_Comment: UITextField!
    
    var comments = [Comment]()
    var news: News!
    var headImage: UIImage?
    let user = loadData()
    
    @IBOutlet weak var nvitem_comment: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        lb_description.text = news.description
        lb_userNickName.setTitle(news.nickName, for: .normal)
        bt_HeadImage.setImage(headImage, for: .normal)
        bt_HeadImage.imageView?.layer.cornerRadius = bt_HeadImage.frame.width/2
        self.tv_TableView.tableFooterView = UIView()

//        showAllNews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showAllNews()
    }
    
    @objc func showAllNews() {
        let url_server = URL(string: common_url + "CommentServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "findAllMessage"
        requestParam["imageId"] = news.imageID
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([Comment].self, from: data!){
                        self.comments = result
                        DispatchQueue.main.async {
                            /* 抓到資料後重刷table view */
                            self.tv_TableView.reloadData()
                            /* 捲動到最下面 */
                            if self.comments.count != 0{
                                let index = IndexPath(row: self.comments.count - 1, section: 0)
                                self.tv_TableView.scrollToRow(at: index, at: .bottom, animated: true)
                            }
                            
                        }
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    //發送留言
    @IBAction func bt_SendComment(_ sender: Any) {
        let commentMessage = tf_Comment.text
        if commentMessage == nil || commentMessage!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        let comment = Comment(0,user.account,commentMessage!,news.imageID!)
        comments.insert(comment, at: comments.count)
        self.tv_TableView.reloadData()
        
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "CommentServlet")
        requestParam["action"] = "insert"
        requestParam["share"] = try! String(data: JSONEncoder().encode(comment), encoding: .utf8)
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    DispatchQueue.main.async {
                         self.tv_TableView.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        tf_Comment.text = nil
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentcell") as! NewsCommentTableViewCell
        let comment = comments[indexPath.row]
        cell.lb_Comment.text = comment.message
        
        //抓使用者暱稱
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "PicturesServlet")
        requestParam["action"] = "findUserNickName"
        requestParam["id"] = comment.userId
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                        let result = String(data: data!, encoding: .utf8)!
                        DispatchQueue.main.async {
                            cell.bt_userNickName.setTitle(result, for: .normal)
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
        requestParam2["userId"] = comment.userId
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
                    cell.iv_HeadPicture.setImage(headImage2, for: .normal)
                    cell.iv_HeadPicture.imageView?.layer.cornerRadius = cell.iv_HeadPicture.frame.width/2
                }
                //設定button為圓形
            } else {
                print(error!.localizedDescription)
            }
        }
        return cell
    }
}
