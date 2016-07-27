//
//  ViewController.swift
//  ImagePicker
//
//  Created by Paul ReFalo on 6/30/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: - Global declarations
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),     // Fill in appropriate UIColor
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "Impact", size: 40)!,    // "HelveticaNeue-CondensedBlack"
        NSStrokeWidthAttributeName : -3.0,                   // Fill in appropriate Float
    ]
    
    private var sentMemes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // MARK: IBActions
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        presentImagePicker(.PhotoLibrary) // or .SavedPhotosAlbum
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        presentImagePicker(.Camera)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        // hand the object in
        let sharedImage = generateMemedImage()
        
        // Activity Controller View
        let nextController = UIActivityViewController(activityItems: [sharedImage], applicationActivities: nil)
        
        // Handler for completion
        nextController.completionWithItemsHandler = { activity, success, items, error in
            
            if (success == true) {
                // Generate a memed image, save it, dismiss ViewController, and go back to SentMemesVC
                self.save(sharedImage)
                self.dismissViewControllerAnimated(true, completion: nil)
                self.returnToSentMemes(self.cancelButton)
                print("Saved and segued back to Sent memes")
            }
        }
        
        // Present the view
        presentViewController(nextController, animated: true, completion: nil)
        
    }
    
    // Action for the cancel button
    @IBAction func returnToSentMemes(sender: UIBarButtonItem) {
        // Nav to TabBarController or MemeTableViewController
        let sentController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeTableViewController") as! MemeTableViewController
        sentController.reloadInputViews()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK:  Override functions
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        // set textField alpha to 0 if there is not image and 1 if there is an image
        // also enable / disable share button
        if (imagePickerView.image != nil) {
            topTextField.alpha = 1
            bottomTextField.alpha = 1
            shareButton.enabled = true
        } else {
            topTextField.alpha = 0
            bottomTextField.alpha = 0
            shareButton.enabled = false
        }
        
        // check for camera and set button
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            cameraButton.enabled = true
        } else {
            cameraButton.enabled = false
        }
        
        // if memes is empty, there are no sent memes to view or navigate to
        if sentMemes.isEmpty {
            cancelButton.enabled = false
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField(topTextField, defaultText: "TOP")
        setupTextField(bottomTextField, defaultText: "BOTTOM")
        
        // To see all of the fonts available as targets
        // showFontFamiliesAvailable()
    }

    
    // MARK: Functions
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField.tag == -1 {
            topTextField.text = "" // Clear text once editing begins
            topTextField.tag = 1   // Reset tags on text fields to prevent clearing text again
        }
        
        if textField.tag == -2 {
            bottomTextField.text = ""
            bottomTextField.tag = 2
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func setupTextField(textField: UITextField, defaultText: String) {
        textField.delegate = self
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.borderStyle = .None
    }
    
    func presentImagePicker(chosenSource: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = chosenSource
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        /* how to resize image if needed
        let newSize:CGSize = CGSize(width: 250,height: 250)
        let rect = CGRectMake(0,0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        newImage.drawInRect(rect)
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        */
 
        imagePickerView.image = newImage  // resizedImage // newImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save(saveImage : UIImage) {
        // Create the meme
        let meme = Meme(
            topText : topTextField.text!,
            bottomText : bottomTextField.text!,
            image : imagePickerView.image!,
            memedImage : generateMemedImage() )
        
        // Add meme to array in app delegate
        let n : Int = 1 // change to 1 to turn in and any number for collection view testing
        for _ in 1...n {
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        }
        let _ = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        // dump(sentMemes)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        navigationController?.navigationBarHidden = true
        toolbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        toolbar.hidden = false
        navigationController?.navigationBarHidden = false
        
        return memedImage
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("Keyboard will show")
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y =  getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("Keyboard will hide")
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        print("get Keyboard Height")
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMemeViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMemeViewController.keyboardWillHide(_:))    , name: UIKeyboardWillHideNotification, object: nil)
        print("subscribe to keyboard notifications")
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        print("UNsubscribe to keyboard notifications")
    }

    func showFontFamiliesAvailable() {
        for family: String in UIFont.familyNames()
        {
            print("\(family)")
            for names: String in UIFont.fontNamesForFamilyName(family)
            {
                print("== \(names)")
            }
        }
    }
    
}





