//
//  MemeDetailViewController.swift
//  Memes
//
//  Created by Paul ReFalo on 7/24/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit

class MemeDetailViewController : UIViewController {
    
    var meme: Meme!
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define image
        if let image = meme?.memedImage {
            imageView.image = image
        } else {
            print("No image populated")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
}
