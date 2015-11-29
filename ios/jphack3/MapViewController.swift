//
//  MapViewController.swift
//  jphack3
//
//  Created by Shoma Saito on 2015/11/29.
//  Copyright © 2015年 eyes,japan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var playerView: UIView!
    
    var cLLocationManager:CLLocationManager?
    var uuid:NSUUID?
    var cLBeaconRegion:CLBeaconRegion?
    var cLBeacon:CLBeacon?
    var str:NSString?
    var myLocationManager:CLLocationManager!
    
    var isFirst = true
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func moveTobeaconView(sender: AnyObject) {
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("afterbeacon")
        presentViewController(next, animated: false, completion: nil)
    }
    
    @IBAction func moveToProfileView(sender: AnyObject) {
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("profileView")
        presentViewController(next, animated: false, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        playerView.userInteractionEnabled = true
        playerView.tag = 121
        
        
        // 緯度・軽度を設定
        let location:CLLocationCoordinate2D
        = CLLocationCoordinate2DMake(35.68154,139.752498)
        
        mapView.setCenterCoordinate(location,animated:true)
        
        mapView.delegate = self
        
        // 縮尺を設定
        var region:MKCoordinateRegion = mapView.region
        region.center = location
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        
        mapView.setRegion(region,animated:true)
        
        // 表示タイプを航空写真と地図のハイブリッドに設定
        mapView.mapType = MKMapType.Standard
        
        myLocationManager = CLLocationManager()
        
        // デリゲートを自身に設定.
        myLocationManager.delegate = self
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 取得頻度の設定.(1mごとに位置情報取得)
        myLocationManager.distanceFilter = 1
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status != CLAuthorizationStatus.AuthorizedAlways) {
            print("CLAuthorizedStatus \(status)");
            
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            myLocationManager.requestAlwaysAuthorization()
        }
        
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定.
        myLocationManager.distanceFilter = 1
        
        myLocationManager.startUpdatingLocation()
        
        // ピンを生成.
        let myPin: MKPointAnnotation = MKPointAnnotation()
        
        let myLatitude: CLLocationDegrees = 35.715282+0.000009
        let myLongitude: CLLocationDegrees = 139.758878+0.000001
        
        // 座標を設定.
        myPin.coordinate = CLLocationCoordinate2DMake(myLatitude, myLongitude)
        
        // MapViewにピンを追加.
        mapView.addAnnotation(myPin)
        
        
        if(CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)) {
            cLLocationManager = CLLocationManager()
            cLLocationManager?.delegate = self
            
            uuid = NSUUID(UUIDString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")
            cLBeaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "Swift iBeacon")
            cLBeaconRegion?.notifyOnEntry = true
            cLBeaconRegion?.notifyOnExit = true
            cLBeaconRegion?.notifyEntryStateOnDisplay = false
            
            if((cLLocationManager?.respondsToSelector("requestAlwaysAuthorization")) != nil) {
                cLLocationManager?.requestAlwaysAuthorization()
            }
            else {
                cLLocationManager?.startMonitoringForRegion(cLBeaconRegion!)
            }
        }
        else {
            log("iBeaconは使えません")
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        log("didStartMonitoringForRegion")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log("didEnterRegion")
        cLLocationManager?.startRangingBeaconsInRegion(cLBeaconRegion!)
    }
    
    func locationManager(manager: CLLocationManager,didExitRegion region: CLRegion){
        log("didExitRegion")
        cLLocationManager?.stopRangingBeaconsInRegion(cLBeaconRegion!)
    }
    
    
    //    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        log("didRangeBeacons")
        if(beacons.count > 0) {
            let nearestCLBeacon:CLBeacon = beacons.first!
            
            log("UUID:\(nearestCLBeacon.proximityUUID.UUIDString)\nMajor:\(nearestCLBeacon.major)\nMinor:\(nearestCLBeacon.minor)")
            
            let cLProximity:CLProximity! = nearestCLBeacon.proximity
            var rangeMessage:String = ""
            
            if(cLProximity == CLProximity.Unknown) {
                rangeMessage = "Unknown"
                if !isFirst {
                    playerView.frame.origin.y = playerView.frame.origin.y+150
                    isFirst = true
                }
            }else if(cLProximity == CLProximity.Far) {
                rangeMessage = "Far"
            }else{
                rangeMessage = "near or immmidiate"
                if isFirst {
                    playerView.frame.origin.y = playerView.frame.origin.y-150
                    isFirst = false
                }
            }
            log(rangeMessage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // ピンをタップしたら呼ばれる
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("tapped")
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 緯度・経度の表示.
        print("緯度：\(manager.location!.coordinate.latitude)")
        
        print("経度：\(manager.location!.coordinate.longitude)")
        
        let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(manager.location!.coordinate.latitude, manager.location!.coordinate.longitude) as CLLocationCoordinate2D
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
        
        
        
        // MapViewに反映.
        mapView.setRegion(myRegion, animated: true)
        
        
        
        myLocationManager.stopUpdatingLocation()
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if(touch!.view!.tag == 121){
            let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("beaconView")
            presentViewController(next, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = String(stringInterpolationSegment: annotation.coordinate.longitude)
        
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if pinView == nil {
            
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.image = UIImage(named: "Live_icon.png")!
        }
        
        let button = UIButton(type: UIButtonType.DetailDisclosure)
        pinView?.rightCalloutAccessoryView = button
        
        
        return pinView
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        switch(state) {
        case .Inside:
            log("Inside")
            cLLocationManager?.startRangingBeaconsInRegion(cLBeaconRegion!)
        case .Outside:
            log("Outside")
        case .Unknown:
            log("Unknown")
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        log("didChangeAuthorizationStatus")
        
        var statusStr = "";
        var start = false
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .AuthorizedAlways:
            statusStr = "AuthorizedAlways"
            start = true
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
            start = true
        }
        if(start == true) {
            cLLocationManager?.startMonitoringForRegion(cLBeaconRegion!)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        log("didFailWithError[\(error.description)]")
    }
    
    
    
    func log(output:String) {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        print("\(dateFormatter.stringFromDate(now)) \(output)")
    }
    
}