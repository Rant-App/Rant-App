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
    var favoriteTags: [String] = []
    var stcheck: [String] = []
    
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
        var checkFavTags: Int!
        var checkSavTags: Int!
        var returnCount: Int!
        if searchController.active && searchController.searchBar.text != ""{
            loadFavoriteTags(searchController.searchBar.text!)
            checkFavTags = favoriteTags.count
            favoriteTags.removeAll()
            
            loadTagsBySearch(searchController.searchBar.text!)
            checkSavTags = stcheck.count
            stcheck.removeAll()
            
            if checkSavTags == 0{
                returnCount = 3
            } else if checkSavTags != 0 && checkFavTags == 0{
                returnCount = 2
            }
            else{
                returnCount = 1
            }
        }
        else{
            returnCount = 1
        }
        
        return returnCount
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
        }
        
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
    func loadFavoriteTags(input: String){
        let wc = "tag LIKE '\(input)%'"
        let dq = BackendlessDataQuery()
        dq.whereClause = wc
        let tags = self.backendless.persistenceService.of(FavoriteTags.ofClass()).find(dq)
        let cpage = tags.getCurrentPage()
        
        for tag in cpage as! [FavoriteTags]{
            let ft = tag.tag!
            favoriteTags.append(ft)
            
        }
    }
    func loadTagsBySearch(input: String){
        let d = BackendlessDataQuery()
        d.whereClause = "tag LIKE '\(input)%'"
        let ts = self.backendless.persistenceService.of(SavedTags.ofClass()).find(d)
        let cps = ts.getCurrentPage()
        
        for tag in cps as! [SavedTags]{
            let tt = tag.tag!
            stcheck.append(tt)
        }
    }
}
