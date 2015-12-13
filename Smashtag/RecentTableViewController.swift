//
//  RecentTableViewController.swift
//  Smashtag
//
//  Created by Sanjib Ahmad on 12/9/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class RecentTableViewController: UITableViewController {
    
    private struct Storyboard {
        static let RecentSearchCell = "Recent Search"
        static let SearchTweetsSegue = "Search Tweets"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaults.sharedInstance.allRecentSearches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.RecentSearchCell, forIndexPath: indexPath)
        cell.textLabel?.text = UserDefaults.sharedInstance.allRecentSearches[indexPath.row]
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            UserDefaults.sharedInstance.removeRecentSearch(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.SearchTweetsSegue {
            if let tvc = segue.destinationViewController as? TweetTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    tvc.searchText = UserDefaults.sharedInstance.allRecentSearches[indexPath.row]
                }
            }
        }
    }

}
