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
    
    @IBOutlet weak var accountTextFild: UITextField!
    @IBOutlet weak var passwordTextFild: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickLogin(_ sender: UIButton) {
        let account = accountTextFild.text == nil ? "": accountTextFild.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextFild.text == nil ? "" :passwordTextFild.text?.trimmingCharacters(in: .whitespacesAndNewlines)
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
                    
                    if let result = try? JSONDecoder().decode( Bool.self, from: data!) {
                         print("1234)")
                        if result {
                            print("56788)")
                            let saved = saveUser(user)
                            print("saved = \(saved)")
                                    let userDefaults = UserDefaults.standard
                                    userDefaults.set(account, forKey: "account")
                                    userDefaults.synchronize()
                            // 開啟下一頁
                            
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "next", sender: self)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "note", message: "User name or password incorrect!", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            
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
                    
                }
                
            }
        }}}
