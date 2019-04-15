//
//  MapViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/3/8.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var appleMapView: MKMapView!
    var locationManager = CLLocationManager()
    var fromLocation: CLLocation?
    var gpslatitude: Double?
    var gpslongitude: Double?
    var landMarkList : [LandMark]!
    var allLocation = [LandMark]()
    var annotationList: [MKAnnotation]!
    
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        checkLocationServices()
        locationManagers()
//        locationManager.requestWhenInUseAuthorization()
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
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
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
        let goButton = UIButton(type: .detailDisclosure)
        //針對window view 加上tag 編號,這樣就知道使用者點了哪個圖標
        for i in 0...annotationList.count {
            // === 比位置  == 比值
            if annotationList[i] === annotation {
                /* 透過tag儲存annotation在array的index */
                detailButton.tag = i
                goButton.tag = i
                break
            }
        }
        /* 設定disclosure按鈕與事件處理 */
        detailButton.addTarget(self, action: #selector(clickDetail(_:)), for: .touchUpInside)
        annotationView!.rightCalloutAccessoryView = detailButton
        
        //導航
        let image = UIImage(named: "car2")
        goButton.setImage(image, for: .normal)
        goButton.addTarget(self, action: #selector(accessoryBtnPressed(_:)), for: .touchUpInside)
        annotationView!.leftCalloutAccessoryView = goButton
        
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
    
    //按下按鈕後會觸發導航功能
    @objc
    func accessoryBtnPressed(_ button: UIButton){
        let alert = UIAlertController(title: nil, message: "導航前往這個地點?", preferredStyle: .alert)
        //let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let index = button.tag
            let spot = self.allLocation[index]
            self.getDirections(spot)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            //.....
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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

    //取得所有地標
    func findAllLocationInfo() {
        let url_server = URL(string: common_url + "LocationServlet")
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
    
    func locationManagers() {
        //取得問位置管理權限
        locationManager = CLLocationManager()
        //請求user同意時取的位置
        locationManager.requestWhenInUseAuthorization()
        //監聽器
        locationManager.delegate = self
        //精準度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //位置移動多少後再去抓新值 會去呼叫 didUpdateLocations方法
        locationManager.distanceFilter = 10
        //開始更新
        locationManager.startUpdatingLocation()
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
//
//    func setupLocationManager() {
////        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//
//
//    func centerViewOnUserLocation() {
//        if let location = locationManager.location?.coordinate {
//            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//            appleMapView.setRegion(region, animated: true)
//        }
//    }
//
//    func checkLocationServices() {
//        if CLLocationManager.locationServicesEnabled() {
//            setupLocationManager()
//            checkLocationAuthorization()
//        } else {
//            // Show alert letting the user know they have to turn this on.
//        }
//    }
//
//    func checkLocationAuthorization() {
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedWhenInUse:
//            startTackingUserLocation()
//        case .denied:
//            // Show alert instructing them how to turn on permissions
//            break
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//        case .restricted:
//            // Show an alert letting them know what's up
//            break
//        case .authorizedAlways:
//            break
//        }
//    }
//
//    func startTackingUserLocation() {
//        appleMapView.showsUserLocation = true
//        centerViewOnUserLocation()
//        locationManager.startUpdatingLocation()
//        previousLocation = getCenterLocation(for: appleMapView)
//    }
//
//    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
//        let latitude = appleMapView.centerCoordinate.latitude
//        let longitude = appleMapView.centerCoordinate.longitude
//
//        return CLLocation(latitude: latitude, longitude: longitude)
//    }
    
    func getDirections(_ spot:LandMark) {
        guard let location = locationManager.location?.coordinate else {
            //TODO: Inform user we don't have their current location
            return
        }
        
        let request = createDirectionsRequest(from: location,spot)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            //TODO: Handle error if needed
            guard let response = response else { return } //TODO: Show response not available in an alert
            
            for route in response.routes {
                self.appleMapView.addOverlay(route.polyline)
                self.appleMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, _ spot:LandMark) -> MKDirections.Request {
        let target = CLLocationCoordinate2D(latitude: spot.latitude!, longitude: spot.longitude!)
        let destinationCoordinate       = target
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destinationCoordinate)
        
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        request.transportType           = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    
    func resetMapView(withNew directions: MKDirections) {
        appleMapView.removeOverlays(appleMapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        let myLocation = CLLocationCoordinate2D(latitude: self.gpslatitude!, longitude: self.gpslongitude!)
        appleMapView.setCenter(myLocation, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3.0
        renderer.alpha = 0.5
        return renderer
    }
}
