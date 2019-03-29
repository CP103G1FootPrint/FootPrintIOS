//
//  NewsTableViewCell.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/14.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit


struct Feed {
    var likeCount = 0
}

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var bt_HeadPicture: UIButton!
    @IBOutlet weak var bt_NickName: UIButton!
    @IBOutlet weak var bt_LandMark: UIButton!
    @IBOutlet weak var iv_NewsPicture: UIImageView!
    @IBOutlet weak var bt_Like: UIButton!
    @IBOutlet weak var bt_Message: UIButton!
    @IBOutlet weak var bt_Collection: UIButton!
    @IBOutlet weak var lb_LikesCount: UILabel!
    @IBOutlet weak var lb_description: UILabel!
    var news: News!
    var like: Likes!
    lazy var likeCount = Int(news.likesCount)
    
    
    
    @IBAction func bt_Like(_ sender: Any) {
        if self.bt_Like.isSelected{
            //取消按讚
            self.bt_Like.isSelected = false
                likeCount! -= 1
                lb_LikesCount.text = String(likeCount!) + " people likes"
                bt_Like.setImage(UIImage(named: "like-1"), for: .normal)
            
            let url_server = URL(string: common_url + "/LikesServlet")
            var requestParam = [String: String]()
            requestParam["action"] = "delete"
            requestParam["delete"] = try! String(data: JSONEncoder().encode(like), encoding: .utf8)
            executeTask(url_server!, requestParam) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        print("input: \(String(data: data!, encoding: .utf8)!)")
                    }
                }
            }
        }else{
            //按讚
            self.bt_Like.isSelected = true
                likeCount! += 1
                lb_LikesCount.text = String(likeCount!) + " people likes"
                bt_Like.setImage(UIImage(named: "like-2"), for: .normal)
            
            let url_server = URL(string: common_url + "/LikesServlet")
            var requestParam = [String: String]()
            requestParam["action"] = "insert"
            requestParam["share"] = try! String(data: JSONEncoder().encode(like), encoding: .utf8)
            executeTask(url_server!, requestParam) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        print("input: \(String(data: data!, encoding: .utf8)!)")
                    }
                }
            }
        }
        //更新按讚人數
        let new = News(String(likeCount!),news.imageID!)
        let url_server = URL(string: common_url + "/PicturesServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "update"
        requestParam["update"] = try! String(data: JSONEncoder().encode(new), encoding: .utf8)
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                }
            }
        }
    }

    
    @IBAction func bt_Collection(_ sender: Any) {
        if self.bt_Collection.isSelected{
            //取消收藏
            self.bt_Collection.isSelected = false
            bt_Collection.setImage(UIImage(named: "collection2"), for: .normal)
            
            let url_server = URL(string: common_url + "/CollectionServlet")
            var requestParam = [String: String]()
            requestParam["action"] = "delete"
            requestParam["delete"] = try! String(data: JSONEncoder().encode(like), encoding: .utf8)
            executeTask(url_server!, requestParam) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        print("input: \(String(data: data!, encoding: .utf8)!)")
                    }
                }
            }
        }else{
            //收藏
            self.bt_Collection.isSelected = true
            bt_Collection.setImage(UIImage(named: "collection"), for: .normal)
            
            let url_server = URL(string: common_url + "/CollectionServlet")
            var requestParam = [String: String]()
            requestParam["action"] = "insert"
            requestParam["share"] = try! String(data: JSONEncoder().encode(like), encoding: .utf8)
            executeTask(url_server!, requestParam) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        print("input: \(String(data: data!, encoding: .utf8)!)")
                    }
                }
            }
        }
    }
}
