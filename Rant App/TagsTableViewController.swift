//
//  TagsTableViewController.swift
//  Rant App
//
//  Created by block7 on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class TagsTableViewController: UITableViewController {
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagsTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        let num = String(numCommentsArray[indexPath.row].count)
        let textColor = colorArray[indexPath.row]
        let currentTags = tagsArray[indexPath.row]
        
        let tagsString = currentTags.joinWithSeparator(", ")
        
        let currentLikes = likesArray[indexPath.row]
        
        let currentPostid = postidArray[indexPath.row]
        
        cell.PostTextLabel.text = postArray[indexPath.row]
        cell.TimeStampLabel.text = time
        cell.PostTextLabel.textColor = textColor
        cell.TagsLabel.text = tagsString
        cell.ReplyButton.setTitle("\(num) replies", forState: .Normal)
        cell.CountLabel.text = currentLikes
        
        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    func loadData(){
        let whereClause = "id = '\(id)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let posts = self.backendless.persistenceService.of(FavoriteTags.ofClass()).find(dataQuery)
        
        let currentPage = posts.getCurrentPage()
        
        test = posts.data
        
        for tag in currentPage as! [FavoriteTags] {
            
        }

        
    }

}
