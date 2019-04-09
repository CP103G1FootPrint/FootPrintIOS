//
//  MapViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/3/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var appleMapView: MKMapView!
    let locationManager = CLLocationManager()
    var landMarkList : [LandMark]!
    var allLocation = [LandMark]()
    var annotationList: [MKAnnotation]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        //地圖監聽器
        appleMapView.delegate = self
        //找所有地標
        findAllLocationInfo()
        //地圖設定
        setMapRegion()
        //顯示自己位置 或storyboard的MKMapview裡面去勾選user location
        appleMapView.showsUserLocation = true
    }
    
    //地圖設定
    func setMapRegion() {
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        var region = MKCoordinateRegion()
        region.span = span
        appleMapView.setRegion(region, animated: true)
        appleMapView.regionThatFits(region)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //如果沒有顯示最新位置在地圖上
        if !mapView.isUserLocationVisible {
            //顯示在地圖上
            mapView.setCenter(userLocation.coordinate, animated: true)
        }
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
        annotationView?.image = UIImage(named: "pin_drop")
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
        /* 設定disclosure按鈕與事件處理 */
        detailButton.addTarget(self, action: #selector(clickDetail(_:)), for: .touchUpInside)
        annotationView!.rightCalloutAccessoryView = detailButton
        
        return annotationView
    }
    
    @objc func clickDetail(_ button: UIButton) {
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "LandMarkDetailViewController") as! LandMarkDetailViewController

        let index = button.tag
        let spot = allLocation[index]
        detailVC.location = spot
//        /* storyboard加上UINavigationController */
        navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func getAnnotationList(landMarkList: [LandMark]) -> [MKAnnotation] {
        var annotationList = [MKAnnotation]()
        for landMark in landMarkList {
            let annotation = MKPointAnnotation()
            annotation.title = landMark.name
            annotation.subtitle = landMark.description
            annotation.coordinate.latitude = landMark.latitude!
            annotation.coordinate.longitude = landMark.longitude!
            annotationList.append(annotation)
        }
        return annotationList
    }

    //取得所有地標
    func findAllLocationInfo() {
        let url_server = URL(string: common_url + "/LocationServlet")
        var requestParam = [String: Any]()
        requestParam["action"] = "AllwithStar"
        executeTask(url_server!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    // 將輸入資料列印出來除錯用
                    //print("input: \(String(data: data!, encoding: .utf8)!)")
                    if let result = try? JSONDecoder().decode([LandMark].self, from: data!) {
                        self.allLocation = result
                        self.annotationList = self.getAnnotationList(landMarkList: self.allLocation)
                        //加到地圖
                        self.appleMapView.addAnnotations(self.annotationList)
                    }
                }
            } else {
                //print(error!.localizedDescription)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
