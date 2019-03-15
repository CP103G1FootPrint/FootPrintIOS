//
//  GroupAlbumCollectionViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

var imagePicker = UIImagePickerController()
var dataArray:[UIImage] = [UIImage]()
private let reuseIdentifier = "Cell"

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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
        return dataArray.count
    }

    //每筆資料內容為何？
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //記得加 as! GroupAlbumCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GroupAlbumCollectionViewCell
        cell.imageViewCell.image =  dataArray [indexPath.item]
        
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
        let pickedImage = info[.originalImage] as! UIImage
        //添加圖片
        dataArray.append(pickedImage)
        dismiss(animated: true, completion: nil)
    }
    
    /* 挑選照片過程中如果按了Cancel，關閉挑選畫面 */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
