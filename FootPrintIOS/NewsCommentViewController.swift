//
//  NewsCommentViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/27.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class NewsCommentViewController: UIViewController{
    @IBOutlet weak var lb_userNickName: UIButton!
    @IBOutlet weak var lb_description: UILabel!
    @IBOutlet weak var bt_HeadImage: UIButton!

    var news: News!
    var headImage: UIImage?
    @IBOutlet weak var nvitem_comment: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        lb_description.text = news.description
        lb_userNickName.setTitle(news.nickName, for: .normal)
        bt_HeadImage.setImage(headImage, for: .normal)
        bt_HeadImage.imageView?.layer.cornerRadius = bt_HeadImage.frame.width/2

//        print("123home\(news.headImageString)")
        // Do any additional setup after loading the view.
//        _=self.navigationController?.popViewController(animated: true)
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
