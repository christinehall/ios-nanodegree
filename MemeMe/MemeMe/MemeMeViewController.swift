//
//  ViewController.swift
//  MemeMe
//
//  Created by Christine Hall on 3/23/16.
//  Copyright © 2016 Christine Hall. All rights reserved.
//

import UIKit

class MemeMeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var imagePickerView: UIImageView!
    var shareButton: UIBarButtonItem!
    var toolBar: UIToolbar!
    var topText: UITextField!
    var bottomText: UITextField!
    var navBar: UIToolbar!
    
    var topTextIsDefault = true
    var bottomTextIsDefault = true
    var expanded = false
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // note: I create all the UI elements 100% programmatically.
        let screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        view.backgroundColor = UIColor.darkGrayColor()
        imagePickerView = UIImageView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        view.addSubview(imagePickerView)
        
        setupNavBar()
        setupToolBar()
        setupTextFields()
        
        view.addSubview(navBar)
        view.addSubview(toolBar)
        view.addSubview(topText)
        view.addSubview(bottomText)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        subscribeToRotationNotifications()

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        unsubscribeToRotationNotifications()

    }
    
    ///////////////////////////////////////
    // UI setup
    
    func resizeElements() {
        navBar.frame = CGRectMake(0,0, screenWidth, 65)
        topText.frame = CGRectMake(30, screenHeight/4, screenWidth - 60, 40)
        bottomText.frame = CGRectMake(30, screenHeight/4*3, screenWidth - 60, 40)
        toolBar.frame = CGRectMake(0, view.frame.size.height - 46, view.frame.size.width, 46)
        imagePickerView.frame = CGRectMake(0, 0, screenWidth, screenHeight)
    }
    

    func setupNavBar() {
        navBar = UIToolbar(frame: CGRectMake(0,0,screenWidth,65))
        shareButton = UIBarButtonItem(title: "Share", style: .Plain, target: self, action: "share:")
        shareButton.enabled = false
        navBar.setItems([shareButton], animated: true)
        
    }
    
    func setupToolBar() {
        toolBar = UIToolbar()
        toolBar.frame = CGRectMake(0, view.frame.size.height - 46, view.frame.size.width, 46)
        toolBar.sizeToFit()
        toolBar.backgroundColor = UIColor.darkGrayColor()
        
        // add buttons to the toolbar to pick or take a photo
        let pickButton = UIBarButtonItem(title:"Pick", style: UIBarButtonItemStyle.Plain, target: self, action: "pickAnImage:")
        pickButton.tag = 0
        
        let cameraButton = UIBarButtonItem(title:"Take a Photo", style: UIBarButtonItemStyle.Bordered , target: self, action: "pickAnImage:")
        cameraButton.tag = 0
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        toolBar.setItems([pickButton, cameraButton], animated: true)
        
    }
    
    func setupTextFields() {
        
        // set the text attributes for our text fields
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -5
        ]
        
        // labels for top and bottom
        topText = UITextField(frame: CGRectMake(30, screenHeight/4, screenWidth - 60, 40))
        topText.text = "TOP"
        topText.tag = 0
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.Center

        bottomText = UITextField(frame: CGRectMake(30, screenHeight/4*3, screenWidth - 60, 40))
        bottomText.text = "BOTTOM"
        bottomText.tag = 1
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = .Center

        topText.delegate = self
        bottomText.delegate = self
    }
    
    func rotated() {
        let screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        print(screenWidth, screenHeight)
        resizeElements()
    }
    
    ///////////////////////////////////////
    // saving the meme!

    @objc func share(sender: AnyObject) {
        
        var meme = Meme()
        meme.topText = topText.text!
        meme.bottomText = bottomText.text!
        meme.image = imagePickerView.image
        meme.memeImage = generateMemedImage()
        
        let avc = UIActivityViewController(activityItems: [meme.memeImage], applicationActivities: nil)
        presentViewController(avc, animated: true, completion: nil)
        avc.completionWithItemsHandler = { (activity: String?, completed: Bool, items: [AnyObject]?, error: NSError?) -> Void in
            if completed {
                self.dismissViewControllerAnimated(true, completion: nil)
                self.clearAll()
            }
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        toolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        toolBar.hidden = false
        
        return memedImage
    }
    
    func clearAll() {
        imagePickerView.image = nil
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        topTextIsDefault = true
        bottomTextIsDefault = true
        shareButton.enabled = false
    }
    
    ///////////////////////////////////////
    // functions for image picking

    @objc func pickAnImage(sender: AnyObject) {
        
        var type = UIImagePickerControllerSourceType.Camera
        if sender.tag == 0 {
            print("Changing type to Photo Library!")
            type = UIImagePickerControllerSourceType.PhotoLibrary
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    ///////////////////////////////////////
    // functions for textfielddelegate
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 0 {
            if topTextIsDefault == true {
                textField.text = ""
                topTextIsDefault = false
            }
        } else if textField.tag == 1{
            if bottomTextIsDefault == true {
                textField.text = ""
                bottomTextIsDefault = false
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // check that the user input some text. if they didnt, replace the default text
        if textField.text == "" {
            if textField.tag == 0 {
                textField.text = "TOP"
            } else {
                textField.text = "BOTTOM"
            }
        }
        textField.resignFirstResponder()
        return true
    }

    ///////////////////////////////////////
    // functions for handling sliding the view as the keyboard is shown/hidden
    
    @objc func keyboardWillShow(notification: NSNotification) {
        for thisView in view.subviews {
            if thisView.isFirstResponder() == true && thisView.tag == 1 {
                view.frame.origin.y -= getKeyboardHeight(notification)
                expanded = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if expanded == true {
            view.frame.origin.y += getKeyboardHeight(notification)
            expanded = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToRotationNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func unsubscribeToRotationNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    ///////////////////////////////////////
    // functions for UIImageickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        dismissViewControllerAnimated(true, completion: nil)
    
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
            shareButton.enabled = true
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Cancelled image picker!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

