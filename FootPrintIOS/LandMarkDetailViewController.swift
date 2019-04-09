//
//  LandMarkDetailViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class LandMarkDetailViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource,UINavigationControllerDelegate {

    @IBOutlet weak var landMarkImageCollectionLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var landMarkImageCollectionView: UICollectionView!
    
    @IBOutlet weak var nameUILabel: UILabel!
    @IBOutlet weak var addressUILabel: UILabel!
    @IBOutlet weak var descriptionUILabel: UILabel!
    @IBOutlet weak var typeUILable: UILabel!
    @IBOutlet weak var openTimeUILable: UILabel!
    @IBOutlet weak var starUILable: UILabel!
    @IBOutlet weak var imageFirstUIImageView: UIImageView!
    
    let fullScreenSize = UIScreen.main.bounds.size
    var pictures = [CameraImage]()
    var location : LandMark?
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collection layout setting
        collectionViewSetting()
        
        //run
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        landMarkImageCollectionView.backgroundView = activityIndicatorView
        
        //title
        self.title = location?.name
        
        //locationInfo
        locationInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let landMarkID = location?.id
        getImagesId(landMarkID!)
        
        //run
        if pictures.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //collection layout setting
    func collectionViewSetting() {
        //設置上下左右的間距
        landMarkImageCollectionLayout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        //設置Cell的size，在func viewDidLoad()外面宣告 let fullScreenSize = UIScreen.main.bounds.size，來得到手機螢幕的大小
        landMarkImageCollectionLayout.itemSize = CGSize(width: fullScreenSize.width/3 - 4, height: 100)
        //設置cell與cell的間距
        landMarkImageCollectionLayout.minimumLineSpacing = 5
        //vertical為上下捲動，horizontal為左右捲動
        landMarkImageCollectionLayout.scrollDirection = .vertical
        //設置header的尺寸
        landMarkImageCollectionLayout.headerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
    }
    
    //找出地標裡所有照片id
    func getImagesId(_ landMarkId : Int) {
        let url_server = URL(string: common_url + "/LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "findImageId"
        requestParam["id"] = landMarkId
        executeTask(url_server!, requestParam) {(data, response, error) in
            if error == nil {
                if data != nil {
                    //print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([CameraImage].self, from: data!){
                        self.pictures = result
                        DispatchQueue.main.async {
                            self.activityIndicatorView.stopAnimating()
                            self.landMarkImageCollectionView.reloadData()
                        }
                    }
                }
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    //collection view detail
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("Int\(pictures.count)")
        return pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"LandMarkImageCollectionCell", for: indexPath) as! LandMarkImagesCollectionViewCell

        let picture = pictures[indexPath.row]
        let url_server = URL(string: common_url + "PicturesServlet")
        
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = picture.imageID
//        requestParam["imageSize"] = cell.frame.width
        requestParam["imageSize"] = 1024
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
//                    print(data!)
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "noImage.jpg")
                }
                DispatchQueue.main.async {
                    cell.landMarkImageCollection.image = image
                }
                DispatchQueue.main.async {
                    if indexPath.row == 0 {
                        self.imageFirstUIImageView.image = image
                    }
                }
            }else{
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "LandMarkImagesTableViewController") as! LandMarkImagesTableViewController
        detailVC.currentIndex = indexPath.row
//        detailVC.locationinfo = pictures
        detailVC.locationId = location?.id
        /* storyboard加上UINavigationController */
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func locationInfo() {
        nameUILabel.text = location?.name
        addressUILabel.text = location?.address
        descriptionUILabel.text = location?.description
        openTimeUILable.text = location?.openingHours
        starUILable.text = String(format:"%.1f", location!.star!)
        typeUILable.text = location?.type
    }
    
}
