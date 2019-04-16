//
//  PlanDetailViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/12.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import Starscream

class PlanDetailViewController: UIViewController,UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var uiTableView: UITableView!
    
    var currentArray = [LandMark]()
    var locationsArray = [LandMark]()
    var friendList  = [String]()
    var numberOfButtons :Int?
    var tripID :Int?
    var tripForDetail: Trip!
    var currentButton:Int = 0
    var socket: WebSocket!
    var user = loadData()
    var receiver:String?
    var placeSelected: Int?
    var placeSelecteds: [LandMark]?
    var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var mScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //run
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.uiTableView.tableFooterView = UIView()
        self.uiTableView.backgroundView = activityIndicatorView
        
        print("\(self) \(#function)" )
        setdata()
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureRecognized(_:)))
        uiTableView.addGestureRecognizer(longpress)
        
        let notificationName = Notification.Name("Planlocation")
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated(noti:)), name: notificationName, object: nil)
        
        socket = WebSocket(url: URL(string: url_server_schedule + user.account)!)
        addSocketCallBacks()
        socket.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dynamicButtonCreation()
        //run
        if currentArray.count == 0 {
            activityIndicatorView.startAnimating()
        }
    }
    
    func dynamicButtonCreation() {
        mScrollView.delegate = self
        mScrollView.isUserInteractionEnabled = true
        // 滑動條的樣式
        mScrollView.indicatorStyle = .black
        // 是否可以滑動
        mScrollView.isScrollEnabled = true
        // 是否可以按狀態列回到最上方
        mScrollView.scrollsToTop = false
        // 是否限制滑動時只能單個方向 垂直或水平滑動
        mScrollView.isDirectionalLockEnabled = true
        // 滑動超過範圍時是否使用彈回效果
        mScrollView.bounces = true
        // 刷新
        mScrollView.subviews.forEach { (button) in
            button.removeFromSuperview()
        }
        
        var count = 0
        var px = 0
        var py = 0
        px = 0
        if count < numberOfButtons! {
            for j in 1...numberOfButtons! {
                count += 1
                let Button = UIButton()
                Button.tag = count
                Button.frame = CGRect(x: px+10, y: py, width: 80, height: 48)
                Button.backgroundColor = UIColor(red: 75.0/255.0, green: 187.0/255.0, blue: 164.0/255.0, alpha: 1.0)
                Button.setTitle("第\(j)天", for: .normal)
                Button.addTarget(self, action: #selector(scrollButtonAction), for: .touchUpInside)
                mScrollView.addSubview(Button)
                px = px + 90
            }
        }
        py =  90
        mScrollView.contentSize = CGSize(width: px, height: py)
    }
    
    @objc func scrollButtonAction(sender: UIButton) {
        changeDataLandMark(tripID!, sender.tag - 1)
        currentButton = sender.tag - 1
        //發送通知
        let notificationName = Notification.Name("ScheduleTripMapChange")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: ["TripID": tripID as Any, "Day":sender.tag - 1 as Any])
    }
    
    @IBAction func addDay(_ sender: Any) {
        numberOfButtons = numberOfButtons! + 1
        // message
        let addMessage = ScheduleDay("ScheduleDay", "dayChangeAdd", self.user.account, receiver!, 1, self.numberOfButtons!)
        dayUpdate(self.tripID!, self.numberOfButtons!,addMessage)
        DispatchQueue.main.async {
            self.viewWillAppear(true)
        }
    }
    
    @IBAction func miday(_ sender: Any) {
        if numberOfButtons! > 1 {
            
            //Alert確認是否刪除資料
            let alert = UIAlertController(title: "note", message: "確定要減少一天嗎？", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default,handler: { action in
                self.numberOfButtons = self.numberOfButtons! - 1
                // message
                let addMessage = ScheduleDay("ScheduleDay", "dayChangeLess", self.user.account, self.receiver!, 1, self.numberOfButtons!)
                self.dayUpdate(self.tripID!, self.numberOfButtons!, addMessage)
                self.dayLandMarkDelete(self.tripID!, self.numberOfButtons!)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }else {
            let alert = UIAlertController(title: "note", message: "別再刪了,只剩一天了", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanDetailCell") as? PlanTableViewCell
        let location = currentArray[indexPath.row]
        cell?.planLocationName.text = location.name
        cell?.planLocationAddress.text = location.address
        cell?.planLocationType.text = location.type
//        findImage(location.id!, cell!)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("\(indexPath.row)")
        performSegue(withIdentifier: "unwindsegueMapController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //送回地圖
        if let indexPath  = uiTableView.indexPathForSelectedRow{
            placeSelected = indexPath.row
            placeSelecteds = currentArray
        }
    }
    //cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //增加地標按鍵的框
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width - 20, height: 60))
        let Button = UIButton()
        Button.frame = CGRect(x: 10, y: 10, width: tableView.frame.size.width - 20, height: 60)
        Button.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let myColor : UIColor = UIColor(red: 75.0/255.0, green: 187.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        Button.layer.borderColor = myColor.cgColor
        Button.layer.cornerRadius = 30
        //設定圖片邊框粗細
        Button.layer.borderWidth = 5.0
        //設定圖片圓形
//        Button.layer.cornerRadius = Button.frame.width/2
        Button.setTitleColor(myColor, for: .normal)
        Button.setTitle("Add LandMark", for: .normal)
        Button.addTarget(self, action: #selector(addLandMarkAction), for: .touchUpInside)
        footerView.addSubview(Button)
        
        return footerView
    }
    //增加地標按鍵的框高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 56
    }
    //增加地標按鍵的動作
    @objc func addLandMarkAction(sender: UIButton) {
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "PlanFindLocationViewController") as! PlanFindLocationViewController
        detailVC.getCurrentButton = currentButton
        print("prepare \(currentButton)")
        navigationController!.pushViewController(detailVC, animated: true)
    }

    //delet action
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        currentArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        // message
        let location = try! String(data: JSONEncoder().encode(currentArray), encoding: .utf8)
        let addMessage = ScheduleDay("ScheduleDayRecycle", currentButton, "judgmentDay", user.account, receiver!, 1, tripID!, location!)
        deletOneLandMark("changePositionLandMarkInSchedulePlanDay", tripID!, currentButton , currentArray, addMessage)
    }
    //delet title
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }
    
    //data
    func setdata() {
        //行程天數
        numberOfButtons = tripForDetail.days
        //id
        tripID = tripForDetail.tripID
        //get friend
        getFriends(tripID!)
        //init table
        changeDataLandMark(tripID!,0)
        
    }
    
    //table can move roll
    @objc func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: uiTableView)
        let indexPath = uiTableView.indexPathForRow(at: locationInView)
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = uiTableView.cellForRow(at: indexPath!) as UITableViewCell?
                My.cellSnapshot  = snapshotOfCell(cell!)
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                uiTableView.addSubview(My.cellSnapshot!)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell?.alpha = 1
                            })
                        } else {
                            cell?.isHidden = true
                        }
                    }
                })
            }
        case UIGestureRecognizerState.changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    currentArray.insert(currentArray.remove(at: Path.initialIndexPath!.row), at: indexPath!.row)
                    uiTableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    Path.initialIndexPath = indexPath
                    // message
                    let location = try! String(data: JSONEncoder().encode(currentArray), encoding: .utf8)
                    let addMessage = ScheduleDay("ScheduleDayRecycle", currentButton, "judgmentDay", user.account, receiver!, 1, tripID!, location!)
                    deletOneLandMark("changePositionLandMarkInSchedulePlanDay", tripID!, currentButton , currentArray, addMessage)
                }
            }
        default:
            if Path.initialIndexPath != nil {
                let cell = uiTableView.cellForRow(at: Path.initialIndexPath!) as UITableViewCell?
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell?.isHidden = false
                    cell?.alpha = 0.0
                }
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = (cell?.center)!
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    cell?.alpha = 1.0
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
        }
        
    }
    
    func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

    //取得行程好友
    func getFriends(_ tripID:Int) {
        let url_trip = URL(string: common_url + "TripServlet")
        var requesrParam = [String: Any]()
        requesrParam["action"] = "getTripFriends"
        requesrParam["tripId"] = tripID
        
        executeTask(url_trip!, requesrParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
//                    print("input1: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([String].self, from: data!) {
                        self.receiver = try! String(data: JSONEncoder().encode(result), encoding: .utf8)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    //天數增減
    func dayUpdate(_ tripID:Int, _ day:Int, _ addMessage:ScheduleDay) {
        var requestParam = [String: Any]()
        let url_server = URL(string: common_url + "TripServlet")
        requestParam["action"] = "dayUpdate"
        requestParam["tripId"] = tripID
        requestParam["day"] = day
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = String(data: data!, encoding: .utf8) {
                        if let count = Int(result) {
                            if count != 0 {
                                //socket
                                if let jsonData = try? JSONEncoder().encode(addMessage) {
                                    let text = String(data: jsonData, encoding: .utf8)
                                    self.socket.write(string: text!)
                                }
                                DispatchQueue.main.async {
                                    self.viewWillAppear(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //天數增減(刪表格)
    func dayLandMarkDelete(_ tripID:Int, _ day:Int) {
        var requestParam = [String: Any]()
        let url_server = URL(string: common_url + "LocationServlet")
        requestParam["action"] = "dayLandMarkDelete"
        requestParam["tripId"] = tripID
        requestParam["day"] = day
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = String(data: data!, encoding: .utf8) {
                        if let count = Int(result) {
                            if count != 0 {
                                DispatchQueue.main.async {
                                    self.uiTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //顯示行程地標
    func changeDataLandMark(_ tripID:Int, _ day:Int) {
        var requestParam = [String: Any]()
        let url_server = URL(string: common_url + "LocationServlet")
        requestParam["action"] = "findLandMarkInSchedulePlanDay"
        requestParam["SchedulePlanDayTripId"] = tripID
        requestParam["SchedulePlanDay"] = day
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([LandMark].self, from: data!) {
                        self.currentArray = result
                        DispatchQueue.main.async {
                            self.activityIndicatorView.stopAnimating()
                            self.uiTableView.reloadData()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.uiTableView.reloadData()
                    }
                }
            }
        }
    }
    
    //取得地標圖片
    func findImage(_ landMarkID:Int, _ cell:PlanTableViewCell) {
        let url_server = URL(string: common_url + "LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["id"] = landMarkID
        requestParam["imageSize"] = 1024
        var image: UIImage?
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "album.png")
                }
                DispatchQueue.main.async {
                    cell.planLocationImage.image = image
                    cell.planLocationImage.layer.cornerRadius = 34.25
                }
            } else {
                //                print(error!.localizedDescription)
            }
        }
    }
    
    //刪除地標行程地標
    func deletOneLandMark(_ action:String, _ tripID:Int, _ day:Int, _ landMarks:[LandMark], _ addMessage:ScheduleDay) {
        var requestParam = [String: Any]()
        let url_server = URL(string: common_url + "LocationServlet")
        requestParam["action"] = action
        requestParam["SchedulePlanDayTripId"] = tripID
        requestParam["SchedulePlanDay"] = day
        requestParam["SchedulePlanDayLandMark"] = try! String(data: JSONEncoder().encode(landMarks), encoding: .utf8)
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = String(data: data!, encoding: .utf8) {
                        if let count = Int(result) {
                            if count != 0 {
                                //socket
                                if let jsonData = try? JSONEncoder().encode(addMessage) {
                                    let text = String(data: jsonData, encoding: .utf8)
                                    self.socket.write(string: text!)
                                }
                                DispatchQueue.main.async {
                                    self.uiTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //地標加入行程
    func addLandMarktoLocation (_ action:String, _ tripID:Int, _ day:Int, _ landMarkID:Int, _ addMessage:ScheduleDay) {
        var requestParam = [String: Any]()
        let url_server = URL(string: common_url + "LocationServlet")
        requestParam["action"] = action
        requestParam["SchedulePlanDayTripId"] = tripID
        requestParam["SchedulePlanDay"] = day
        requestParam["SchedulePlanDayLandMark"] = landMarkID
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    // print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = String(data: data!, encoding: .utf8) {
                        if let count = Int(result) {
                            if count != 0 {
                                //socket
                                if let jsonData = try? JSONEncoder().encode(addMessage) {
                                    let text = String(data: jsonData, encoding: .utf8)
                                    self.socket.write(string: text!)
                                }
                                DispatchQueue.main.async {
                                    self.uiTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Unwind segue
    @IBAction func resultToLocation(segue: UIStoryboardSegue) {
        
       
    }
    
    @objc func locationUpdated(noti:Notification) {
        let resultlandMark = noti.userInfo!["Planlocation"] as? LandMark
        let getnumber = noti.userInfo!["getCurrentButton"] as? Int
        currentArray.append(resultlandMark!)

        print("fin \(getnumber)")
        // message
        let location = try! String(data: JSONEncoder().encode(currentArray), encoding: .utf8)
        let addMessage = ScheduleDay("ScheduleDayRecycle", currentButton, "judgmentDay", user.account, receiver!, 1, tripID!, location!)
        
        addLandMarktoLocation("insertLandMarkInSchedulePlanDay", tripID!, getnumber!, resultlandMark!.id!,addMessage)
        DispatchQueue.main.async {
            self.uiTableView.reloadData()
        }
    }
    
    // 也可使用closure偵測WebSocket狀態
    func addSocketCallBacks() {
        
        socket.onText = { (text: String) in
            if let stateMessage = try? JSONDecoder().decode(ScheduleDay.self, from: text.data(using: .utf8)!) {
                let dayType = stateMessage.messageType
                let scheduleDay = stateMessage.numberOfDay
//                let tripId = stateMessage.tripId
                let tabCount =  stateMessage.tabCount
                let result = stateMessage.landMarkList
                
                switch dayType {
                
                case "updateMap" :
                    
                    break
                
                case "dayChangeAdd" :
                    self.numberOfButtons = tabCount
                    DispatchQueue.main.async {
                        self.viewWillAppear(true)
                        self.uiTableView.reloadData()
                    }
                    break
                    
                case "dayChangeLess" :
                    self.numberOfButtons = tabCount
                    DispatchQueue.main.async {
                        self.viewWillAppear(true)
                        self.uiTableView.reloadData()
                    }
                    break
                    
                case "judgmentDay" :
                    if self.currentButton == scheduleDay{
                        if result != nil {
                            let data = result!.data(using: .utf8)!
                            let resultlocations = try? JSONDecoder().decode([LandMark].self, from: data)
                            self.currentArray = resultlocations!
                            DispatchQueue.main.async {
                                self.viewWillAppear(true)
                                self.uiTableView.reloadData()
                            }
                        }
                    }
                    break
                default:
                    break
                }
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParent{
            if socket.isConnected{
                socket.disconnect()
            }
        }
    }
}
