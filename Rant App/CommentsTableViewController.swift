//
//  CommentsTableViewController.swift
//  Rant App
//
//  Created by Aaron Epstein on 3/2/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    
    ///ADD ADD COMMENT FUNCTIONALITY
    
    var postid: String!
    
    let backendless = Backendless.sharedInstance()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var id = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    var commentsArray: [String] = []
    var likesArray: [String] = []
    var timeArray: [String] = []
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentsTableViewCell", forIndexPath: indexPath) as! CommentsTableViewCell
        let commentText = commentsArray[indexPath.row]
        let commentTime = timeArray[indexPath.row]
        let commentLikes = likesArray[indexPath.row]
        cell.commentLabel.text = commentText
        cell.likesLabel.text = commentLikes
        cell.timeLabel.text = commentTime
        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        self.navigationItem.setHidesBackButton(false, animated: true)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    
    func loadData(){
        let whereClause = "postid = '\(postid)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        let comments = self.backendless.persistenceService.of(Comments.ofClass()).find(dataQuery)
        let currentPage = comments.getCurrentPage()
        for comment in currentPage as! [Comments]{
            let comText = comment.comment!
            let comTime = String(comment.created)
            let comLikes = comment.likes!
            commentsArray.append(comText)
            timeArray.append(comTime)
            likesArray.append(comLikes)
        }
        
        
    }
}
