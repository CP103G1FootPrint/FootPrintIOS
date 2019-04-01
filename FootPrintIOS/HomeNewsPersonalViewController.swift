//
//  HomeNewsPersonalViewController.swift
//  FootPrintIOS
//
//  Created by Cockroach on 2019/3/31.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class HomeNewsPersonalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var iv_HeadPicture: UIImageView!
    @IBOutlet weak var lb_Userid: UILabel!
    @IBOutlet weak var lb_UserNickName: UILabel!
    @IBOutlet weak var lb_Birthday: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    var news: News!
    var headimage: UIImage!
    var pictures = [PersonalPicture]()
    let fullScreenSize = UIScreen.main.bounds.size
    @IBOutlet weak var collectionlayout: UICollectionViewFlowLayout!
    @IBOutlet weak var navationitem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iv_HeadPicture.image = self.headimage
        //設定圖片圓形
        iv_HeadPicture.layer.cornerRadius = iv_HeadPicture.frame.width/2
        lb_Userid.text = news.userID
        lb_UserNickName.text = news.nickName
        navationitem.title = news.nickName
//      lb_Birthday.text =
//      getAllPicturesId()
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
         getAllPicturesId()

    }
    
    @objc func getAllPicturesId() {
        let url_server = URL(string: common_url + "PicturesServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "findPersonalImageId"
        requestParam["userId"] = news.userID
        executeTask(url_server!, requestParam) {(data, response, error) in
            if error == nil {
                if data != nil {
//                  print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([PersonalPicture].self, from: data!){
                        self.pictures = result
                    }
                }
            }else{
                 print(error!.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Int\(pictures.count)")
        return pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"personalPictureCell", for: indexPath) as! PersonalPictureCollectionViewCell
//        getAllPicturesId()
        let picture = pictures[indexPath.row]
        let url_server = URL(string: common_url + "PicturesServlet")
        
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = picture.imageID
        requestParam["imageSize"] = cell.frame.width
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    print(data!)
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "noImage.jpg")
                }
                DispatchQueue.main.async {
                    cell.iv_Pictures.image = image
                }
            }else{
                print(error!.localizedDescription)
            }
        }
        return cell
    }
}