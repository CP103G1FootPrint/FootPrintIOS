

import UIKit

class CameraViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageDescriptionUITextField: UITextField!
    @IBOutlet weak var openStateUISwitch: UISwitch!
    @IBOutlet weak var showLocationUILabel: UILabel!
    
    @IBOutlet weak var newPostUIButton: UIButton!
    
    
    var newPostImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //鍵盤
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let account = user.account
        
        if newPostImage == nil {
            let text = "Image is empty"
            self.alertNote(text)
        }else if imageDescriptionUITextField == nil {
            let text = "Image description is empty"
            self.alertNote(text)
        }else{
            let cameraImage = CameraImage(0,imageDescription!,openSateText!,account,1)
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
        let url_server = URL(string: common_url + "/PictureServlet")
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
}
