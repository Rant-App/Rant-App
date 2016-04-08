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
    
    var timeSinceDate: Int!
    var StringTimeSinceDate: String!
    
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
    
    var colorArray: [UIColor] = []
    var likesArray: [String] = []
    var postidArray: [String] = []
    var timeArray: [String] = []

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
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
        print(cell.TagsLabel.text)
        cell.replyLabel.text = "\(num) replies"
        cell.CountLabel.text = currentLikes

        
        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if test != 0 {
            return test
        }
        return 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        numCommentsArray.removeAtIndex(0)
        loadData()
        tagsArray.removeAtIndex(0)
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()

    }
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profile" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let pid = postidArray[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CommentsTableViewController
                controller.postid = pid
                
            }
        }
    }

    func loadData(){
        let whereClause = "id = '\(id)'"
        let query = BackendlessDataQuery()
        query.whereClause = whereClause
        
        let posts = self.backendless.persistenceService.of(Posts.ofClass()).find(query)
        
        test = posts.data.count
        
        let currentPage = posts.getCurrentPage()
        
        for post in currentPage as! [Posts]{
            let postText = post.post!
            postArray.append(postText)
            
            count = post.likes!
            likesArray.append(count)
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
            
            postid = post.objectId!
            postidArray.append(postid)
            
            color = post.color!
            
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
            tagsArray.append(row)
            print(tagsArray[1].joinWithSeparator(", "))
            
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
