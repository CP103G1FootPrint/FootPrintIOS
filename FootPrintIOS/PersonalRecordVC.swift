import UIKit

class PersonalRecordVC: UICollectionViewController {
    
//    let userDefault = UserDefaults.standard
    let url_server = URL(string: common_url + "RecordServlet")
    var recordImageId = [Record]()
     let user = loadData()

    let fullScreenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.collectionView.tableFooterView =  UIView()
        collectionViewRefreshControl()
        
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        //距離螢幕邊框
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //CELL大小
        layout.itemSize = CGSize(width: (fullScreenSize.width)/3, height:(fullScreenSize.width)/3 )
        //上下CELL間距
        layout.minimumLineSpacing = 0
        //左右CELL間距
        layout.minimumInteritemSpacing = 0
        //捲動方向
        layout.scrollDirection = .vertical
        //header 距離螢幕上方。 footer 距離螢幕下方
        //        layout.headerReferenceSize = CGSize( width: fullScreenSize.width, height: 40)
    }
    
        /** tableView加上下拉更新功能 */
        
        func collectionViewRefreshControl(){
            let refreshControl = UIRefreshControl()
            refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refreshControl.addTarget(self, action: #selector(getImage), for: .valueChanged)
            self.collectionView.refreshControl = refreshControl
        }
    
    override func viewWillAppear(_ animated: Bool) {
            getImage()
    }
    
    @objc func getImage(){
        var requestParam = [String: String]()
        requestParam["action"] = "findImageId"
        requestParam["id"] = user.account
        imageIdTask(url_server!,requestParam)
    }
    
    func imageIdTask(_ url_server: URL, _ requestParam: [String: String]) {
        // 將輸出資料列印出來除錯用
        print("output: \(requestParam)")
        let jsonData = try! JSONEncoder().encode(requestParam)
        var request = URLRequest(url: url_server)
        request.httpMethod = "POST"
        // 不使用cache
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        // 請求參數為JSON data，無需再轉成JSON字串
        request.httpBody = jsonData
        let session = URLSession.shared
        // 建立連線並發出請求，取得結果後會呼叫closure執行後續處理
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                if data != nil {
                    if let result = try? JSONDecoder().decode([Record].self, from: data!) {
                        self.recordImageId = result
                        DispatchQueue.main.async {
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
        task.resume()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return recordImageId.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordCell", for: indexPath) as! PersonalRecordCVCell
        let imageId = recordImageId[indexPath.row]
        
        var requestParam = [String: Any]()
        requestParam["action"] = "getInfoImage"
        requestParam["id"] = imageId.imageID
        // 圖片寬度為tableViewCell的1/4，ImageView的寬度也建議在storyboard加上比例設定的constraint
        requestParam["imageSize"] = cell.frame.width / 4
        var image: UIImage?
        
        executeTask(url_server!,requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "noImage.jpg")
                }
                DispatchQueue.main.async { cell.RecordCellImage.image = image }
            } else {
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    
}

