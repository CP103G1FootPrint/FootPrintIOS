//
//  CreateTripViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/3/12.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class CreateTripViewController: UIViewController ,UIPickerViewDataSource,UIPickerViewDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var tripfriend = [String]()
    let url_server = URL(string: common_url + "/TripServlet")
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dayPicker: UITextField!
    @IBOutlet weak var datePickerTextFild: UITextField!
    @IBOutlet weak var tripNameTextFild: UITextField!
    @IBOutlet weak var friendListTextView: UITextView!
    
    var image: UIImage?
    let datePicker = UIDatePicker()
    var picker = UIPickerView()
    var days = ["1","2","3","4","5","6","7","8","9","10"]
    var addFriends:String?
    var tripID:Int?
    
    //挑選照片
    @IBAction func clickPickPhoto(_ sender: Any) {
        imagePicker(type: .photoLibrary)
    }
    func imagePicker(type: UIImagePickerController.SourceType) {
//        hideKeyboard()
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = type
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let tripImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = tripImage
            imageView.image = tripImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        findTripId()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        addKeyboardObserver()
        createDatePicker()
        //選擇旅遊天數
        picker.delegate = self
        picker.dataSource = self
        dayPicker.inputView = picker
         let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        dayPicker.inputAccessoryView = toolBar
        
//        findTripId()
        
        //加入行程的好友
//        friendListTextView.text = tripfriend.joined(separator: ",")
    }
//    override func viewWillAppear(_ animated: Bool) {
//        findTripId()
//    }
    
    
    @objc func donePicker(){
        dayPicker.resignFirstResponder()
    }
    @objc func cancelClick(){
        dayPicker.resignFirstResponder()
    }
    
    //選擇出發日期
    func createDatePicker(){
        datePicker.datePickerMode = .date
        datePickerTextFild.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))
        
        toolbar.setItems([doneButton], animated: true)
        datePickerTextFild.inputAccessoryView = toolbar
    }
    @objc func doneClicked(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        datePickerTextFild.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
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
        dayPicker.text = days[row]
    }
    //設定每列PickerView要顯示的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return days[row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func findTripId(){
        var requestParam = [String: String]()
        requestParam["action"] = "findTripId"
        executeTask(self.url_server!, requestParam
            , completionHandler: { (data, response, error) in
                if error == nil {
                    if data != nil {
                        if let result = String(data: data!, encoding: .utf8) {
                              self.tripID = Int(result)
//                            print("trip\(self.tripID)")
                        }
                    }
                } else {
                    print(error!.localizedDescription)
                }
        })
    }
    
    
    
    @IBAction func clickSave(_ sender: Any) {
        let user = loadData()
        let account = user.account
        
        
        
//        let tripID = count
        let title = tripNameTextFild.text == nil ? "" : tripNameTextFild.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let formater = DateFormatter();
        formater.dateFormat = "yyyy-MM-dd"
        let dateStr = formater.string(from: (datePicker.date))
        
        var days = dayPicker.text == nil ? "1" : dayPicker.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if days.isEmpty {
             days = "1"
        }
        let day:Int = Int(days)!
        let type: String
        if friendListTextView.text.isEmpty {
            type = "Personal"
        }else {
            type = "Group"
        }
        let createID = account
    
        let trip = Trip(tripID!+1,title,dateStr,type,createID,day)
        
       var requestParam = [String: String]()
        requestParam["action"] = "tripInsert"
        requestParam["trip"] = try! String(data: JSONEncoder().encode(trip), encoding: .utf8) //主轉成jason 字串 只有文字沒有圖
        // 有圖才上傳 圖轉乘的imageBase64 字串
        if self.image != nil {
            requestParam["imageBase64"] = self.image!.jpegData(compressionQuality: 1.0)!.base64EncodedString() //compressionQuality: 1.0 紙質最好的圖
        }
        executeTask(self.url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    if let result = String(data: data!, encoding: .utf8) {
                        if let count = Int(result) {
                            DispatchQueue.main.async {
                                // 新增成功則回前頁
                                if count != 0 {                                            self.navigationController?.popViewController(animated: true)
                                } else {
                                    let alertController = UIAlertController(title: "insert fail",
                                                                            message: nil, preferredStyle: .alert)
                                    self.present(alertController, animated: true, completion: nil)
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                        self.presentedViewController?.dismiss(animated: false, completion: nil)
                                    }
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
    
    @IBAction func clickCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    //按下 return 鍵收鍵盤
    @IBAction func didEndOnExit(_ sender: Any) {
    }
    
    @IBAction func unwindToCreateTripViewController(segue: UIStoryboardSegue){
        friendListTextView.text = tripfriend.joined(separator: ",")
    }
    
    
    
    }

