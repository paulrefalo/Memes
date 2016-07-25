//
//  MemeCollectionViewController.swift
//  Memes
//
//  Created by Paul ReFalo on 7/19/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit

class MemeCollectionViewController : UICollectionViewController {
    
    // MARK: Global Declarations, outlets, and actions

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    @IBOutlet weak var flowLayout : UICollectionViewFlowLayout!
    
    @IBAction func segueToEditMeme(sender: AnyObject) {
        performSegueWithIdentifier("EditVCSegueFromCollection", sender: nil)
    }
    
    // MARK: override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat
        let dimension: CGFloat
        
        if (UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            space = 3.0
            dimension = (view.frame.size.width - (2 * space)) / 3
        } else {
            space = 5.0
            dimension = (view.frame.size.width - (2 * space)) / 5
        }
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space / space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
 
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {        
        // Go directly to EditMemeViewController if memes array is empty
        if memes.isEmpty {
            performSegueWithIdentifier("EditVCSegueFromCollection", sender: nil)
        }
        // Reload the data to keep current - must be class UITableViewController for this to work
        collectionView!.reloadData()
    }
    
    // MARK: Collection View Data Source and Collection functions
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        let currentMeme = memes[indexPath.item]
        let imageView = UIImageView(image: currentMeme.memedImage)
        cell.backgroundView = imageView
        
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath){
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
    
}


 