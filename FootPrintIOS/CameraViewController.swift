import UIKit
import CoreLocation

class CameraViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var imageDescriptionUITextField: UITextField!
    @IBOutlet weak var openStateUISwitch: UISwitch!
    @IBOutlet weak var showLocationUILabel: UILabel!
    

    @IBOutlet weak var chooseLocationUIButton: UIButton!
    @IBOutlet weak var newPostUIButton: UIButton!
    
    var locationManager: CLLocationManager?
    var fromLocation: CLLocation?
    var newPostImage: UIImage?
    var gpslatitude: Double?
    var gpslongitude: Double?
    var showLandMark: LandMark?
    var result : LandMark?
    var landMarkID : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //locationManager
        locationManagers()
        
        //框顏色
        self.chooseLocationUIButton.layer.borderWidth = 1.0
        self.chooseLocationUIButton.layer.borderColor = UIColor.lightGray.cgColor
        self.chooseLocationUIButton.layer.cornerRadius = 5.0
        
        //鍵盤
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    //Unwind segue
    @IBAction func toresult(segue: UIStoryboardSegue) {
        let notificationName = Notification.Name("locationCreate")
        NotificationCenter.default.addObserver(self, selector: #selector(songUpdated(noti:)), name: notificationName, object: nil)
    }

    //選照片動作
    @IBAction func chooseImage(_ sender: Any) {
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
    
    
    //上傳
    @IBAction func insertNewPost(_ sender: Any) {

        let imageDescription = imageDescriptionUITextField.text == nil ? "": imageDescriptionUITextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var openSateText: String?
        if openStateUISwitch.isOn {
            openSateText = "Public"
        }else{
            openSateText = "Private"
        }
        
        let user = loadData()
        
        let landMarkID = result?.id
        
        if newPostImage == nil {
            let text = "Image is empty"
            self.alertNote(text)
        }else if imageDescription!.isEmpty {
            let text = "Image description is empty"
            self.alertNote(text)
        }else if landMarkID == nil {
            let text = "landMark is empty"
            self.alertNote(text)
        }else{
            let cameraImage = CameraImage(0,imageDescription!,openSateText!,user.account,landMarkID!)
            self.insertNewPost(cameraImage: cameraImage, image: newPostImage!)
        }
        
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
        newPostUIButton.setImage(newPostImage, for: .normal)
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
        imageDescriptionUITextField.resignFirstResponder()
    }
    
    //警示訊息
    func alertNote(_ text:String) {
        let alert = UIAlertController(title: "Note", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //新增貼文
    func insertNewPost(cameraImage:CameraImage,image:UIImage) {
        var requestParam = [String: String]()
        let url_server = URL(string: common_url + "PictureServlet")
        requestParam["action"] = "shareInsert"
        requestParam["share"] = try! String(data: JSONEncoder().encode(cameraImage), encoding: .utf8)
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
                                DispatchQueue.main.async {
                                   let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let home = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                                    self.present(home, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //傳GPS給NearLocationTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let cameraViewController = segue.destination as? FindLocationViewController
        if gpslatitude != nil && gpslongitude != nil {
            cameraViewController?.requestParam["latitude"] = gpslatitude
            cameraViewController?.requestParam["longitude"] = gpslongitude
        }
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
    
    /* 實作CLLocationManagerDelegate */
    //當抓不到值得時候
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let text = error.localizedDescription
        self.alertNote(text)
    }
    

    func updateInfo(){
//        showLocationUILabel.text = "777"
    }
    
    
    @objc func songUpdated(noti:Notification) {
        result = noti.userInfo!["location"] as? LandMark
//        showLocationUILabel.text = result?.address
        DispatchQueue.main.async {
            self.showLocationUILabel.text = self.result?.address
        }
//        updateInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
