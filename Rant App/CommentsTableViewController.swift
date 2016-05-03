//
//  CommentsTableViewController.swift
//  Rant App
//
//  Created by Aaron Epstein on 3/2/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController, UITextViewDelegate {
    
    var postid: String!
    
    let backendless = Backendless.sharedInstance()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var id = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    var commentsArray: [String] = []
    var likesArray: [String] = []
    var timeArray: [String] = []
    
    var commentView: UITextView?
    var footerView: UIView?
    
    var timeSinceDate: Int!
    var StringTimeSinceDate: String!
    
    var postText = ""
    var tagsArray: [String] = []
    var postTimeSinceDate: Int!
    var postStringTimeSinceDate: String!
    var postTime: String!
    var numOfComments: Int!
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
    
    var likes: String!

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            
        }
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
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else{
            return commentsArray.count
        }
    }
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50.0))
        footerView?.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
        commentView = UITextView(frame: CGRect(x: 10, y: 5, width: tableView.bounds.width - 80 , height: 40))
        commentView?.backgroundColor = UIColor.whiteColor()
        commentView?.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        commentView?.layer.cornerRadius = 2
        commentView?.scrollsToTop = true
        
        
        
        footerView?.addSubview(commentView!)
        let button = UIButton(frame: CGRect(x: tableView.bounds.width - 65, y: 10, width: 60 , height: 30))
        button.setTitle("Reply", forState: UIControlState.Normal)
        button.backgroundColor = UIColor(red: 155.0/255, green: 189.0/255, blue: 113.0/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: "commentAction:", forControlEvents: UIControlEvents.TouchUpInside)
        footerView?.addSubview(button)
        commentView?.delegate = self
        return footerView
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.footerView != nil {
            return self.footerView!.bounds.height
        }
        return 50.0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
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
            let df = NSDate()
            let created = comment.created
            let interval = df.timeIntervalSinceDate(created)
            if interval < 60.0 * 60.0{
                timeSinceDate = Int(interval / (60.0))
                StringTimeSinceDate = "\(timeSinceDate) minutes ago"
            }
            else if interval < 24.0 * 60 * 60{
                timeSinceDate = Int(interval / (60.0 * 60.0))
                StringTimeSinceDate = "\(timeSinceDate) hours ago"
            }
            else if interval < 24.0 * 60 * 60 * 30{
                timeSinceDate = Int(interval / (60.0 * 60.0 * 24.0))
                StringTimeSinceDate = "\(timeSinceDate) days ago"
            }
            else{
                timeSinceDate = Int(interval / (60.0 * 60.0 * 24.0 * 30.0))
                StringTimeSinceDate = "\(timeSinceDate) months ago"
            }
            let comTime = StringTimeSinceDate
            let comLikes = comment.likes!
            commentsArray.append(comText)
            timeArray.append(comTime)
            likesArray.append(comLikes)
        }
        
        let wc = "id = '\(postid)'"
        let query = BackendlessDataQuery()
        query.whereClause = wc
        
        let posts = self.backendless.persistenceService.of(Posts.ofClass()).find(query)
        
        let cp = posts.getCurrentPage()
        
        for post in cp as! [Posts]{
            likes = post.likes
            postText = post.post!
            let nscreated = post.created!
            let nsdate = NSDate()
            let inter = nsdate.timeIntervalSinceDate(nscreated)
            if inter < 60.0 * 60.0{
                postTimeSinceDate = Int(inter / 60.0)
                postStringTimeSinceDate = "\(postTimeSinceDate) minutes ago"
            }
            else if inter < 24.0 * 60 * 60{
                postTimeSinceDate = Int(inter / 60.0 * 60.0)
                postStringTimeSinceDate = "\(postTimeSinceDate) hours ago"
            }
            else if inter < 24.0 * 60 * 60 * 30{
                postTimeSinceDate = Int(inter / 60.0 * 60.0 * 24.0)
                postStringTimeSinceDate = "\(postTimeSinceDate) days ago"
            }
            else{
                postTimeSinceDate = Int(inter / 60.0 * 60.0 * 24.0 * 30.0)
                postStringTimeSinceDate = "\(postTimeSinceDate) months ago"
            }
            postTime = postStringTimeSinceDate
            
        }

    }
    
    func commentAction(sender: UIButton!){
        let ct = commentView?.text
        let cl = "0"
        let comments = Comments()
        comments.comment = ct
        comments.likes = cl
        
        
        let dataStore = backendless.data.of(Comments.ofClass())
        
        var error: Fault?
        let result = dataStore.save(comments, fault: &error) as? Comments
        if error == nil {
            print("Post has been saved: \(result!.objectId)")
        }
        else {
            print("Server reported an error: \(error)")
        }
        
        loadData()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()

    }
}
