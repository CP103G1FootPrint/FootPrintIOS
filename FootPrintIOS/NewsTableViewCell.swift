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
    
    
    
    @IBAction func bt_Like(_ sender: Any) {
        if self.bt_Like.isSelected{
            self.bt_Like.isSelected = false
            if let likeCount = Int(news.likesCount) {
                lb_LikesCount.text = String(likeCount) + " people likes"
            }
            bt_Like.setImage(UIImage(named: "like-1"), for: .normal)
            
            //            let url_server = URL(string: common_url + "LikesServlet")
            //            var requestParam = [String: String]()
            //            requestParam["action"] = "insert"
            //            requestParam["share"] =
            //            executeTask(url_server!, requestParam) { (data, response, error) in
            //                if error == nil {
            //                    if data != nil {
            //                        // 將輸入資料列印出來除錯用
            //                        print("input: \(String(data: data!, encoding: .utf8)!)")
            //                    }
            //                } else {
            //                    print(error!.localizedDescription)
            //                }
            //            }
        }else{
            self.bt_Like.isSelected = true
            if var likeCount = Int(news.likesCount) {
                likeCount += 1
                lb_LikesCount.text = String(likeCount) + " people likes"
                //              lb_LikesCount.text = "\( likeCount + 1)"
            }
            bt_Like.setImage(UIImage(named: "like-2"), for: .normal)
        }
    }
    
    
    
    
    @IBAction func bt_Message(_ sender: Any) {
    }
    @IBAction func bt_Collection(_ sender: Any) {
        if self.bt_Collection.isSelected{
            self.bt_Collection.isSelected = false
            bt_Collection.setImage(UIImage(named: "collection2"), for: .normal)
        }else{
            self.bt_Collection.isSelected = true
            bt_Collection.setImage(UIImage(named: "collection"), for: .normal)
        }
    }
    
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        // Initialization code
    //    }
    //
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state
    //    }
    
}
