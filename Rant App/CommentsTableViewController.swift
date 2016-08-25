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
    
    var num = 0
    var n = 0
    
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
    var tagsForPost: String!
    var numberOfComments: String!
    
    var comIDArray: [String] = []

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let postCell = tableView.dequeueReusableCellWithIdentifier("PostComment", forIndexPath: indexPath) as! PostTableViewCell
            postCell.PostTextLabel.text = postText
            postCell.CountLabel.text = likes
            postCell.TimeStampLabel.text = postTime
            postCell.PostTextLabel.textColor = uicolor
            postCell.TagsLabel.text = tagsForPost
            postCell.replyLabel.text = "\(numberOfComments) replies"
            
            let img = postCell.ClapImage
            
            let tap = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
            img.addGestureRecognizer(tap)
            img.userInteractionEnabled = true
            
            return postCell
            
        }
        if commentsArray.count != 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentsTableViewCell", forIndexPath: indexPath) as! CommentsTableViewCell
            let commentText = commentsArray[indexPath.row]
            let commentTime = timeArray[indexPath.row]
            let commentLikes = likesArray[indexPath.row]
            cell.commentLabel.text = commentText
            cell.likesLabel.text = commentLikes
            cell.timeLabel.text = commentTime
            
            let image = cell.clapImage
            
            let tap = UITapGestureRecognizer(target: self, action: Selector("commentTapped:"))
            image.addGestureRecognizer(tap)
            image.userInteractionEnabled = true
            return cell
        }
        let new = tableView.dequeueReusableCellWithIdentifier("CommentsTableViewCell", forIndexPath: indexPath) as! CommentsTableViewCell
        new.commentLabel.text = "\(commentsArray.count) Comments"
        new.likesLabel.text = nil
        new.timeLabel.text = nil
        new.clapImage.hidden = true
        return new
        
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else{
            if commentsArray.count == 0{
                return 1
            } else{
                return commentsArray.count
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        commentsArray.removeAll()
        timeArray.removeAll()
        likesArray.removeAll()
        loadData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func tapped(recognizer: UITapGestureRecognizer){
        let tappedLocation = recognizer.locationInView(self.tableView)
        if let tappedIndexPath = tableView.indexPathForRowAtPoint(tappedLocation) {
            let tappedID = postid
            print(tappedID)
            //add likes to database
            let dq = BackendlessDataQuery()
            let wc = "postid = '\(tappedID)'"
            dq.whereClause = wc
            
            let postsForLikes = self.backendless.persistenceService.of(Likes.ofClass()).find(dq)
            let np = postsForLikes.data
            let cp = postsForLikes.getCurrentPage()
            if cp.count > 0 {
                for post in cp as! [Likes] {
                    if post.ownerId != id {
                        AddLikeSync(tappedID)
                        loadData()
                        self.tableView.reloadData()
                        refreshControl!.endRefreshing()
                        
                    } else{
                        print("Already Liked")
                    }
                }
            } else {
                AddLikeSync(tappedID)
                loadData()
                self.tableView.reloadData()
                refreshControl!.endRefreshing()
            }
            
        }
    }
    func AddLikeSync(pid: String){
        var p = Likes()
        let dataStore = backendless.data.of(Likes.ofClass())
        p.ownerId = id
        p.postid = pid
        // save object synchronously
        var error: Fault?
        let result = dataStore.save(p, fault: &error) as? Likes
        if error == nil {
            print("Contact has been saved: \(result!.objectId)")
        }
        else {
            print("Server reported an error: \(error)")
        }
        
    }
    
    func commentTapped(recognizer: UITapGestureRecognizer){
        let tappedLocation = recognizer.locationInView(self.tableView)
        if let tappedIndexPath = tableView.indexPathForRowAtPoint(tappedLocation) {
            let tappedID = comIDArray[tappedIndexPath.row]
            //add likes to database
            let dq = BackendlessDataQuery()
            let wc = "commentid = '\(tappedID)'"
            dq.whereClause = wc
            
            let postsForLikes = self.backendless.persistenceService.of(CommentLikes.ofClass()).find(dq)
            let np = postsForLikes.data
            let cp = postsForLikes.getCurrentPage()
            if cp.count > 0 {
                for post in cp as! [CommentLikes] {
                    if post.ownerId != id {
                        AddCommentLikeSync(tappedID)
                        loadData()
                        self.tableView.reloadData()
                        refreshControl!.endRefreshing()
                        
                    } else{
                        print("Already Liked")
                    }
                }
            } else {
                AddCommentLikeSync(tappedID)
                loadData()
                self.tableView.reloadData()
                refreshControl!.endRefreshing()
            }
            
        }
    }
    func AddCommentLikeSync(cid: String){
        var c = CommentLikes()
        let dataStore = backendless.data.of(CommentLikes.ofClass())
        c.ownerId = id
        c.postid = postid
        c.commentid = cid
        // save object synchronously
        var error: Fault?
        let result = dataStore.save(c, fault: &error) as? CommentLikes
        if error == nil {
            print("Contact has been saved: \(result!.objectId)")
        }
        else {
            print("Server reported an error: \(error)")
        }
        
    }
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1{
            footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
            footerView?.backgroundColor = UIColor.blueColor()
            commentView = UITextView(frame: CGRect(x: 10, y: 5, width: tableView.bounds.width - 80 , height: 100))
            commentView?.backgroundColor = UIColor.whiteColor()
            commentView?.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
            commentView?.layer.cornerRadius = 2
            commentView?.scrollsToTop = true
            
            footerView?.addSubview(commentView!)
            let button = UIButton(frame: CGRect(x: tableView.bounds.width - 65, y: 10, width: 60 , height: 30))
            button.setTitle("Reply", forState: UIControlState.Normal)
            button.backgroundColor = UIColor.redColor()
            button.layer.cornerRadius = 5
            button.addTarget(self, action: "reply", forControlEvents: UIControlEvents.TouchUpInside)
            footerView?.addSubview(button)
            commentView?.delegate = self
            
            return footerView

        } else{
            return nil
        }
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1{
            if self.footerView != nil {
                return self.footerView!.bounds.height
            }
            return 50
        } else{
            return 0
        }
    }
    
    
    func loadData(){
        let whereClause = "postid = '\(postid)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        let comments = self.backendless.persistenceService.of(Comments.ofClass()).find(dataQuery)
        numberOfComments = String(comments.data.count)
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
            commentsArray.append(comText)
            timeArray.append(comTime)
            
            let comid = comment.objectId!
            comIDArray.append(comid)
            let clauseComLikes = "commentid = '\(comid)'"
            let queryComLikes = BackendlessDataQuery()
            queryComLikes.whereClause = clauseComLikes
            let comLikesResult = self.backendless.persistenceService.of(CommentLikes.ofClass()).find(queryComLikes)
            let comLikesPage = comLikesResult.getCurrentPage()
            for like in comLikesPage as! [CommentLikes] {
                n += 1
            }
            let comLikes = String(n)
            likesArray.append(comLikes)
            n = 0
            
        }
        
        let wc = "objectId = '\(postid)'"
        let query = BackendlessDataQuery()
        query.whereClause = wc
        
        let posts = self.backendless.persistenceService.of(Posts.ofClass()).find(query)
        
        let cp = posts.getCurrentPage()
        
        for post in cp as! [Posts]{
            postText = post.post!
            let nscreated = post.created
            let nsdate = NSDate()
            let inter = nsdate.timeIntervalSinceDate(nscreated)
            if inter < 60.0 * 60.0{
                postTimeSinceDate = Int(inter / (60.0))
                postStringTimeSinceDate = "\(postTimeSinceDate) minutes ago"
            }
            else if inter < 24.0 * 60 * 60{
                postTimeSinceDate = Int(inter / (60.0 * 60.0))
                postStringTimeSinceDate = "\(postTimeSinceDate) hours ago"
            }
            else if inter < 24.0 * 60 * 60 * 30{
                postTimeSinceDate = Int(inter / (60.0 * 60.0 * 24.0))
                postStringTimeSinceDate = "\(postTimeSinceDate) days ago"
            }
            else{
                postTimeSinceDate = Int(inter / (60.0 * 60.0 * 24.0 * 30.0))
                postStringTimeSinceDate = "\(postTimeSinceDate) months ago"
            }
            postTime = postStringTimeSinceDate
            color = post.color!
            if color == "red"{
                uicolor = red
            } else if color == "blue"{
                uicolor = blue
            } else if color == "brown"{
                uicolor = brown
            } else if color == "black"{
                uicolor = black
            } else if color == "purple"{
                uicolor = purple
            } else if color == "green"{
                uicolor = green
            } else if color == "yellow"{
                uicolor = yellow
            } else if color == "orange"{
                uicolor = orange
            }
            
            let clauseLikes = "postid = '\(postid)'"
            let queryLikes = BackendlessDataQuery()
            queryLikes.whereClause = clauseLikes
            let likesResult = self.backendless.persistenceService.of(Likes.ofClass()).find(queryLikes)
            let likesPage = likesResult.getCurrentPage()
            for like in likesPage as! [Likes] {
                num += 1
            }
            likes = String(num)
            
            let tagsClause = "postid = '\(postid)'"
            let queryTags = BackendlessDataQuery()
            queryTags.whereClause = tagsClause
            let tags = self.backendless.persistenceService.of(Tags.ofClass()).find(queryTags)
            let tagsCurrentPage = tags.getCurrentPage()
            
            var row = [String]()
            
            for tag in tagsCurrentPage as! [Tags]{
                let t = tag.tag!
                row.append(t)
                print(t)
            }
            tagsForPost = row.joinWithSeparator(", ")
            
        }

    }
    
    func reply() {
        let newc = Comments()
        let ctext = commentView?.text
        let ds = backendless.data.of(Comments.ofClass())
        
        newc.comment = ctext
        newc.id = id
        newc.postid = postid
        
        var e: Fault?
        let r = ds.save(newc, fault: &e) as? Comments
        if e == nil{
            print("Post has been saved: \(r!.objectId)")
        }
        else {
            print("Server reported an error: \(e)")
        }
        
        loadData()
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
        
    }
}
