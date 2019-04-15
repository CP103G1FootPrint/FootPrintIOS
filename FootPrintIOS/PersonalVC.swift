

import UIKit

class PersonalVC: UIViewController {
//    let userDefault = UserDefaults.standard
    let url_server = URL(string:common_url + "AccountServlet")
    let user = loadData()
   let userHead = UIImage(data: loadHead())
    
    var userInfo : User?
    
    @IBOutlet weak var p1: UISegmentedControl!
    @IBOutlet weak var ivSelfie: UIImageView!
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var lbPoint: UILabel!
    @IBOutlet weak var ivMoney: UIImageView!
    @IBOutlet weak var viewRecord: UIView!
    @IBOutlet weak var viewCollect: UIView!
    @IBOutlet weak var viewNotify: UIView!
    @IBOutlet weak var viewExchange: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
     
        //設定邊框顏色
        let myColor : UIColor = UIColor.lightGray
        ivSelfie.layer.borderColor = myColor.cgColor
        //設定圖片邊框粗細
        ivSelfie.layer.borderWidth = 3.0
        //設定圖片圓形
        ivSelfie.layer.cornerRadius = ivSelfie.frame.width/2
        
//        ivSelfie.image(userHead, for: .normal)
//        ivSelfie.image = UIImage()
        ivSelfie.image = userHead
        viewRecord.isHidden = false
        viewCollect.isHidden = true
        viewNotify.isHidden = true
        viewExchange.isHidden = true
        /*打包*/ //把要傳送的值打包
        var requsetParam = [String:String]() //[String:String]()是dicitionary是方法要加()
        requsetParam["action"] = "personalGetAll"
        requsetParam["id"] = user.account
        executeTask(url_server!,requsetParam)
    }
    
    @IBAction func segma(_ sender: UISegmentedControl) {
        switch p1.selectedSegmentIndex {
        case 0:
            viewRecord.isHidden = false
            viewCollect.isHidden = true
            viewNotify.isHidden = true
            viewExchange.isHidden = true
        case 1:
            viewRecord.isHidden = true
            viewCollect.isHidden = false
            viewNotify.isHidden = true
            viewExchange.isHidden = true
        case 2:
            viewRecord.isHidden = true
            viewCollect.isHidden = true
            viewNotify.isHidden = false
            viewExchange.isHidden = true
        case 3:
            viewRecord.isHidden = true
            viewCollect.isHidden = true
            viewNotify.isHidden = true
            viewExchange.isHidden = false
        default:
            fatalError()
        }
    }
    
    /*傳送*/
    func executeTask(_ url_server: URL, _ requestParam: [String: String]) {
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
                    let Info = try? JSONDecoder().decode(User.self, from: data!)
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    self.userInfo = Info
                    // 將結果顯示在UI元件上必須轉給main thread
                    DispatchQueue.main.async {
                        
                        self.lbAccount.text = Info?.nickname
                        let integral = String(describing: Info!.integral!)
                        self.lbPoint.text = "\(integral) Point"
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        task.resume()
    }
    
    @IBAction func btSetting(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userInfo"{
            let PersonalSettingVC = segue.destination as! PersonalSettingVC
            PersonalSettingVC.userInfo = userInfo
        }
    }
    
}

