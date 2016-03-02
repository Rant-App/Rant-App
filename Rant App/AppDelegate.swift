//
//  AppDelegate.swift
//  Rant App
//
//  Created by block7 on 2/29/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let APP_ID = "B5E3E615-2F73-EC0E-FFAB-9C3646FAA700"
    let SECRET_KEY = "1EAB5EE9-6CA8-3275-FFD8-B9ACD243D400"
    let VERSION_NUM = "v1"
    
    var backendless = Backendless.sharedInstance()
    
    let identification = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        logoutUserSync()
        logoutUserAsync()
    }
    func logoutUserAsync() {
        
        backendless.userService.login(
            identification, password:"password",
            response: { ( user : BackendlessUser!) -> () in
                print("User has been logged in (ASYNC): \(user)")
                
                self.backendless.userService.logout(
                    { ( user : AnyObject!) -> () in
                        print("Current user session expired.")
                    },
                    error: { ( fault : Fault!) -> () in
                        print("Server reported an error: \(fault)")
                    }
                )
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
            }
        )
    }
    func logoutUserSync() {
        
        Types.tryblock({ () -> Void in
            
            let user = self.backendless.userService.login(self.identification, password: "password")
            print("User has been logged in (SYNC): \(user)")
            self.backendless.userService.logout()
            print("Current user session expired.")
            },
            
            catchblock: { (exception) -> Void in
                print("Server reported an error: \(exception as! Fault)")
            }
        )
    }



}

