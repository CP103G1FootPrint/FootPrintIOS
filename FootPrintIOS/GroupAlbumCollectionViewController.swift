//
//  GroupAlbumCollectionViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
var groupAlbums = [GroupAlbum]()
let url_server = URL(string: common_url + "/GroupAlbumServlet")

var imagePicker = UIImagePickerController()
//var dataArray:[UIImage] = [UIImage]()


class GroupAlbumCollectionViewController: UICollectionViewController,
    UIImagePickerControllerDelegate,UINavigationBarDelegate{
    
    let fullScreanSize = UIScreen.main.bounds.size

    @IBOutlet var albumCollectionView: UICollectionView!
    @IBOutlet weak var albumCollectionLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        albumCollectionLayout.sectionInset = UIEdgeInsets(top: 5,left: 20,bottom: 5,right: 20)
        albumCollectionLayout.itemSize = CGSize(width: fullScreanSize.width/2-50, height: 200)
        albumCollectionLayout.minimumLineSpacing = 5
        albumCollectionLayout.scrollDirection = .vertical
        
    }
    override func viewWillAppear(_ animated: Bool) {
        showAllphotos()
    }
    
    @objc func showAllphotos(){
        var requestParam = [String: Any]()
        requestParam["action"] = "findAblumId"
        requestParam["tripID"] = "1"
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    //沒有包含圖片的旅遊景點
                    if let result = try? JSONDecoder().decode([GroupAlbum].self, from: data!) {
                        groupAlbums = result
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
        print("count",groupAlbums.count)
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
//        let pickedImage = info[.originalImage] as! UIImage
//        //添加圖片
//        groupAlbums.append(pickedImage)
        dismiss(animated: true, completion: nil)
    }
    
    /* 挑選照片過程中如果按了Cancel，關閉挑選畫面 */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
