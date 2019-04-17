import Foundation
import UIKit

// 實機
let URL_SERVER = "http://192.168.0.101:8080/FootPrint/"
// 模擬器
let common_url = "http://127.0.0.1:8080/FootPrint/"
//實機
//let common_url = "http://172.20.10.3:8080/FootPrint/"

//Socket
let url_server_schedule = "ws://127.0.0.1:8080/FootPrint/ScheduleDayServer/"

func executeTask(_ url_server: URL, _ requestParam: [String: Any], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
    // requestParam值為Any就必須使用JSONSerialization.data()，而非JSONEncoder.encode()
    let jsonData = try! JSONSerialization.data(withJSONObject: requestParam)
    var request = URLRequest(url: url_server)
    request.httpMethod = "POST"
    request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
    request.httpBody = jsonData
    let sessionData = URLSession.shared
    let task = sessionData.dataTask(with: request, completionHandler: completionHandler)
    task.resume()
}

func showSimpleAlert(message: String, viewController: UIViewController) {
    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(cancel)
    /* 呼叫present()才會跳出Alert Controller */
    viewController.present(alertController, animated: true, completion:nil)
}
//存帳密
func saveUser(_ user: [String: String]) -> Bool {
    if let jsonData = try? JSONEncoder().encode(user) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(jsonData, forKey: "user")
        return userDefaults.synchronize()
    } else {
        return false
    }
}
//讀帳密
func loadData() ->( account : String, password : String){
    let userDefaults = UserDefaults.standard
    let user = userDefaults.data(forKey: "user")
    let result = try! JSONDecoder().decode([String: String].self, from: user!)
    let account = result["userId"]
    let password = result["password"]
    return (account!, password!)
}
//存頭像
func saveUserHead( userHead : Data ){
    let userDefaults = UserDefaults.standard
    userDefaults.set(userHead, forKey: "userHead")
    userDefaults.synchronize()
}
//讀頭像
func loadHead() ->( Data ){
    let userDefaults = UserDefaults.standard
    let userHead = userDefaults.data(forKey: "userHead")
    return userHead!
}
//存個人資訊
func saveInfo( _ account : Account){
    let userDefaults = UserDefaults.standard
    let jsonData = try! JSONEncoder().encode(account)
    userDefaults.set(jsonData, forKey: "userInfo")
    userDefaults.synchronize()
}
//讀個人資訊
func loadInfo() -> (account : String, password : String, nickName : String, birthday : String, constellation : String){
    let userDefaults = UserDefaults.standard
    let userInfo = userDefaults.data(forKey: "userInfo")
    let result = try! JSONDecoder().decode(Account.self, from: userInfo!)
    let userId = result.account
    let password = result.password
    let nickName = result.nickname
    let birthday = result.birthday
    let constellation = result.constellation
    return (userId!,password!,nickName!,birthday!,constellation!)
}
/*  除讀取帳密用法
 let user = loadData()
 let account = user.account
 let password = user.password
 print("\(user.account) + \(user.password)")
 */

extension UITableView {
    
    func setEmptyView(title: String, message: String, messageImage: UIImage) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let messageImageView = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        messageImageView.backgroundColor = .clear
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageImageView)
        emptyView.addSubview(messageLabel)
        
        messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20).isActive = true
        messageImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageImageView.image = messageImage
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        UIView.animate(withDuration: 1, animations: {
            
            messageImageView.transform = CGAffineTransform(rotationAngle: .pi / 10)
        }, completion: { (finish) in
            UIView.animate(withDuration: 1, animations: {
                messageImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 10))
            }, completion: { (finishh) in
                UIView.animate(withDuration: 1, animations: {
                    messageImageView.transform = CGAffineTransform.identity
                })
            })
            
        })
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        
        self.backgroundView = nil
        self.separatorStyle = .singleLine
        
    }
    
}
