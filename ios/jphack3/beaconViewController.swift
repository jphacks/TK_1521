//
//  beaconViewController.swift
//  jphack3
//
//  Created by Shoma Saito on 2015/11/29.
//  Copyright © 2015年 eyes,japan. All rights reserved.
//

import UIKit
import CoreLocation
import Social

class beaconViewController: UIViewController, CLLocationManagerDelegate {
    
    var cLLocationManager:CLLocationManager?
    var uuid:NSUUID?
    var cLBeaconRegion:CLBeaconRegion?
    var cLBeacon:CLBeacon?
    var str:NSString?
    var myLocationManager:CLLocationManager!
    
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var twitterImage: UIImageView!
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
        facebookImage.userInteractionEnabled = true
        facebookImage.tag = 110
        
        twitterImage.userInteractionEnabled = true
        twitterImage.tag = 111
        
        if(CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)) {
            cLLocationManager = CLLocationManager()
            cLLocationManager?.delegate = self
            
            uuid = NSUUID(UUIDString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")
            cLBeaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "Swift iBeacon")
            cLBeaconRegion?.notifyOnEntry = true
            cLBeaconRegion?.notifyOnExit = true
            cLBeaconRegion?.notifyEntryStateOnDisplay = false
            
            if((cLLocationManager?.respondsToSelector("requestAlwaysAuthorization")) != nil) {
               // cLLocationManager?.requestAlwaysAuthorization()
            }
            else {
                //cLLocationManager?.startMonitoringForRegion(cLBeaconRegion!)
            }
        }
        else {
            log("iBeaconは使えません")
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if(touch!.view!.tag == 110){
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                // make controller to share on twitter
                let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                // add link to the controller
                let link: String = "http://www.apple.com"
                let url = NSURL(string: link)
               // controller.addURL(url)
                
                // add text to the controller
                let title: String = "ﾟ(ﾟ´ω`ﾟ)ﾟ｡ﾋﾟｰ"
                controller.setInitialText(title)
                
                // show twitter post screen
                presentViewController(controller, animated: true, completion: {})
            }
        }else if(touch!.view!.tag == 111){
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                // make controller to share on twitter
                let controller = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                // add link to the controller
                let link: String = "http://www.apple.com"
                let url = NSURL(string: link)
               // controller.addURL(url)
                
                // add text to the controller
                let title: String = "ﾟ(ﾟ´ω`ﾟ)ﾟ｡ﾋﾟｰ"
                controller.setInitialText(title)
                
                // show twitter post screen
                presentViewController(controller, animated: true, completion: {})
            }
        }
    
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        log("didStartMonitoringForRegion")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log("didEnterRegion")
        //cLLocationManager?.startRangingBeaconsInRegion(cLBeaconRegion!)
    }
    
    func locationManager(manager: CLLocationManager,didExitRegion region: CLRegion){
        log("didExitRegion")
        //cLLocationManager?.stopRangingBeaconsInRegion(cLBeaconRegion!)
    }
    
    
    //    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        log("didRangeBeacons")
        if(beacons.count > 0) {
            let nearestCLBeacon:CLBeacon = beacons.first!
            
            log("UUID:\(nearestCLBeacon.proximityUUID.UUIDString)\nMajor:\(nearestCLBeacon.major)\nMinor:\(nearestCLBeacon.minor)")
            
            let cLProximity:CLProximity! = nearestCLBeacon.proximity
            var rangeMessage:String = ""
            
            if(cLProximity == CLProximity.Immediate) {
                rangeMessage = "Immediate"
            }
            else if(cLProximity == CLProximity.Near) {
                rangeMessage = "Near"
            }
            else if(cLProximity == CLProximity.Far) {
                rangeMessage = "Far"
            }
            else if(cLProximity == CLProximity.Unknown) {
                rangeMessage = "Unknown"
            }
            log(rangeMessage)
        }
    }
    
    
    
    @IBAction func moveToMapView(sender: AnyObject) {
        //cLLocationManager?.stopRangingBeaconsInRegion(cLBeaconRegion!)
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("MapView")
        presentViewController(next, animated: false, completion: nil)
    }
    
    
    @IBAction func moveToProfileView(sender: AnyObject) {
        //cLLocationManager?.stopRangingBeaconsInRegion(cLBeaconRegion!)
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("profileView")
        presentViewController(next, animated: false, completion: nil)
    }
    
    @IBAction func moveafter(sender: AnyObject) {
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("afterbeacon")
        presentViewController(next, animated: false, completion: nil)
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func log(output:String) {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        print("\(dateFormatter.stringFromDate(now)) \(output)")
    }
    
}