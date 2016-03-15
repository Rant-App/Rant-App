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
    
    var favTagsArray: [String] = []
    var postIdArray: [String] = []
    
    var timeArray: [String] = []
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagsTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        let num = String(numCommentsArray[indexPath.row].count)
        let textColor = colorArray[indexPath.row]
        let currentTags = tagsArray[indexPath.row]
        
        let tagsString = currentTags.joinWithSeparator(", ")
        
        let currentLikes = likesArray[indexPath.row]
        
        cell.PostTextLabel.text = postArray[indexPath.row]
        cell.TimeStampLabel.text = timeArray[indexPath.row]
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
        return test
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
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tags" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let pid = postIdArray[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CommentsTableViewController
                controller.postid = pid
                
            }
        }
    }

    func loadData(){
        let whereClause = "id = '\(id)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let tags = self.backendless.persistenceService.of(FavoriteTags.ofClass()).find(dataQuery)
        
        let currentPage = tags.getCurrentPage()
        
        for tag in currentPage as! [FavoriteTags] {
            let tagText = tag.tag!
            favTagsArray.append(tagText)
        }
        
        for x in favTagsArray{
            let wc = "tag = '\(x)'"
            let dq = BackendlessDataQuery()
            dq.whereClause = wc
            
            let postids = self.backendless.persistenceService.of(Tags.ofClass()).find(dq)
            
            let curPage = postids.getCurrentPage()
            
            for postid in curPage as! [Tags] {
                let postId = postid.postid!
                postIdArray.append(postId)
            }
            
            postIdArray = Array(Set(postIdArray))
            
            test = postIdArray.count
            
            for pi in postIdArray{
                let w = "objectId = '\(pi)'"
                let d = BackendlessDataQuery()
                d.whereClause = w
                let post = self.backendless.persistenceService.of(Posts.ofClass()).find(d)
                let cp = post.getCurrentPage()
                
                
                for post in cp as! [Posts] {
                    let postText = post.post!
                    count = post.likes!
                    time = String(post.created)
                    timeArray.append(time)
                    likesArray.append(count)
                    postArray.append(postText)
                    color = post.color!
                    
                    postid = post.objectId!
                    
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

}
