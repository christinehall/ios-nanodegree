//
//  ViewController.swift
//  MemeMe
//
//  Created by Christine Hall on 3/23/16.
//  Copyright © 2016 Christine Hall. All rights reserved.
//

import UIKit

struct Meme {
    var topText: String!
    var bottomText: String!
    var image: UIImage!
    var memeImage: UIImage!
}

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var imagePickerView: UIImageView!
    var shareButton: UIButton!
    var toolBar: UIToolbar!
    var topText: UITextField!
    var bottomText: UITextField!
    var topTextIsDefault = true
    var bottomTextIsDefault = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // note: I create all the UI elements 100% programmatically.
        let screenSize = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        imagePickerView = UIImageView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        
        shareButton = UIButton(frame: CGRectMake(20, 20, 50, 50))
        shareButton.setTitle("Share", forState: .Normal)
        shareButton.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        
        toolBar = UIToolbar()
        toolBar.frame = CGRectMake(0, self.view.frame.size.height - 46, self.view.frame.size.width, 46)
        toolBar.sizeToFit()
        toolBar.backgroundColor = UIColor.darkGrayColor()
        
        // add buttons to the toolbar to pick or take a photo
        let pickButton = UIBarButtonItem(title:"Pick", style: UIBarButtonItemStyle.Plain, target: self, action: "pickAnImage:")
        let cameraButton = UIBarButtonItem(title:"Take a Photo", style: UIBarButtonItemStyle.Plain, target: self, action: "pickAnImageFromCamera:")
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        toolBar.setItems([pickButton, cameraButton], animated: true)
        
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
        topText.contentVerticalAlignment = .Center
        topText.textAlignment = .Center
        topText.tag = 0
        topText.defaultTextAttributes = memeTextAttributes
        
        bottomText = UITextField(frame: CGRectMake(30, screenHeight/4*3, screenWidth - 60, 40))
        bottomText.text = "BOTTOM"
        bottomText.contentVerticalAlignment = .Center
        bottomText.textAlignment = .Center
        bottomText.tag = 1
        bottomText.defaultTextAttributes = memeTextAttributes
        
        // make sure delegates are set to self
        self.topText.delegate = self
        self.bottomText.delegate = self
        
        // add all elements to the view
        self.view.addSubview(imagePickerView)
        self.view.addSubview(shareButton)
        self.view.addSubview(toolBar)
        self.view.addSubview(topText)
        self.view.addSubview(bottomText)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    ///////////////////////////////////////
    // saving the meme!

    func save() {
        
        var meme = Meme()
        meme.topText = topText.text!
        meme.bottomText = bottomText.text!
        meme.image = imagePickerView.image!
        
        var avc = UIActivityViewController(activityItems: [meme.image], applicationActivities: nil)
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func memeShared() {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    ///////////////////////////////////////
    // functions for image picking

    @objc func pickAnImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @objc func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
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
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
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
    
    ///////////////////////////////////////
    // functions for UIImageickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        dismissViewControllerAnimated(true, completion: nil)
    
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
            
        }
    
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Cancelled image picker!")
        dismissViewControllerAnimated(true, completion: nil)
    }


}

