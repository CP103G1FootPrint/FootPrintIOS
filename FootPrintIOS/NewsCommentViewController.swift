//
//  NewsCommentViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/27.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class NewsCommentViewController: UIViewController {
    @IBOutlet weak var lb_userNickName: UIButton!
    @IBOutlet weak var lb_description: UILabel!
    var news: News!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lb_description.text = news.description
        // Do any additional setup after loading the view.
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
