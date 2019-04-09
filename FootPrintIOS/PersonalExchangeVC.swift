import UIKit

class PersonalExchangeVC: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    
    let url_server = URL(string: common_url + "ExchangeServlet")
    var goods = [ExchangeGoods]()
    
    @IBOutlet weak var exchangeTBV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getAll()
        exchangeTBV.delegate = self
        exchangeTBV.dataSource = self
    }
    
    /*打包*/
    func getAll(){
        var requsetParam = [String:String]() //[String:String]()是dicitionary是方法要加()
        requsetParam["action"] = "getAll"
        goodTask(url_server!,requsetParam)
    }
    /*傳送*/
    func goodTask(_ url_server: URL, _ requestParam: [String: String]) {
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
                    // 解析資料
                    if let result = try? JSONDecoder().decode([ExchangeGoods].self, from: data!){
                        self.goods = result
                        // 將結果顯示在UI元件上必須轉給main thread
                        DispatchQueue.main.async {
                            self.exchangeTBV.reloadData()
                        }
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //把ExchangeTVCell格式帶入exchangeCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "exchangeCell", for: indexPath) as! ExchangeTVCell
        let good = goods[indexPath.row]
        
        var requestParam = [String: Any]()
        requestParam["action"] = "getInfoImage"
        requestParam["id"] = good.id
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
                DispatchQueue.main.async { cell.productPic.image = image }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        
        cell.productName.text = good.productId
        cell.productScr.text = good.description
        cell.integral.text = "💰\(good.point)"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QRcode" {
            let controller = segue.destination as? PersonalQRcode
            let indexPath = self.exchangeTBV.indexPathForSelectedRow
            controller?.productName = goods[indexPath!.row].productId
        }
    }
}
