//
//  CommentsTableViewController.swift
//  Rant App
//
//  Created by Aaron Epstein on 3/2/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentsTableViewCell", forIndexPath: indexPath) as! CommentsTableViewCell
        
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
