//
//  PlanViewController.swift
//  FootPrintIOS
//
//  Created by lulu on 2019/4/7.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import MapKit

class PlanViewController: UIViewController,MKMapViewDelegate {
    var trip: Trip!

    var annotationList = [MKAnnotation]()
    let locationManager = CLLocationManager()
    var geodesicPolyline:MKGeodesicPolyline?
    var testcoords:[CLLocationCoordinate2D] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var spView: UIView!
    @IBOutlet weak var boConView: UIView!
    @IBOutlet weak var spViewCenterConstraint: NSLayoutConstraint!
    
    var startingConstant: CGFloat  = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        //地圖監聽器
        mapView.delegate = self
        //地圖設定
        setMapRegion()
        //init
        changeDataLandMark(trip.tripID!, 0)
        
//        print("trip \(String(describing: trip.title))")
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan(recognizer:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        spView.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
        
        let notificationName = Notification.Name("ScheduleTripMapChange")
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleLocationMapUpdated(noti:)), name: notificationName, object: nil)
    }
    
    @objc func detectPan(recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            self.startingConstant = self.spViewCenterConstraint.constant
        case .changed:
            let translation = recognizer.translation(in: self.view)
//            print("result view size \(self.startingConstant + translation.y)")
            if self.startingConstant + translation.y > 250 {
                self.spViewCenterConstraint.constant = 250
            } else if self.startingConstant + translation.y < -240 {
                self.spViewCenterConstraint.constant = -240
            } else {
                self.spViewCenterConstraint.constant = self.startingConstant + translation.y
            }
        default:
            break
        }
        
    }
    
    @objc func scheduleLocationMapUpdated(noti:Notification) {
        let getTripID = noti.userInfo!["TripID"] as? Int
        let getDay = noti.userInfo!["Day"] as? Int
        changeDataLandMark(getTripID!, getDay!)
    }
    
    //Unwind segue
    @IBAction func unwindsegueMapController(segue: UIStoryboardSegue) {
        if let controller = segue.source as? PlanDetailViewController {
            let data = controller.placeSelecteds
            let index = controller.placeSelected
            mapLine(data!, index!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("\(self) \(#function)" )
        if segue.identifier == "planDetailViewController" {
            /* indexPath(for:)可以取得UITableViewCell的indexPath */
            let detailVC = segue.destination as! PlanDetailViewController
            detailVC.tripForDetail = trip
        }
    }
    
    func getAnnotationList(landMarkList: [LandMark]) -> [MKAnnotation] {
        var annotationList = [MKAnnotation]()
        for landMark in landMarkList {
            let annotation = MKPointAnnotation()
            annotation.title = landMark.name
            annotation.subtitle = landMark.type
            annotation.coordinate.latitude = landMark.latitude!
            annotation.coordinate.longitude = landMark.longitude!
            annotationList.append(annotation)
        }
        return annotationList
    }
    
    //地圖設定
    func setMapRegion() {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        var region = MKCoordinateRegion()
        region.span = span
        mapView.setRegion(region, animated: true)
        mapView.regionThatFits(region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        /* user location已經有預設圖示無需給予新的圖示 */
        if annotation is MKUserLocation {
            return nil
        }
        /* 指定identifier以重複利用annotation view */
        let identifier = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.canShowCallout = true
        //圖針樣式
        if annotation.subtitle == "Recommended by Tourist" {
            annotationView?.image = UIImage(named: "footprintpin")
        }else if annotation.subtitle == "Restaurant" {
            annotationView?.image = UIImage(named: "restaurantpin")
        }else if annotation.subtitle == "Hotel" {
            annotationView?.image = UIImage(named: "hotelpin")
        }else{
            annotationView?.image = UIImage(named: "placeholder")
        }
        /* 預設圖示中心點會在地點上，應改成圖示底部對齊地點，負值代表向上移動 */
        let height = annotationView?.frame.height
        annotationView?.centerOffset = CGPoint(x: 0, y: -(height!) / 2)
        
        //建立window view
        let detailButton = UIButton(type: .detailDisclosure)
        //針對window view 加上tag 編號,這樣就知道使用者點了哪個圖標
        for i in 0...annotationList.count {
            // === 比位置  == 比值
            if annotationList[i] === annotation {
                /* 透過tag儲存annotation在array的index */
                detailButton.tag = i
                break
            }
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
        renderer.alpha = 0.5
        renderer.strokeColor = UIColor.blue
        return renderer
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
                        self.mapLine(result, 0)
                    }
                }
            }
        }
    }
    
    func mapLine( _ data:[LandMark], _ index:Int) {
        if data.count != 0 {
            //從地圖上移除所有 array 裡面的圖標
            mapView.removeAnnotations(annotationList)
            annotationList.removeAll()
            if testcoords.count != 0 {
                mapView.removeOverlay(geodesicPolyline!)
                testcoords.removeAll()
            }
            
            //重新載入
            annotationList = getAnnotationList(landMarkList: data)
            for index in 0...(annotationList.count - 1) {
                let annotation = annotationList[index]
                let latLng = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                testcoords.append(latLng)
            }
            geodesicPolyline = MKGeodesicPolyline(coordinates: testcoords, count: testcoords.count)
            mapView.addOverlay(geodesicPolyline!)
            mapView.addAnnotations(annotationList)
            //移動到畫面正中央取第一筆
            let firstLocation = annotationList[index]
            mapView.setCenter(firstLocation.coordinate, animated: true)
        }
    }
}
