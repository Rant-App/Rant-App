//
//  SearchedTagTableViewController.swift
//  Rant App
//
//  Created by block7 on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class SearchedTagTableViewController: UITableViewController {
    var clickedTag: String = ""
    
    
    let backendless = Backendless.sharedInstance()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var id = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    var postArray: [String] = []
    
    var tagsArray: [[String]] = [[]]
    var numCommentsArray: [[String]] = [[]]
    
    var num = 0
    
    var time = ""
    var test: Int!
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
    
    var postIdArray: [String] = []
    var colorArray: [UIColor] = []
    var likesArray: [String] = []
    var favTagsArray: [String] = []
    var timeArray: [String] = []
    
    var timeSinceDate: Int!
    var StringTimeSinceDate: String!
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("STCell", forIndexPath: indexPath) as! PostTableViewCell
        let num = numCommentsArray[indexPath.row][0]
        let textColor = colorArray[indexPath.row]
        var currentTags: String!
        if tagsArray[indexPath.row].count <= 1{
            currentTags = tagsArray[indexPath.row][0]
        } else{
            currentTags = tagsArray[indexPath.row].joinWithSeparator(", ")
        }
        
        let currentLikes = likesArray[indexPath.row]
        
        let postTime = timeArray[indexPath.row]
        
        cell.PostTextLabel.text = postArray[indexPath.row]
        cell.TimeStampLabel.text = postTime
        cell.PostTextLabel.textColor = textColor
        cell.TagsLabel.text = currentTags
        cell.replyLabel.text = "\(num) replies"
        cell.CountLabel.text = currentLikes
        
        let img = cell.ClapImage
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
        img.addGestureRecognizer(tap)
        img.userInteractionEnabled = true

        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return test
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        numCommentsArray.removeAtIndex(0)
        loadData()
        tagsArray.removeAtIndex(0)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.navigationItem.title = clickedTag
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searched" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let pid = postIdArray[indexPath.row]
                let controller = segue.destinationViewController as! CommentsTableViewController
                controller.postid = pid
                
            }
        }
    }
    func tapped(recognizer: UITapGestureRecognizer){
        let tappedLocation = recognizer.locationInView(self.tableView)
        if let tappedIndexPath = tableView.indexPathForRowAtPoint(tappedLocation) {
            let tappedID = postIdArray[tappedIndexPath.row]
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

    func loadData(){
        let whereClause = "tag = '\(clickedTag)'"
        let query = BackendlessDataQuery()
        query.whereClause = whereClause
        
        let results = self.backendless.persistenceService.of(Tags.ofClass()).find(query)
        
        
        let currentPage = results.getCurrentPage()
        
        for x in currentPage as! [Tags]{
            let idForTag = x.postid!
            postIdArray.append(idForTag)
        }
        
        postIdArray = Array(Set(postIdArray))
        
        test = postIdArray.count
        
        for p in postIdArray{
            let w = "objectId = '\(p)'"
            let q = BackendlessDataQuery()
            q.whereClause = w
            let posts = self.backendless.persistenceService.of(Posts.ofClass()).find(q)
            
            
            let cp = posts.getCurrentPage()
            
            for post in cp as! [Posts]{
                let postText = post.post!
                let df = NSDate()
                let created = post.created
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
                time = StringTimeSinceDate

                timeArray.append(time)
                postArray.append(postText)
                color = post.color!
                
                postid = post.objectId!
                
                let clauseLikes = "postid = '\(postid)'"
                let queryLikes = BackendlessDataQuery()
                queryLikes.whereClause = clauseLikes
                let likesResult = self.backendless.persistenceService.of(Likes.ofClass()).find(queryLikes)
                let likesPage = likesResult.getCurrentPage()
                for like in likesPage as! [Likes] {
                    num += 1
                }
                count = String(num)
                likesArray.append(count)
                num = 0
                
                let clauseTags = "postid = '\(postid)'"
                let queryTags = BackendlessDataQuery()
                queryTags.whereClause = clauseTags
                let tagsForPosts = self.backendless.persistenceService.of(Tags.ofClass()).find(queryTags)
                let tagsCurrentPage = tagsForPosts.getCurrentPage()
                
                var row = [String]()
                
                for y in tagsCurrentPage as! [Tags]{
                    let t = y.tag!
                    row.append(t)
                }
                tagsArray.append(row)
                
                let clauseComments = "postid = '\(postid)'"
                let queryComments = BackendlessDataQuery()
                queryComments.whereClause = clauseComments
                let comments = self.backendless.persistenceService.of(Comments.ofClass()).find(queryComments)
                numberOfComments = String(comments.data.count)
                
                var rowC = [String]()
                rowC.append(numberOfComments)
                numCommentsArray.append(rowC)
                
                
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
                
                colorArray.append(uicolor)

                
            }
            
        }
        
        
        
        
    }

    
    
}
