
import UIKit

class SelfieEditVC:  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selfie: UIImageView!
    
    let url_server = URL(string: common_url + "AccountServlet")
    var image: UIImage?
    
    //    @IBAction func clickTakePicture(_ sender: Any) {
    //        imagePicker(type: .camera)
    //    }
    //    @IBAction func clickPickPicture(_ sender: Any) {
    //        imagePicker(type: .photoLibrary)
    //    }
    //
    //    func imagePicker(type: UIImagePickerController.SourceType) {
    //        let imagePickerController = UIImagePickerController()
    //        imagePickerController.sourceType = type
    //        imagePickerController.delegate = self
    //        present(imagePickerController, animated: true, completion: nil)
    //    }
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //        if let selfieChange = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
    //            // 拍照或挑選的照片視為要上傳更新的照片
    //            imageUpload = selfieChange
    //            imageView.image = selfieChange
    //        }
    //        dismiss(animated: true, completion: nil)
    //    }
    //
    //    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //        dismiss(animated: true, completion: nil)
    //    }
    //
    //    @IBAction func clickUpdate(_ sender: Any) {
    //        if self.imageUpload != nil {
    //            requestParam["imageBase64"] = self.imageUpload!.jpegData(compressionQuality: 1.0)!.base64EncodedString()
    //        }
    //        executeTask(self.url_server!, requestParam) { (data, response, error) in
    //            if error == nil {
    //                if data != nil {
    //                    if let result = String(data: data!, encoding: .utf8) {
    //                        if let count = Int(result) {
    //                            DispatchQueue.main.async {
    //                                // 新增成功則回前頁
    //                                if count != 0 {                                            self.navigationController?.popViewController(animated: true)
    //                                } else {
    //                                    self.label.text = "update fail"
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            } else {
    //                print(error!.localizedDescription)
    //            }
    //        }
    //    }
    //
}
