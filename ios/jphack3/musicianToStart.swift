//
//  musicianToStart.swift
//  jphack3
//
//  Created by Shoma Saito on 2015/11/29.
//  Copyright © 2015年 eyes,japan. All rights reserved.
//

import UIKit
import Alamofire

class musicianToStart: UIViewController {

    @IBOutlet weak var startLive: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        startLive.userInteractionEnabled = true
        startLive.tag = 200
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if(touch!.view!.tag == 200){
            moveToMapView()
        }
    }
    
    func moveToMapView(){
        let view: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("musicianStop")
        self.presentViewController(view, animated: false, completion: nil)
    }
    
}