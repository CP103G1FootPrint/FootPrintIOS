import UIKit

class PersonalSettingVC: UIViewController {
    
    let url_server = URL(string:common_url + "AccountServlet")
//    let userDefault = UserDefaults.standard
    var userInfo : User?
     let user = loadData()
    
    @IBOutlet weak var btSelfie: UIButton!
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfNickName: UITextField!
    @IBOutlet weak var tfBirthday: UITextField!
    @IBOutlet weak var tfConstellation: UITextField!
    @IBOutlet weak var tvResult: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        lbAccount.text = userDefault.string(forKey: "user")
        lbAccount.text = user.account
        tfPassword.text = userInfo?.password
        tfBirthday.text = userInfo?.birthday
        tfNickName.text = userInfo?.nickname
        tfConstellation.text = userInfo?.constellation
    }
    
    
    
    @IBAction func btDone(_ sender: Any) {
        //取當下textfield的值
        let password = tfPassword.text == nil ? "":
            tfPassword.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        let nickName = tfNickName.text == nil ? "":
            tfNickName.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        let birthday = tfBirthday.text == nil ? "":
            tfBirthday.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        let constellation = tfConstellation.text == nil ? "":
            tfConstellation.text?.trimmingCharacters(in:.whitespacesAndNewlines)
        let account = lbAccount.text
        if password!.isEmpty || nickName!.isEmpty || birthday!.isEmpty || constellation!.isEmpty {
            return //動作無法送出
        }
        let user = User(password!,nickName!,birthday!,constellation!,account!)
        let userJson = try?String(data: JSONEncoder().encode(user),encoding: .utf8)
        /*打包*/ //把要傳送的值打包
        var requsetParam = [String:String]() //[String:String]()是dicitionary是方法要加()
        requsetParam["action"] = "accountUpdate"
        requsetParam["account"] = userJson! //eclipse端accountUpdate裡的account
        executeTask(url_server!,requsetParam)
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
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    
                    // 將結果顯示在UI元件上必須轉給main thread
                    DispatchQueue.main.async {
                        self.showResult(String(data: data!, encoding: .utf8)!)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    func showResult(_ result: String) {
        if result == "1" {
            self.tvResult.text = "更改成功！"
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "PersonalVC"){
                self.present(controller,animated: true, completion: nil)
            }
            else {
                self.tvResult.text = "更改失敗！"
            }
            
        }
        
    }
    
    @IBAction func clickLogout(_ sender: Any) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil) //storyboard
            let destination = storyboard.instantiateViewController(withIdentifier:"SignInViewController")
            self.present(destination,animated:true,completion:nil)
            
            
        }
        
    }
}


