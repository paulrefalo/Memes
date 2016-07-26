//
//  MemeTableViewController.swift
//  Memes
//
//  Created by Paul ReFalo on 7/19/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController : UITableViewController {
    
    // MARK: Global Declarations, outlets, and actions
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    @IBAction func segueToEditMemeVC(sender: AnyObject) {
        performSegueWithIdentifier("EditVCSegue", sender: nil)
    }
    
    // MARK: override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        // tableView.estimatedRowHeight = 65
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Show the tab bar if segue from EditMemeVC
        // self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = false

        // Go directly to EditMemeViewController if memes array is empty
        if memes.isEmpty {
            performSegueWithIdentifier("EditVCSegue", sender: nil)
        }
        // Reload the data to keep current - must be class UITableViewController for this to work
        tableView!.reloadData()
    }
    
    
    // MARK: Data Source and table methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("memeTableCell")!
        let currentMeme = memes[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = "\(currentMeme.topText) - \(currentMeme.bottomText)"
        cell.imageView?.image = currentMeme.memedImage
                
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // Delete meme
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    // segue to MemeDetailVC
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    // MARK: Add edit button
    // gives table row delete functionality
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem()
    }
}
