import UIKit

class PersonalSettingVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    let url_server = URL(string:common_url + "AccountServlet")
    //    let userDefault = UserDefaults.standard
    var userInfo : User?
    let user = loadData()
    var newPostImage: UIImage?
    var image: UIImage?
    let userHead = UIImage(data: loadHead())
    
    @IBOutlet weak var btSelfie: UIButton!
    @IBOutlet weak var lbAccount: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfNickName: UITextField!
    @IBOutlet weak var tfBirthday: UITextField!
    @IBOutlet weak var tfConstellation: UITextField!
    @IBOutlet weak var tvResult: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //鍵盤
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        btSelfie.setImage(userHead, for: .normal)
        lbAccount.text = user.account
        print("userInfo?.password \(userInfo?.password)")
        tfPassword.text = userInfo?.password
        tfBirthday.text = userInfo?.birthday
        tfNickName.text = userInfo?.nickname
        tfConstellation.text = userInfo?.constellation
    }
    override func viewWillAppear(_ animated: Bool) {
        print("will userInfo?.password \(userInfo?.password)")
    }
    //換照片
    @IBAction func btImage(_ sender: Any) {
        let alertController = UIAlertController(title: "Image From", message: nil,
                                                preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let cameramAction = UIAlertAction(title: "Cameram", style: .default) { (UIAlertAction) in self.takePicture()
        }
        let albumAction = UIAlertAction(title: "Album", style: .default) { (UIAlertAction) in self.choosePicture()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(cameramAction)
        alertController.addAction(albumAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //照片來源方式
    func takePicture(){
        imagePicker(type: .camera)
    }
    func choosePicture(){
        imagePicker(type: .photoLibrary)
    }
    func imagePicker(type: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = type
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /* 利用指定的key從info dictionary取出照片 */
        newPostImage = info[.originalImage] as? UIImage
        //來源如果是相機
        if picker.sourceType == .camera{
            UIImageWriteToSavedPhotosAlbum(newPostImage!, nil, nil, nil)
            dismiss(animated: true, completion: nil)
        }
        btSelfie.setImage(newPostImage, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    /* 挑選照片過程中如果按了Cancel，關閉挑選畫面 */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //鍵盤
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            view.frame.origin.y = -180
        } else {
            view.frame.origin.y = -view.frame.height / 3
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func tfPassword(_ sender: Any) {
        hideKeyboard()
    }
    @IBAction func tfNickName(_ sender: Any) {
        hideKeyboard()
    }
    @IBAction func tfBirthday(_ sender: Any) {
        hideKeyboard()
    }
    @IBAction func tfConstellation(_ sender: Any) {
        hideKeyboard()
    }
    
    @IBAction func gesture(_ sender: Any) {
    }
    
    /** 隱藏鍵盤 */
    func hideKeyboard(){
        tfPassword.resignFirstResponder()
        tfNickName.resignFirstResponder()
        tfBirthday.resignFirstResponder()
        tfConstellation.resignFirstResponder()
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
        executeTasks(url_server!,requsetParam)
        //照片
        var picParam = [String: String]()
        picParam["action"] = "changePic"
        picParam["userId"] = user.account
        if self.image != nil {
            picParam["imageBase64"] = self.image!.jpegData(compressionQuality: 1.0)!.base64EncodedString()
        }
        executeTask(self.url_server!, picParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    if let result = String(data: data!, encoding: .utf8) {
                        print("input321:\(result)")
                        if let count = Int(result) {
                            DispatchQueue.main.async {
                                // 新增成功則回前頁
                                if count != 0 {
                                    let head = self.image!.pngData()
                                    saveUserHead(userHead: head!)
                                    print("updata success")
                                    //                                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "PersonalVC"){
                                    //                                        self.present(controller, animated: true, completion: nil)
                                    //                                    }
                                    self.dismiss(animated: true, completion: nil)
                                } else {
                                    print("updata faild")
                                }
                            }
                        }
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    /*傳送*/
    func executeTasks(_ url_server: URL, _ requestParam: [String: String]) {
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
                    //                    DispatchQueue.main.async {
                    //                        self.showResult(String(data: data!, encoding: .utf8)!)
                }
            }
        }
    }
            @IBAction func btLogout(_ sender: Any) {
                //        let text : String? = ""
                //        let account = Account(text!,text!,text!,text!,text!)
                //        saveInfo(account)
                //
                //        var requestParam = [String: String]()
                //        requestParam["userId"] = text
                //        requestParam["password"] = text
                //        _ = saveUser(requestParam)
                
// DispatchQueue.main.async {
// let storyboard = UIStoryboard(name: "Main", bundle: nil) //storyboard
// let destination = storyboard.instantiateViewController(withIdentifier:"SignInViewController")
//                    self.present(destination,animated:true,completion:nil)
//                }
                
                
            }
}
