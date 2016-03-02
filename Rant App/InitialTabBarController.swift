//
//  InitialTabBarController.swift
//  Rant App
//
//  Created by block7 on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class InitialTabBarController: UITabBarController {

}

//
//  BackendlessTabBarController.swift
//  Backendless Test
//
//  Created by block7 on 2/9/16.
//  Copyright © 2016 block7. All rights reserved.
//

import UIKit

class BackendlessTabBarController: UITabBarController {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let identification = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    var backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        userRegistrationOrLogin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerUser() {
        
        Types.tryblock({ () -> Void in
            let backendless = Backendless.sharedInstance()
            let user: BackendlessUser = BackendlessUser()
            user.setProperty("id", object: self.identification)
            user.password = "password"
            
            var registeredUser = self.backendless.userService.registering(user)
            print("User has been registered (SYNC): \(registeredUser)")
            self.defaults.setInteger(0, forKey: "registered")
            }) { (exception) -> Void in
                print("Server reported an error: \(exception as! Fault)")
                self.defaults.setInteger(1, forKey: "registered")
        }
    }
    
    func registerUserAsync(){
        
        let user: BackendlessUser = BackendlessUser()
        user.setProperty("id", object: self.identification)
        user.password = "password"
        
        backendless.userService.registering(user,
            response: { (var registeredUser : BackendlessUser!) -> () in
                print("User has been registered (ASYNC): \(registeredUser)")
            },
            error: { (var fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )
    }
    
    func loginUser() {
        Types.tryblock({ () -> Void in
            let registeredUser = self.backendless.userService.login(self.identification, password: "password")
            print("User has been logged in (SYNC): \(registeredUser)")
            }) { (exception) -> Void in
                print("Server reported an error: \(exception as! Fault)")
        }
    }
    
    func loginUserAsync() {
        
        backendless.userService.login(
            identification, password:"password",
            response: { (var registeredUser : BackendlessUser!) -> () in
                print("User has been logged in (ASYNC): \(registeredUser)")
            },
            error: { (var fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )
    }
    
    func userRegistrationOrLogin(){
        registerUser()
        registerUserAsync()
        let key = defaults.stringForKey("registered")
        if key! == String(1){
            loginUser()
            loginUserAsync()
            print("logged in")
        }
        else{
            print("registered")
        }
        
    }
    
}
