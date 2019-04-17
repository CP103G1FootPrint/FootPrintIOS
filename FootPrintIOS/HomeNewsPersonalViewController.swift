//
//  HomeNewsPersonalViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/31.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class HomeNewsPersonalViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var iv_HeadPicture: UIImageView!
    @IBOutlet weak var lb_Userid: UILabel!
    @IBOutlet weak var lb_UserNickName: UILabel!
    @IBOutlet weak var lb_Birthday: UILabel!
    @IBOutlet weak var collection: UICollectionView!
//    @IBOutlet weak var bt_AddFriend: UIBarButtonItem!
    var news: News!
    var headimage: UIImage!
    var pictures = [PersonalPicture]()
    var user = loadInfo()
    var image: UIImage?
    var friendship = [Friends]()
    var personalId: String?

    
    let fullScreenSize = UIScreen.main.bounds.size
    @IBOutlet weak var collectionlayout: UICollectionViewFlowLayout!
    @IBOutlet weak var navationitem: UINavigationItem!
    @IBOutlet weak var tableview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if news != nil  {
            iv_HeadPicture.image = self.headimage
//            //設定邊框顏色
//            let myColor : UIColor = UIColor.green
//            iv_HeadPicture.layer.borderColor = myColor.cgColor
//            //設定圖片邊框粗細
//            iv_HeadPicture.layer.borderWidth = 5.0
            //設定圖片圓形
            iv_HeadPicture.layer.cornerRadius = iv_HeadPicture.frame.width/2
            lb_Userid.text = news.userID
            lb_UserNickName.text = news.nickName
            navationitem.title = news.nickName
            lb_Birthday.text = user.birthday
            personalId = news.userID
        }else{
            let url_server = URL(string: common_url + "AccountServlet")
            var requestParam = [String: String]()
            requestParam["action"] = "personalGetAll"
            requestParam["id"] = personalId
            executeTask(url_server!, requestParam) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        // 將輸入資料列印出來除錯用
//                         print("input: \(String(data: data!, encoding: .utf8)!)")
                        if let result = try? JSONDecoder().decode(Account.self, from: data!) {
                            DispatchQueue.main.async {
                                self.lb_Userid.text = self.personalId
                                self.lb_UserNickName.text = result.nickname
                                self.navationitem.title = result.nickname
                                self.lb_Birthday.text = result.birthday
                            }
                        }
                        let url_server2 = URL(string: common_url + "PicturesServlet")
                        var requestParam2 = [String: Any]()
                        requestParam2["action"] = "findUserHeadImage"
                        requestParam2["userId"] = self.personalId
                        requestParam2["imageSize"] = 1024
                        executeTask(url_server2!, requestParam2) { (data, response, error) in
                            if error == nil {
                                if data != nil {
                                    self.headimage = UIImage(data: data!)
                                }
                                if self.headimage == nil {
                                    self.headimage = UIImage(named: "album")
                                }
                                DispatchQueue.main.async {
//                                    //設定邊框顏色
//                                    let myColor : UIColor = UIColor.green
//                                    self.iv_HeadPicture.layer.borderColor = myColor.cgColor
//                                    //設定圖片邊框粗細
//                                    self.iv_HeadPicture.layer.borderWidth = 5.0
                                    //設定圖片圓形
                                    self.iv_HeadPicture.image = self.headimage
                                    self.iv_HeadPicture.layer.cornerRadius = self.iv_HeadPicture.frame.width/2

                                }
                            }
                        }
                    }
                }
            }
        }
       
        //設置上下左右的間距
        collectionlayout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        //設置cell與cell的間距
        collectionlayout.minimumLineSpacing = 0
        //vertical為上下捲動，horizontal為左右捲動
        collectionlayout.scrollDirection = .vertical
        //設置Cell的size，在func viewDidLoad()外面宣告 let fullScreenSize = UIScreen.main.bounds.size，來得到手機螢幕的大小
        collectionlayout.itemSize = CGSize(width: fullScreenSize.width/3 - 4, height: 100)
        //設置header的尺寸
        collectionlayout.headerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
        
        getAllPicturesId()

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if user.account == personalId{

        }else{
            let url_server = URL(string: common_url + "FriendsServlet")
            var requestparam = [String:String]()
            requestparam["action"] = "findFriendId"
            requestparam["userId"] = user.account
            requestparam["inviteeId"] = personalId

            executeTask(url_server!, requestparam) { (data, response, error) in
                if error == nil{
                    if data != nil{
                        if let result = try? JSONDecoder().decode([Friends].self, from: data!){
                            print("input: \(String(data: data!, encoding: .utf8)!)")
                            // self.friendship = result
                            if result.isEmpty{
                                requestparam["action"] = "findFriendIdCheckFriendShip"
                                requestparam["userId"] = self.user.account
                                requestparam["inviteeId"] = self.personalId
                                executeTask(url_server!, requestparam) { (data, response, error) in
                                    if error == nil{
                                        if data != nil{
                                            if let result = try? JSONDecoder().decode([Friends].self, from: data!){
                                                print("input: \(String(data: data!, encoding: .utf8)!)")
                                                if result.isEmpty{
                                                    DispatchQueue.main.async {
                                                        let addFriendButton = UIButton(type: .custom)
                                                        addFriendButton.setImage(UIImage (named: "addfriend-1"), for: .normal)
                                                        addFriendButton.addTarget(self, action: #selector(self.AddFriend), for: .touchUpInside)
                                                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addFriendButton)
                                                        self.view.layoutIfNeeded()

                                                    }
                                                }else{
                                                    DispatchQueue.main.async {
                                                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage (named: "friendshipcheck"), style: .plain, target: nil, action: nil)
                                                        self.view.layoutIfNeeded()

                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage (named: "checkfriend"), style: .plain, target: nil, action: nil)
                                    self.view.layoutIfNeeded()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @objc func getAllPicturesId() {
        
        let url_server = URL(string: common_url + "PicturesServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "findPersonalImageId"
        requestParam["userId"] = personalId
        executeTask(url_server!, requestParam) {(data, response, error) in
            if error == nil {
                if data != nil {
//                  print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([PersonalPicture].self, from: data!){
                        self.pictures = result
//                        print("pic count", self.pictures.count)
                        self.pictures.forEach({ (pic) in
                            print(pic.imageID)
                        })
                        DispatchQueue.main.async {
                            self.tableview.reloadData()
                        }
                    }
                }
            }else{
                 print(error!.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("Int\(pictures.count)")
        return pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"personalPictureCell", for: indexPath) as! PersonalPictureCollectionViewCell
        let picture = pictures[indexPath.row]
        let url_server = URL(string: common_url + "PicturesServlet")
        
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = picture.imageID
        // requestParam["id"] = 7
//        print("cellForItemAt ", picture.imageID)
        requestParam["imageSize"] = cell.frame.width
        cell.tag = indexPath.item
//        var image: UIImage?
        
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
//                    print(data!)
                    self.image = UIImage(data: data!)
                }
                if self.image == nil {
                    self.image = UIImage(named: "noImage.jpg")
                }
                DispatchQueue.main.async {
                    if cell.tag == indexPath.item {
                        cell.iv_Pictures.image = self.image

                    }
                }
            }else{
                print(error!.localizedDescription)
            }
        }
        return cell
    }

    @objc func AddFriend(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AddFriendViewController") as? AddFriendViewController{
            controller.headimage = headimage
            controller.friend = personalId
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
