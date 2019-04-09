import Foundation
import UIKit

// 實機

let URL_SERVER = "http://192.168.0.101:8080/FootPrint/"
// 模擬器
let common_url = "http://127.0.0.1:8080/FootPrint/"
//實機
//let common_url = "http:// 192.168.50.204:8080/FootPrint/"

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
