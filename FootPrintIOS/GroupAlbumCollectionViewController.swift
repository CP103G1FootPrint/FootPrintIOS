//
//  GroupAlbumCollectionViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit




//var dataArray:[UIImage] = [UIImage]()


class GroupAlbumCollectionViewController: UICollectionViewController,
    UIImagePickerControllerDelegate,UINavigationBarDelegate{
    
    @IBOutlet var showActivityIndicator: UIActivityIndicatorView!
    var groupAlbums = [GroupAlbum]()
    var pickedImage = UIImage()
    let url_server = URL(string: common_url + "/GroupAlbumServlet")
    var imagePicker = UIImagePickerController()
    var trips: Trip!
    let fullScreanSize = UIScreen.main.bounds.size

    @IBOutlet var albumCollectionView: UICollectionView!
    @IBOutlet weak var albumCollectionLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        //與邊界距離
        albumCollectionLayout.sectionInset = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        //圖片大小
        albumCollectionLayout.itemSize = CGSize(width: fullScreanSize.width/3 - 10, height: 320)
//        fullScreanSize.width/3
        //上下行兼距
        albumCollectionLayout.minimumLineSpacing = 5
        //圖片左右距離
        albumCollectionLayout.minimumInteritemSpacing = 5
        albumCollectionLayout.scrollDirection = .vertical
        
    }
    override func viewWillAppear(_ animated: Bool) {
        showAllphotos()
    }
    
    @objc func showAllphotos(){
        var requestParam = [String: Any]()
        requestParam["action"] = "findAblumId"
        requestParam["tripID"] = trips.tripID
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    //沒有包含圖片的旅遊景點
                    if let result = try? JSONDecoder().decode([GroupAlbum].self, from: data!) {
                        self.groupAlbums = result
                        DispatchQueue.main.async {
                            //取得更新後讓下來更新動畫結束
                            if let control = self.collectionView.refreshControl {
                                if control.isRefreshing {
                                    // 停止下拉更新動作
                                    control.endRefreshing()
                                }
                            }
                            /* 抓到資料後重刷table view */
                            self.collectionView.reloadData()
                        }
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    
    //有幾個section
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    //每個section有幾筆資料
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return groupAlbums.count
    }

    //每筆資料內容為何？
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //記得加 as! GroupAlbumCollectionViewCell
        let cellId = "albumCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupAlbumCollectionViewCell
        let groupAlbum = groupAlbums[indexPath.row]
      
        // 尚未取得圖片，另外開啟task請求
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = groupAlbum.albumID
        // 圖片寬度為tableViewCell的1/4，ImageView的寬度也建議在storyboard加上比例設定的constraint
        requestParam["imageSize"] = cell.frame.width / 4
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "noImage.jpg")
                }
                DispatchQueue.main.async { cell.imageViewCell.image = image }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    
    //新增照片 Info.plist加上Privacy
    @IBAction func clickAddPhoto(_ sender: UIBarButtonItem) {
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        /* 照片來源為相簿 */
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 選擇照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            pickedImage = info[.originalImage] as! UIImage
            let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
                showActivityIndicator.addSubview(activityIndicatorView)
        
//                var requestParam = [String: String]()
//                requestParam["action"] = "groupalbumInsert"
//                requestParam["tripId"] = trips.tripID
//        //主轉成jason 字串 只有文字沒有圖
//        // 有圖才上傳 圖轉乘的imageBase64 字串
//        if self.image != nil {
//            requestParam["imageBase64"] = self.image!.jpegData(compressionQuality: 0.0)!.base64EncodedString() //compressionQuality: 1.0 紙質最好的圖
//        }
//        executeTask(self.url_server!, requestParam) { (data, response, error) in
//            if error == nil {
//                if data != nil {
//                    if let result = String(data: data!, encoding: .utf8) {
//                        if let count = Int(result) {
//                            DispatchQueue.main.async {
//                                // 新增成功則回前頁
//                                if count != 0 {                                            self.navigationController?.popViewController(animated: true)
//                                } else {
//                                    let alertController = UIAlertController(title: "insert fail",
//                                                                            message: nil, preferredStyle: .alert)
//                                    self.present(alertController, animated: true, completion: nil)
//                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
//                                        self.presentedViewController?.dismiss(animated: false, completion: nil)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            } else {
//                print(error!.localizedDescription)
//            }
//        }
        
//             groupAlbums.append(pickedImage)
            collectionView.reloadData()
        


       
        dismiss(animated: true, completion: nil)
    }
    
    /* 挑選照片過程中如果按了Cancel，關閉挑選畫面 */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}


