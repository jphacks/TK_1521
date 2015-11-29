//
//  musician.swift
//  jphack3
//
//  Created by Shoma Saito on 2015/11/29.
//  Copyright © 2015年 eyes,japan. All rights reserved.
//

import UIKit
import Alamofire

class musician: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var isCreate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        NSUserDefaults.standardUserDefaults().setObject("token", forKey: "accesstoken")
        //        NSUserDefaults.standardUserDefaults().setObject("no", forKey: "error")
        
        
        var imageView: UIImageView!
        imageView = UIImageView(frame: CGRectMake(0,0,228,40))
        imageView.image = UIImage(named: "login-1.png")
        imageView.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2+100.0)
        imageView.userInteractionEnabled = true
        imageView.tag = 100
        self.view.addSubview(imageView)
        
        
        var simageView: UIImageView!
        simageView = UIImageView(frame: CGRectMake(0,0,228,40))
        simageView.image = UIImage(named: "SIGNUP.png")
        simageView.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2+180.0)
        simageView.userInteractionEnabled = true
        simageView.tag = 101
        self.view.addSubview(simageView)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if(touch!.view!.tag == 100){
            print(100)
            let params = ["username":"\(emailTextField.text!)","password":"\(passwordTextField.text!)"]
            
            print(params)
            
            var json:JSON!
            
            
            Alamofire.request(.POST, "http://52.10.5.15:8000/v1/user/login", parameters: params, encoding: .JSON).responseJSON { response in
                json = JSON(response.result.value!)
                print(json)
                NSUserDefaults.standardUserDefaults().setObject("\(json["access_token"])", forKey: "accesstoken")
                NSUserDefaults.standardUserDefaults().setObject("\(self.emailTextField.text!)", forKey: "username")
                print(json["access_token"])
                self.moveToMapView()
            }
        }else if(touch!.view!.tag == 101){
            print(101)
            let params = ["loginName":"\(emailTextField.text!)","password":"\(passwordTextField.text!)","major": "0","minor": "1","displayName": "sample","type": "musician"]
            
            Alamofire.request(.POST, "http://52.10.5.15:8000/v1/user/create", parameters: params, encoding: .JSON).responseString { response in
                if(response.result.isSuccess){
                    // 2. login
                    let loginparams = ["username":"\(self.emailTextField.text!)","password":"\(self.passwordTextField.text!)"]
                    Alamofire.request(.POST, "http://52.10.5.15:8000/v1/user/login", parameters: loginparams, encoding: .JSON).responseJSON { response in
                        let json = JSON(response.result.value!)
                        print(json)
                        NSUserDefaults.standardUserDefaults().setObject("\(json["access_token"])", forKey: "accesstoken")
                        NSUserDefaults.standardUserDefaults().setObject("\(self.emailTextField.text!)", forKey: "username")
                        print(json["access_token"])
                        self.moveToMapView()
                    }
                }else{
                    let myAlert: UIAlertController = UIAlertController(title: "エラー:Cannot Create", message: "そのユーザ名とパスワードは既に使われています。", preferredStyle: .Alert)
                    
                    // OKのアクションを作成する.
                    let myOkAction = UIAlertAction(title: "OK", style: .Default) { action in
                        print("Action OK!!")
                    }
                    
                    myAlert.addAction(myOkAction)
                    
                    self.presentViewController(myAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        print("will appear")
        
        let u = NSUserDefaults.standardUserDefaults()
        u.synchronize()
        
        if isCreate {
            if u.objectForKey("accesstoken")! as! String == "token" {
                print("token")
            } else {
                moveToMapView()
            }
        }
    }
    
    
    func moveToMapView(){
        let view: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("musicianStart")
        self.presentViewController(view, animated: false, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}