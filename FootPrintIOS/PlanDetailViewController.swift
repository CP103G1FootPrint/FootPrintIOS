//
//  PlanDetailViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/12.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit

class PlanDetailViewController: UIViewController,UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var uiTableView: UITableView!
    
    var currentArray = [LandMark]()
    var locationsArray = [LandMark]()
    var friendList  = [String]()
    var numberOfButtons :Int?
    var tripID :Int?
    var tripForDetail: Trip!
    var placeSelected: LandMark?
    var result : LandMark?
    var currentButton: Int?
    
    @IBOutlet weak var mScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setdata()
        print("detail \(String(describing: tripForDetail.days))")
        print("detail \(String(describing: tripForDetail.title))")
        
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureRecognized(_:)))
        uiTableView.addGestureRecognizer(longpress)
        
        let notificationName = Notification.Name("Planlocation")
        NotificationCenter.default.addObserver(self, selector: #selector(songUpdated(noti:)), name: notificationName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dynamicButtonCreation()
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
                Button.backgroundColor = UIColor(red: 155.0/255.0, green: 245.0/255.0, blue: 207.0/255.0, alpha: 1.0)
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
    }
    
    @IBAction func addDay(_ sender: Any) {
        numberOfButtons = numberOfButtons! + 1
        dayUpdate(self.tripID!, self.numberOfButtons!)
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
                self.dayUpdate(self.tripID!, self.numberOfButtons!)
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
    //送回地圖
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath  = uiTableView.indexPathForSelectedRow{
            placeSelected = currentArray[indexPath.row]
        }
    }
    //cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //增加地標按鍵的框
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        let Button = UIButton()
        Button.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50)
        Button.backgroundColor = UIColor(red: 155.0/255.0, green: 245.0/255.0, blue: 207.0/255.0, alpha: 1.0)
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

        navigationController!.pushViewController(detailVC, animated: true)
    }

    //delet action
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        currentArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        deletOneLandMark("changePositionLandMarkInSchedulePlanDay", tripID!, numberOfButtons! - 1 , currentArray)
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
        changeDataLandMark(tripID!,0)
    }
    
    //move
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
                    deletOneLandMark("changePositionLandMarkInSchedulePlanDay", tripID!, numberOfButtons! - 1 , currentArray)
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

    //天數增減
    func dayUpdate(_ tripID:Int, _ day:Int) {
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
                            self.uiTableView.reloadData()
                        }
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
    func deletOneLandMark(_ action:String, _ tripID:Int, _ day:Int, _ landMarks:[LandMark]) {
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
                    if let result = try? JSONDecoder().decode([LandMark].self, from: data!) {
                        self.currentArray = result
                        DispatchQueue.main.async {
                            self.uiTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    //地標加入行程
    func addLandMarktoLocation (_ action:String, _ tripID:Int, _ day:Int, _ landMarkID:Int) {
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
    
    @objc func songUpdated(noti:Notification) {
        result = noti.userInfo!["Planlocation"] as? LandMark
        currentArray.append(result!)
//        print("resulr \(result?.name)")
//        print("day \(currentButton)")
        if currentButton == nil {
            currentButton = 0
        }
        addLandMarktoLocation("insertLandMarkInSchedulePlanDay", tripID!, currentButton!, result!.id!)
        DispatchQueue.main.async {
            self.uiTableView.reloadData()
        }
    }
}
