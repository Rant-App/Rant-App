//
//  ProfileTableViewController.swift
//  Rant App
//
//  Created by block7 on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    let backendless = Backendless.sharedInstance()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var id = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    var myPosts = [PostTableViewCell]()
    
    var postArray: [String] = []
    
    var tagsArray: [[String]] = [[]]
    var numCommentsArray: [[String]] = [[]]
    
    var tagsInCell = ""
    
    var time = ""
    var test: [AnyObject]!
    var count: String = ""
    var numberOfComments: String = ""
    var postid = ""
    var color = "black"
    var uicolor: UIColor!
    
    let red = UIColor.redColor()
    let purple = UIColor.purpleColor()
    let black = UIColor.blackColor()
    let brown = UIColor.brownColor()
    let blue = UIColor.blueColor()
    let green = UIColor.greenColor()
    let yellow = UIColor.yellowColor()
    let orange = UIColor.orangeColor()
    
    var colorArray: [UIColor] = []
    var likesArray: [String] = []
    var postidArray: [String] = []
    var timeArray: [String] = []

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        cell.PostTextLabel.text = "test"
        cell.TimeStampLabel.text = "1"
        cell.PostTextLabel.textColor = UIColor.blackColor()
        cell.TagsLabel.text = "tagtest"
        
        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
    }
}
