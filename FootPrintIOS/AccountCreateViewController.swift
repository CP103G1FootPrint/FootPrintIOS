//
//  AccountCreateViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/3/28.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class AccountCreateViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var emailUITextField: UITextField!
    @IBOutlet weak var passwordUITextField: UITextField!
    @IBOutlet weak var nickNameUITextField: UITextField!
    
    @IBOutlet weak var constellationUITextView: UITextView!
    @IBOutlet weak var birthdayUITextView: UITextView!
    
    @IBOutlet weak var buttonImage: UIButton!
    let birthdayPicker = UIDatePicker()
    var picker = UIPickerView()
    var days = ["水瓶座","雙魚座","牡羊座","金牛座","雙子座","巨蟹座","獅子座","處女座","天秤座","天蠍座","射手座","摩羯座"]
    var pickedImage: UIImage?
    let format = DateFormatter()
    var chooseConstellation: String = ""
    var chooseBirthday: String = ""
    var resultCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //textViewColor
        textViewColor(textView: birthdayUITextView)
        textViewColor(textView: constellationUITextView)
        
        //生日挑選器
        createDatePicker()
        
        //星座挑選器
        picker.dataSource = self
        picker.delegate = self
//        constellationUITextView.text = days[0]
        constellationUITextView.inputView = picker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        constellationUITextView.inputAccessoryView = toolBar
        
        //鍵盤
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func donePicker(){
        constellationUITextView.resignFirstResponder()
    }
    @objc func cancelClick(){
        constellationUITextView.resignFirstResponder()
    }
    
    @IBAction func headImageAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        /* 將UIImagePickerControllerDelegate、UINavigationControllerDelegate物件指派給UIImagePickerController */
        imagePicker.delegate = self
        /* 照片來源為相簿 */
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /* 利用指定的key從info dictionary取出照片 */
        pickedImage = info[.originalImage] as? UIImage
        //來源如果是相機
        if picker.sourceType == .camera{
            UIImageWriteToSavedPhotosAlbum(pickedImage!, nil, nil, nil)
            dismiss(animated: true, completion: nil)
        }
        buttonImage.setImage(pickedImage, for: .normal)
        buttonImage.imageView?.layer.cornerRadius = buttonImage.frame.width/2
        dismiss(animated: true, completion: nil)
    }
    
    /* 挑選照片過程中如果按了Cancel，關閉挑選畫面 */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        let email = emailUITextField.text == nil ? "": emailUITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        validatedEmail(emailStr: email!)
        
        let password = passwordUITextField.text == nil ? "": passwordUITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let nickName = nickNameUITextField.text == nil ? "":
            nickNameUITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //判斷欄位是不是空的
        if email!.isEmpty {
            let text = "Email is empty"
            self.alertNote(text)
        }else if password!.isEmpty{
            let text = "Password is empty"
            self.alertNote(text)
        }else if nickName!.isEmpty{
            let text = "NickName is empty"
            self.alertNote(text)
        }else if chooseBirthday.isEmpty{
            let text = "Birthday is empty"
            self.alertNote(text)
        }else if chooseConstellation.isEmpty{
            let text = "Constellation is empty"
            self.alertNote(text)
        }else if pickedImage == nil {
            let text = "image is empty"
            self.alertNote(text)
        }else if resultCount == 0 {
            //
        }else{
            let account = Account(email!,password!,nickName!,chooseBirthday,chooseConstellation,0,0)
            self.insertUser(account: account, image: pickedImage!)
        }
    }
    
    //取消申請帳號
    @IBAction func cancelCreateAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //PickerView有幾個區塊
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //裡面有幾列
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }
    
    //選擇到的那列要做的事
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        constellationUITextView.text = days[row]
        chooseConstellation = days[row]
    }
    //設定每列PickerView要顯示的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return days[row]
    }
    
    //框顏色
    func textViewColor(textView:UITextView){
        //        textView.layer.borderColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
    }
    
    //選擇生日日期
    func createDatePicker(){
        birthdayPicker.datePickerMode = .date
        birthdayUITextView.inputView = birthdayPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))
        toolbar.setItems([doneButton], animated: true)
        birthdayUITextView.inputAccessoryView = toolbar
    }
    @objc func doneClicked(){
        format.dateFormat = "yyyy-MM-dd"
        birthdayUITextView.text = format.string(from: birthdayPicker.date)
        chooseBirthday = format.string(from: birthdayPicker.date)
        self.view.endEditing(true)
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
    @IBAction func tapGesture(_ sender: Any) {
        hideKeyboard()
    }
    @IBAction func didEndOnExit(_ sender: Any) {
        hideKeyboard()
    }
    /** 隱藏鍵盤 */
    func hideKeyboard(){
        emailUITextField.resignFirstResponder()
        passwordUITextField.resignFirstResponder()
        nickNameUITextField.resignFirstResponder()
    }
    
    //帳號驗證
    func validatedEmail(emailStr:String) {
        let regex =  "^.*@[A-Za-z0-9]+\\.com([-.]\\w+)*$"
        let predicate = NSPredicate(format:"SELF MATCHES %@",regex)
        let result = predicate.evaluate(with: emailStr)
        if !result {
            let text = "Email is invalid"
            self.alertNote(text)
            self.resultCount = 0
        }else{
            //檢查帳密
            let url_server = URL(string: common_url + "AccountServlet")
            var requestParam = [String: String]()
            requestParam["action"] = "accountExist"
            requestParam["userId"] = emailStr
            executeTask(url_server!, requestParam) { (data, response, error) in
                if error == nil {
                    if data != nil {
                        if String(data:data!,encoding: .utf8)! == "true" {
                            DispatchQueue.main.async {
                                //顯示帳密已存在
                                let text = "Email is Exist"
                                self.alertNote(text)
                                self.resultCount = 0
                            }
                        }else{
                            self.resultCount = 1
                        }
                    }
                }
            }
            
        }
    }
    
    //警示訊息
    func alertNote(_ text:String) {
        let alert = UIAlertController(title: "Note", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //新增使用者資訊
    func insertUser(account:Account,image:UIImage) {
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "AccountServlet")
        requestParam["action"] = "accountInsertNotFB"
        requestParam["account"] = try! String(data: JSONEncoder().encode(account), encoding: .utf8)
        requestParam["imageBase64"] = image.jpegData(compressionQuality: 0.0)!.base64EncodedString()
        //1.0品質最好 0.0品質最差
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = String(data: data!, encoding: .utf8) {
                        if let count = Int(result) {
                            if count != 0 {
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true, completion: nil)
                                }
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
