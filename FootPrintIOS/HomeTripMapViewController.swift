//
//  HomeTripMapViewController.swift
//  FootPrintIOS
//
//  Created by Molder on 2019/4/13.
//  Copyright © 2019 lulu. All rights reserved.
//

import UIKit
import MapKit

class HomeTripMapViewController: UIViewController {
    var tripMap: Trip!
    var name:String?
    var lat:Double?
    var long:Double?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var spView: UIView!
    
    @IBOutlet weak var boConView: UIView!
    
    
    @IBOutlet weak var spViewCenterConstraint: NSLayoutConstraint!
    
    
    var startingConstant: CGFloat  = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("trip \(String(describing: tripMap.title))")
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan(recognizer:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        spView.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
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
    
    func presentAnnotation(){
        let lattitude = lat
        let longitude = long
        let annotation = MKPointAnnotation()
        annotation.title = name
        annotation.coordinate = CLLocationCoordinate2DMake(lattitude!, longitude!)
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    //Unwind segue
    @IBAction func homeUnwindsegueMapController(segue: UIStoryboardSegue) {
        if let controller = segue.source as? HomeTripDetailViewController,let data = controller.placeSelected{
            name = data.name
            lat = data.latitude
            long = data.longitude
        }
        presentAnnotation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            let detailVC = segue.destination as! HomeTripDetailViewController
            detailVC.homeTripForDetail = tripMap
        
    }
}
