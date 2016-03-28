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
    
    var addSavedTagButton: UIButton!
    var addFavoriteTagButton: UIButton!
    
    var numberOfSections: Int!
    
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
        if searchController.searchBar.text == ""{
            return savedTags.count
        }
        else if numberOfSectionsInTableView(tableView) == 1{
            if searchController.active && searchController.searchBar.text != "" {
                return filteredSavedTags.count
            }
            return savedTags.count
        } else if numberOfSectionsInTableView(tableView) == 2{
            if searchController.active && searchController.searchBar.text != "" {
                return filteredSavedTags.count + 1
            }
            return savedTags.count + 1
        } else{
            if searchController.active && searchController.searchBar.text != "" {
                return filteredSavedTags.count + 2
            }
            return savedTags.count + 2

        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let text = searchController.searchBar.text!
        if numberOfSectionsInTableView(tableView) == 2{
            if indexPath.section == 0{
                let c = tableView.dequeueReusableCellWithIdentifier("LikeTag", forIndexPath: indexPath) as! SearchAddCells
                c.TextLabel.text = text
                c.AddBtn.indexPath = indexPath.row
                c.AddBtn.section = 1
                c.AddBtn.tagText = text
                c.AddBtn.addTarget(self, action: "addBtnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
                addFavoriteTagButton = c.AddBtn
                return c
            }
            
        } else{
            if indexPath.section == 0{
                let c2 = tableView.dequeueReusableCellWithIdentifier("AddTag", forIndexPath: indexPath) as! SearchAddCells
                c2.TextLabel.text = text
                c2.AddBtn.indexPath = indexPath.row
                c2.AddBtn.section = 0
                c2.AddBtn.tagText = text
                c2.AddBtn.addTarget(self, action: "addBtnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
                addSavedTagButton = c2.AddBtn
                return c2
                
            } else if indexPath.section == 1{
                let c3 = tableView.dequeueReusableCellWithIdentifier("LikeTag", forIndexPath: indexPath) as! SearchAddCells
                c3.TextLabel.text = text
                c3.AddBtn.indexPath = indexPath.row
                c3.AddBtn.section = 1
                c3.AddBtn.tagText = text
                c3.AddBtn.addTarget(self, action: "addBtnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
                addFavoriteTagButton = c3.AddBtn
                return c3
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchedTag", forIndexPath: indexPath) as! SearchTableViewCell
        var tag: String!
        if searchController.active && searchController.searchBar.text != "" {
            tag = filteredSavedTags[indexPath.row]
        } else {
            tag = savedTags[indexPath.row]
        }
        cell.tagLabel.text = tag
        cell.tagBtn.setTitle(tag, forState: .Normal)
        return cell
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tagBtnClicked" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let tag = savedTags[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! SearchedTagTableViewController
                controller.clickedTag = tag
                
            }
        }
    }
    func addBtnClicked(sender: AddUIButton){
        let sec = sender.section!
        let tt = sender.tagText!
        if sec == 0{
            let savedTags = SavedTags()
            savedTags.tag = tt
            let dataStore = backendless.data.of(SavedTags.ofClass())
            
            var error: Fault?
            let result = dataStore.save(savedTags, fault: &error) as? SavedTags
            if error == nil {
                print("Post has been saved: \(result!.objectId)")
            }
            else {
                print("Server reported an error: \(error)")
            }
            addSavedTagButton.setTitle("Added", forState: .Normal)
            addSavedTagButton.enabled = false

        } else{
            let favoriteTags = FavoriteTags()
            favoriteTags.tag = tt
            favoriteTags.id = id
            let store = backendless.data.of(FavoriteTags.ofClass())
            
            var error: Fault?
            let result = store.save(favoriteTags, fault: &error) as? FavoriteTags
            if error == nil {
                print("Post has been saved: \(result!.objectId)")
            }
            else {
                print("Server reported an error: \(error)")
            }
            addFavoriteTagButton.setTitle("Liked", forState: .Normal)
            addFavoriteTagButton.enabled = false

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
