//
//  SignInViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/14.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SignInViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let url_server = URL(string: common_url + "/AccountServlet")
    var account:String? = ""
    var password:String? = ""
    
    @IBOutlet weak var fbButton: FBSDKLoginButton!
    @IBOutlet weak var accountTextFild: UITextField!
    @IBOutlet weak var passwordTextFild: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbButton.readPermissions = ["email"]
        fbButton.delegate = self
        
        // 第一次登入後可取得使用者token，後續即可直接登入
        if (FBSDKAccessToken.current()) != nil{
            //fetchProfile()
        }
        //自動登入
//                loadDataLogin()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func clickLogin(_ sender: UIButton) {
        //擷取使用者輸入的帳號
        account = accountTextFild.text == nil ? "": accountTextFild.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        //擷取使用者輸入的密碼
        password = passwordTextFild.text == nil ? "" :passwordTextFild.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        //判斷欄位是不是空的
        if account!.isEmpty || password!.isEmpty{
            let text = "User name or password is invalid"
            self.alertNote(text)
        }
        
        //檢查帳密
        var requestParam = [String: String]()
        requestParam["action"] = "accountValid"
        requestParam["userId"] = account
        requestParam["password"] = password
        let url_server = URL(string: common_url + "/AccountServlet")
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    //                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if String(data:data!,encoding: .utf8)! == "true" {
                        //儲存使用者資訊到userdefault
                        self.findUserInfo(account: self.account!)
                        self.findUserHead(account: self.account!)
                        let bool = saveUser(requestParam)
                        print("user save : \(bool)")
                        // 進入首頁
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "next", sender: self)
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            //顯示帳密有誤
                            let text = "User name or password incorrect!"
                            self.alertNote(text)
                        }
                    }
                }
            }
        }}
    //鍵盤
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            view.frame.origin.y = -keyboardHeight
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
    @IBAction func tapGesture(_ sender: Any) {
        hideKeyboard()
    }
    @IBAction func didEndOnExit(_ sender: Any) {
        hideKeyboard()
    }
    /** 隱藏鍵盤 */
    func hideKeyboard(){
        accountTextFild.resignFirstResponder()
        passwordTextFild.resignFirstResponder()
    }
    
    //fb
    func showProfile(){
        //可以指定照片尺寸，參看https://developers.facebook.com/docs/graph-api/reference/user/picture/
        let param = ["fields":"id, name, email, picture.width(600).height(600), birthday"]
        let myGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: param)
        var headData :Data?
        var userImage :UIImage?
        // FB 回應
        myGraphRequest?.start(completionHandler: { (connection, result, error) in
            if error == nil {
                if result != nil {
                    //                    print("result: \(result!)")
                    //轉成 字典模式 key,value 設定為Any
                    if let resultDic = result as? [String : Any] {
                        let id = resultDic["id"] ?? ""
                        let name = resultDic["name"] ?? ""
                        let birthday = resultDic["birthday"] ?? ""
                        let constellation = "天秤座" //預設
                        let password = "footPrint"  //預設
                        //先拿picture
                        if let picture = resultDic["picture"] as? [String : Any]{
                            //再拿data
                            let data = picture["data"] as! [String : Any]
                            //圖片儲存的格式 url 轉成 string
                            let pictureUrl = data["url"] as! String
                            let imgData = NSData(contentsOf: URL(string: pictureUrl)!)
                            userImage = UIImage(data: imgData! as Data)
                            headData = userImage?.pngData()
                        }
                        //                        let text = "ID: \(id)\nName: \(name)\nEmail: \(email)\nBirthday \(birthday)"
                        //                        print(text)
                        //檢查資料庫FB使用者帳號是否已申請
                        var requestParam = [String: Any]()
                        let url_server = URL(string: common_url + "/AccountServlet")
                        requestParam["action"] = "accountValidFB"
                        requestParam["userId"] = id
                        requestParam["fbId"] = 1
                        executeTask(url_server!, requestParam) { (data, response, error) in
                            if error == nil {
                                if data != nil {
                                    // 將輸入資料列印出來除錯用
                                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                                    if String(data:data!,encoding: .utf8)! == "true" {
                                        let accountFB = Account(id as! String, password, name as! String, birthday as! String, constellation)
                                        var requestParam = [String: String]()
                                        requestParam["userId"] = id as? String
                                        requestParam["password"] = password
                                        saveInfo(accountFB)
                                        let bool = saveUser(requestParam)
                                        saveUserHead(userHead: headData!)
                                        //動到UI元件要使用main async
                                        DispatchQueue.main.async {
                                            print("fb save : \(bool)")
                                            self.performSegue(withIdentifier: "next", sender: self)
                                        }
                                    }else{
                                        let account = Account(id as! String, password, name as! String, birthday as! String, constellation, 0, 1)
                                        self.insertUserFB(account: account, image: userImage!)
                                        var requestParam = [String: String]()
                                        requestParam["userId"] = id as? String
                                        requestParam["password"] = password
                                        let bool = saveUser(requestParam)
                                        //動到UI元件要使用main async
                                        DispatchQueue.main.async {
                                            print("fb save : \(bool)")
                                            self.performSegue(withIdentifier: "next", sender: self)
                                        }
                                    }
                                }
                            } else {
                                //print(error!.localizedDescription)
                            }
                        }
                    }
                    
                }
            }
        })
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        showProfile()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    //警示訊息
    func alertNote(_ text:String) {
        let alert = UIAlertController(title: "Note", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //取得使用者資訊
    func findUserInfo(account:String) {
        let url_server = URL(string: common_url + "/AccountServlet")
        var requestParam = [String: String]()
        requestParam["action"] = "findSelfInfo"
        requestParam["id"] = account
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    //                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode(Account.self, from: data!) {
                        //儲存到userDefault
                        //account , password, nickName, birthday, constellation
                        result.account = account
                        saveInfo(result)
                    }
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    
    //取得使用者頭像
    func findUserHead(account:String) {
        let url_server = URL(string: common_url + "/AccountServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "headImage"
        requestParam["userId"] = account
        requestParam["imageSize"] = 1024
        //        requestParam["imageSize"] = "\(UIScreen.main.bounds)"
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                    let headData = image?.pngData()
                    saveUserHead(userHead: headData!)
                }
                if image == nil {
                    image = UIImage(named: "user2.png")
                    let headData = image?.pngData()
                    saveUserHead(userHead: headData!)
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    //自動登入
    func loadDataLogin() {
        let userDefaults = UserDefaults.standard
        let user = userDefaults.data(forKey: "user")
        if user != nil{
            let result = try! JSONDecoder().decode([String: String].self, from: user!)
            let account = result["userId"]
            let password = result["password"]
            accountTextFild.text = account
            passwordTextFild.text = password
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "next", sender: self)
            }
        }
    }
    
    //新增使用者資訊fb
    func insertUserFB(account:Account,image:UIImage) {
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "/AccountServlet")
        requestParam["action"] = "accountInsert"
        requestParam["account"] = try! String(data: JSONEncoder().encode(account), encoding: .utf8)
        requestParam["imageBase64"] = image.jpegData(compressionQuality: 1.0)!.base64EncodedString()
        //1.0品質最好 0.0品質最差
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = String(data: data!, encoding: .utf8) {
                        if let count = Int(result) {
                            if count != 0 {
                                let headData = image.pngData()
                                saveUserHead(userHead: headData!)
                                saveInfo(account)
                            } else {
                                //                                print(error!.localizedDescription)
                            }
                        }
                    }
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
}
