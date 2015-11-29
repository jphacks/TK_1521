//
//  afterBeaconViewController.swift
//  jphack3
//
//  Created by Shoma Saito on 2015/11/29.
//  Copyright © 2015年 eyes,japan. All rights reserved.
//

import UIKit
import Alamofire

class afterBeaconViewController: UIViewController {
    
    @IBOutlet weak var cellView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cellView.userInteractionEnabled = true
        cellView.tag = 120
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if(touch!.view!.tag == 120){
            let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("beaconView")
            presentViewController(next, animated: false, completion: nil)
        }
    }
    
    
    @IBAction func moveToprofile(sender: AnyObject) {
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("profileView")
        presentViewController(next, animated: false, completion: nil)
    }
    
    @IBAction func moveTomap(sender: AnyObject) {
        let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("MapView")
        presentViewController(next, animated: false, completion: nil)
    }
    
    
}