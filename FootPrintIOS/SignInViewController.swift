//
//  SignInViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/14.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    let url_server = URL(string: common_url + "/AccountServlet")
    var account:String? = ""
    var password:String? = ""
    
    @IBOutlet weak var accountTextFild: UITextField!
    @IBOutlet weak var passwordTextFild: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func clickLogin(_ sender: UIButton) {
        account = accountTextFild.text == nil ? "": accountTextFild.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        password = passwordTextFild.text == nil ? "" :passwordTextFild.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if account!.isEmpty || password!.isEmpty{
            let alert = UIAlertController(title: "note", message: "user name or password is invalid", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        }
        let user = Account(account!,password!)
        var requestParam = [String: Any]()
        requestParam["action"] = "accountValid"
        requestParam["userId"] = account
        requestParam["password"] = password
        
        executeTask(url_server!, requestParam as! [String : String]) { (data, response, error) in

            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    print("input: \(String(data: data!, encoding: .utf8)!)")
                    
                     if String(data:data!,encoding: .utf8)! == "true" {
                         print("1234)")
                            let saved = saveUser(user)
                            print("saved = \(saved)")
                                    let userDefaults = UserDefaults.standard
                            userDefaults.set(self.account, forKey: "account")
                                    userDefaults.synchronize()
                            // 開啟下一頁
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "next", sender: self)
                            }
                        
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "note", message: "User name or password incorrect!", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                }
        }}
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
}
