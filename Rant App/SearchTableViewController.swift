//
//  SearchTableViewController.swift
//  Rant App
//
//  Created by block7 on 3/1/16.
//  Copyright © 2016 Rant-App. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating{
    var searchController: UISearchController!
    
    let backendless = Backendless.sharedInstance()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var id = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    var savedTags: [String] = []
    var filteredSavedTags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        loadSavedTags()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredSavedTags.count
        }
        return savedTags.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        var tag: String!
        if searchController.active && searchController.searchBar.text != "" {
            tag = filteredSavedTags[indexPath.row]
        } else {
            tag = savedTags[indexPath.row]
        }
        cell.textLabel?.text = tag
        return cell
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "" {
        }
    }
    
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController){
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        let whereclause = "tag LIKE '\(searchText.lowercaseString)%'"
        let query = BackendlessDataQuery()
        query.whereClause = whereclause
        let filteredtags = self.backendless.persistenceService.of(SavedTags.ofClass()).find(query)
        let cp = filteredtags.getCurrentPage()
        for tag in cp as! [SavedTags] {
            let t = tag.tag!
            filteredSavedTags.append(t)
            return t
        }
        
        filteredSavedTags = savedTags.filter({
            
        })
        
        tableView.reloadData()
    }
    func loadSavedTags(){
        let savedtags = self.backendless.persistenceService.of(SavedTags.ofClass()).find()
        
        let currentPage = savedtags.getCurrentPage()
        
        for tag in currentPage as! [SavedTags] {
            let tagText = tag.tag!
            savedTags.append(tagText)
        }

        
    }
}
