//
//  KRWAddressControllerTableViewController.swift
//  Spot
//
//  Created by Kw on 02/01/15.
//  Copyright (c) 2015 K.Wachendorff. All rights reserved.
//

import UIKit

class KRWAddressController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {

    let cities = ["Boston", "New York", "Oregon", "Tampa", "Los Angeles", "Dallas", "Miami", "Olympia", "Montgomery", "Washington", "Orlando", "Detroit"].sorted {
        $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending
    }
    
    var searchController: UISearchController?
    var searchResultsController: UITableViewController?
    
    let identifier = "Cell"
    
    // Filtered results are stored here.
    var results: NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // A table for search results and its controller.
        let resultsTableView = UITableView(frame: self.tableView.frame)
        self.searchResultsController = UITableViewController()
        self.searchResultsController?.tableView = resultsTableView
        self.searchResultsController?.tableView.dataSource = self
        self.searchResultsController?.tableView.delegate = self
        
        // Register cell class for the identifier.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.identifier)
        self.searchResultsController?.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.identifier)
        
        self.searchController = UISearchController(searchResultsController: self.searchResultsController!)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.delegate = self
        self.searchController?.searchBar.sizeToFit() // bar size
        self.tableView.tableHeaderView = self.searchController?.searchBar
        
        self.definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchResultsController?.tableView {
            if let results = self.results {
                return results.count
            } else {
                return 0
            }
        } else {
            return self.cities.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifier) as UITableViewCell
        
        var text: String?
        if tableView == self.searchResultsController?.tableView {
            if let results = self.results {
                text = self.results!.objectAtIndex(indexPath.row) as? String
            }
        } else {
            text = self.cities[indexPath.row]
        }
        
        cell.textLabel?.text = text
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == self.searchResultsController?.tableView {
            // Remove search bar & hide it.
            self.searchController?.active = false
            self.hideSearchBar()
        }
    }
    
    func hideSearchBar() {
        let yOffset = self.navigationController!.navigationBar.bounds.height + UIApplication.sharedApplication().statusBarFrame.height
        self.tableView.contentOffset = CGPointMake(0, self.searchController!.searchBar.bounds.height - yOffset)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if self.searchController?.searchBar.text.lengthOfBytesUsingEncoding(NSUTF32StringEncoding) > 0 {
            if let results = self.results {
                results.removeAllObjects()
            } else {
                results = NSMutableArray(capacity: self.cities.count)
            }
            
            let searchBarText = self.searchController!.searchBar.text
            
            let predicate = NSPredicate(block: { (city: AnyObject!, b: [NSObject : AnyObject]!) -> Bool in
                var range: NSRange = 0
                if city is NSString {
                    range = city.rangeOfString(searchBarText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                }
                
                return range.location != NSNotFound
            })
            
            // Get results from predicate and add them to the appropriate array.
            let filteredArray = (self.cities as NSArray).filteredArrayUsingPredicate(predicate)
            self.results?.addObjectsFromArray(filteredArray)
            
            // Reload a table with results.
            self.searchResultsController?.tableView.reloadData()
        }
    }
    
    //UISearchController
    
    func didDismissSearchController(searchController: UISearchController) {
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.hideSearchBar()
            }, completion: nil)
    }

}
