//
//  profileViewController.swift
//  jphack3
//
//  Created by Shoma Saito on 2015/11/29.
//  Copyright © 2015年 eyes,japan. All rights reserved.
//

import UIKit
import Alamofire

class profileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    @IBAction func moveToMapView(sender: AnyObject) {
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("MapView")
        presentViewController(next, animated: false, completion: nil)
    }

    @IBAction func moveTobeaconView(sender: AnyObject) {
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("afterbeacon")
        presentViewController(next, animated: false, completion: nil)
    }
    

}