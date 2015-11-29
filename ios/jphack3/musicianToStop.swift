//
//  musicianToStop.swift
//  jphack3
//
//  Created by Shoma Saito on 2015/11/29.
//  Copyright © 2015年 eyes,japan. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import CoreBluetooth

class musicianToStop: UIViewController, CBPeripheralManagerDelegate {
    
    var myPheripheralManager:CBPeripheralManager!
    
    @IBOutlet weak var stop: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        stop.userInteractionEnabled = true
        stop.tag = 201
        myPheripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
 
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if(touch!.view!.tag == 201){
            moveToMapView()
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        // iBeaconのUUID.
        let myProximityUUID = NSUUID(UUIDString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")
        
        // iBeaconのIdentifier.
        let myIdentifier = "akabeacon"
        
        // Major.
        let myMajor : CLBeaconMajorValue = 0
        
        // Minor.
        let myMinor : CLBeaconMinorValue = 0
        
        // BeaconRegionを定義.
        let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID!, major: myMajor, minor: myMinor, identifier: myIdentifier)
        
        // Advertisingのフォーマットを作成.
        let myBeaconPeripheralData = NSDictionary(dictionary: myBeaconRegion.peripheralDataWithMeasuredPower(nil))
        
        
        // Advertisingを発信.
        myPheripheralManager.startAdvertising(myBeaconPeripheralData as? [String : AnyObject])
    }
    
    func moveToMapView(){
        myPheripheralManager.stopAdvertising()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
}