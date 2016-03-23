//
//  GeoTableViewController.swift
//  Rant App
//
//  Created by block7 on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit
import CoreLocation

class GeoTableViewController: UITableViewController, CLLocationManagerDelegate {
    let backendless = Backendless.sharedInstance()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var id = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    var myPosts = [PostTableViewCell]()
    let locationManager = CLLocationManager()
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        
        let num = String(numCommentsArray[indexPath.row].count)
        let textColor = colorArray[indexPath.row]
        tagsArray.removeAtIndex(0)
        let currentTags = tagsArray[indexPath.row].joinWithSeparator(", ")
        
        let currentLikes = likesArray[indexPath.row]
        
        let currentPostid = postidArray[indexPath.row]
        
        let postTime = timeArray[indexPath.row]
        
        cell.PostTextLabel.text = postArray[indexPath.row]
        cell.TimeStampLabel.text = postTime
        cell.PostTextLabel.textColor = textColor
        cell.TagsLabel.text = currentTags
        cell.ReplyButton.setTitle("\(num) replies", forState: .Normal)
        cell.CountLabel.text = currentLikes
        
        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return test.count
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        latitude = locValue.latitude
        longitude = locValue.longitude
    }
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "geo" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let pid = postidArray[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! CommentsTableViewController
                controller.postid = pid
                
            }
        }
    }

    func loadData(){
        let whereClause = "distance( \(latitude), \(longitude), coordinates.latitude, coordinates.longitude ) < mi(10)"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let posts = self.backendless.persistenceService.of(Posts.ofClass()).find(dataQuery)
        
        let currentPage = posts.getCurrentPage()
        
        test = posts.data
        
        for post in currentPage as! [Posts] {
            let postText = post.post
            let df = NSDateFormatter()
            time = String(post.created)
            timeArray.append(time)
            count = post.likes!
            likesArray.append(count)
            
            postid = post.objectId!
            postidArray.append(postid)
            color = post.color!
            let unwrappedPostText = postText!
            postArray.append(unwrappedPostText)
            
            let clauseTags = "postid = '\(postid)'"
            let queryTags = BackendlessDataQuery()
            queryTags.whereClause = clauseTags
            let tags = self.backendless.persistenceService.of(Tags.ofClass()).find(queryTags)
            let tagsCurrentPage = tags.getCurrentPage()
            
            var row = [String]()
            
            for tag in tagsCurrentPage as! [Tags]{
                let t = tag.tag!
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
