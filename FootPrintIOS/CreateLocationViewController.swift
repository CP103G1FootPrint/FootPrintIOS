import UIKit
import MapKit
import CoreLocation

class CreateLocationViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var nameUITextField: UITextField!
    @IBOutlet weak var addressUITextField: UITextField!
    @IBOutlet weak var descriptionUITextField: UITextField!
    @IBOutlet weak var openHoursUITextView: UITextView!
    @IBOutlet weak var evaluationUITextView: UITextView!
    @IBOutlet weak var typeUITextView: UITextView!
    @IBOutlet weak var openHorsEndUITextView: UITextView!
    
    var nearLocations = [LandMark]()
    let openHoursPicker = UIDatePicker()
    var picker = UIPickerView()
    var types = ["Recommended by Tourist","Restaurant","Hotel","Spot"]
    let format = DateFormatter()
    var chooseType: String = ""
    var chooseOpenHoursStand: String = ""
    var chooseOpenHoursEnd: String = ""
    var evaluationValue: Double = 0.5
    var resultCount = 0
    var requestCreateLocation = [String: Double]()
    var landMarkID :Int = 0
    var locationManager: CLLocationManager?
    var fromLocation: CLLocation?
    var gpslatitude: Double?
    var gpslongitude: Double?
    var locationFirstPage: LandMark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //locationManager
        locationManagers()
        
        //id
        findLandMarkID()
        
        //textViewColor
        textViewColor(textView: openHoursUITextView)
        textViewColor(textView: openHorsEndUITextView)
        
        //openHour挑選器
        createDatePickerStart()
        createDatePickerEnd()
        
        //type挑選器
        picker.dataSource = self
        picker.delegate = self
//        typeUITextView.text = types[0]
        typeUITextView.inputView = picker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        typeUITextView.inputAccessoryView = toolBar
        
        //鍵盤
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc func donePicker(){
        typeUITextView.resignFirstResponder()
    }
    @objc func cancelClick(){
        typeUITextView.resignFirstResponder()
    }
    
    // 評價動作
    @IBAction func evaluationSender(_ sender: UIStepper) {
        evaluationValue = Double(sender.value)   // Stepper回傳的是float所以需要轉成Double
        evaluationUITextView.text = String(evaluationValue) // Text為文字，所以將數字再轉為字串後顯示
//        print(" latitude create: \(self.gpslatitude)")
    }
    
    // 新建地標
    @IBAction func createLandMarkButton(_ sender: Any) {
        
        let name = nameUITextField.text == nil ? "": nameUITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let description = descriptionUITextField.text == nil ? "": descriptionUITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var sumOpenHours:String?
        sumOpenHours = String("\(chooseOpenHoursStand) - \(chooseOpenHoursEnd)")
        
        //GPS
        var latitude :Double?
        var longitude :Double?
        let address = addressUITextField.text == nil ? "": addressUITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
//        latitude = self.gpslatitude
//        longitude = self.gpslongitude
        
        if name!.isEmpty {
            let text = "name is empty"
            self.alertNote(text)
        }else if description!.isEmpty {
            let text = "description is empty"
            self.alertNote(text)
        }else if sumOpenHours!.isEmpty {
            let text = "OpenHours is empty"
            self.alertNote(text)
        }else if self.chooseType.isEmpty {
            let text = "type is empty"
            self.alertNote(text)
        }else if self.evaluationValue < 0.5 {
            let text = "evaluation is empty"
            self.alertNote(text)
        }else if address!.isEmpty {
            let text = "address is empty"
            self.alertNote(text)
        }else if self.landMarkID == 0 {
            let text = "Not Net Work"
            self.alertNote(text)
        }else {
            latitude = self.gpslatitude
            longitude = self.gpslongitude
            if self.landMarkID == 0 {
                let text = "No Net Work"
                self.alertNote(text)
            }else {
                let locationall = LandMark(self.landMarkID + 1,name!,address!,latitude!,longitude!,description!,sumOpenHours!,self.chooseType,self.evaluationValue)
                self.locationFirstPage = locationall
                self.insertLandMark(landMark: locationall)
                //                        print("123 \(locationall.address)")
                let notificationName = Notification.Name("locationCreateLandMark")
                //發送通知
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["locationLandMark":locationall])
                self.navigationController?.popToRootViewController(animated: true)
                //                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "camera") {
                //                            self.present(controller, animated: true, completion: nil)
                //                        }
            }
        //
        //建立編碼器
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(address!) { (placemarks, error) in
//            if error == nil && placemarks != nil && placemarks!.count > 0 {
//                //只取第一個結果
//                if let placemark = placemarks!.first {
//                    //座標
//                    let location2d = placemark.location!
//                    latitude = location2d.coordinate.latitude
//                    longitude = location2d.coordinate.longitude
//                }
//            }else {
//                    latitude = self.gpslatitude
//                    longitude = self.gpslongitude
//
//                    if self.landMarkID == 0 {
//                        let text = "No Net Work"
//                        self.alertNote(text)
//                    }else {
//                        let locationall = LandMark(self.landMarkID + 1,name!,address!,latitude!,longitude!,description!,sumOpenHours!,self.chooseType,self.evaluationValue)
//                        self.locationFirstPage = locationall
//                        self.insertLandMark(landMark: locationall)
////                        print("123 \(locationall.address)")
//                        let notificationName = Notification.Name("locationCreateLandMark")
//                        //發送通知
//                        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["locationLandMark":locationall])
//                        self.navigationController?.popToRootViewController(animated: true)
////                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "camera") {
////                            self.present(controller, animated: true, completion: nil)
////                        }
//                    }
//                }
            //
            }
        

    
        
        
        
    }
    
    //PickerView有幾個區塊
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //裡面有幾列
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    //選擇到的那列要做的事
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeUITextView.text = types[row]
        chooseType = types[row]
    }
    //設定每列PickerView要顯示的內容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    //框顏色
    func textViewColor(textView:UITextView){
        //        textView.layer.borderColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
    }
    
    //選擇開放時間Start
    func createDatePickerStart(){
        openHoursPicker.datePickerMode = .time
        openHoursUITextView.inputView = openHoursPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedStart))
        toolbar.setItems([doneButton], animated: true)
        openHoursUITextView.inputAccessoryView = toolbar
    }
    @objc func doneClickedStart(){
        format.dateFormat = "HH:mm"
        // let date = format.date(from: openHoursPicker.date)
        let date24 = format.string(from: openHoursPicker.date)
        openHoursUITextView.text = date24
        chooseOpenHoursStand = date24
        self.view.endEditing(true)
    }
    
    //選擇開放時間End
    func createDatePickerEnd(){
        openHoursPicker.datePickerMode = .time
        openHorsEndUITextView.inputView = openHoursPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedEnd))
        toolbar.setItems([doneButton], animated: true)
        openHorsEndUITextView.inputAccessoryView = toolbar
    }
    @objc func doneClickedEnd(){
        format.dateFormat = "HH:mm"
        // let date = format.date(from: openHoursPicker.date)
        let date24 = format.string(from: openHoursPicker.date)
        openHorsEndUITextView.text = date24
        chooseOpenHoursEnd = date24
        self.view.endEditing(true)
    }
    
    //警示訊息
    func alertNote(_ text:String) {
        let alert = UIAlertController(title: "Note", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //新增地標
    func insertLandMark(landMark:LandMark) {
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "LocationServlet")
        requestParam["action"] = "landMarkInsert"
        requestParam["landMark"] = try! String(data: JSONEncoder().encode(landMark), encoding: .utf8)
        //1.0品質最好 0.0品質最差
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                     print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = String(data: data!, encoding: .utf8) {
                        if let count = Int(result) {
                            if count != 0 {
                                DispatchQueue.main.async {
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //新增地標
    func findLandMarkID() {
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "LocationServlet")
        requestParam["action"] = "findLandMarkLastId"
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = String(data: data!, encoding: .utf8) {
                        self.landMarkID = Int(result)!
                    }
                }
            }
        }
    }
    
    //鍵盤
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
//            view.frame.origin.y = -keyboardHeight
            view.frame.origin.y = -50
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
        nameUITextField.resignFirstResponder()
        addressUITextField.resignFirstResponder()
        descriptionUITextField.resignFirstResponder()
    }
    
    func locationManagers() {
        //取得問位置管理權限
        locationManager = CLLocationManager()
        //請求user同意時取的位置
        locationManager?.requestWhenInUseAuthorization()
        //監聽器
        locationManager?.delegate = self
        //精準度
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        //位置移動多少後再去抓新值 會去呼叫 didUpdateLocations方法
        locationManager?.distanceFilter = 10
        //開始更新
        locationManager?.startUpdatingLocation()
    }
    
    /* 實作CLLocationManagerDelegate */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /* 若無起點，就將第一次更新取得的位置當作起點 */
        let newLocation = locations[0]
        if fromLocation == nil {
            fromLocation = newLocation
            gpslatitude = fromLocation?.coordinate.latitude
            gpslongitude = fromLocation?.coordinate.longitude
        }else {
            fromLocation = locations.last!
            gpslatitude = fromLocation?.coordinate.latitude
            gpslongitude = fromLocation?.coordinate.longitude
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sourceController = segue.destination as? CameraViewController
//        print("prepare \(locationFirstPage?.address)")
        sourceController?.result = locationFirstPage
    }
}
