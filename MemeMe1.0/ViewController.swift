//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by Gil Felot on 24/08/15.
//  Copyright (c) 2015 Gil Felot. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var botText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    //Attributes for styling the text in the text fields
    let memeTextAttribues = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : NSNumber(float: -3.0)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setTextAttribut(botText, str : " BOTTOM ")
        setTextAttribut(topText, str: " TOP ")

    }
    
    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications()
        shareButton.enabled = imagePickerView.image != nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // Add an observer for KB notification
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:" , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:" , name: UIKeyboardWillHideNotification, object: nil)
    }
    // Remove thoses observer
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if botText.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if botText.isFirstResponder() {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromPhoto(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        self.presentViewController(pickerController, animated: true, completion: nil)
    }

    func setTextAttribut(textField : UITextField, str : String) {
        textField.delegate = self
        textField.text = str
        textField.textAlignment = .Center
        textField.defaultTextAttributes = memeTextAttribues
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //To erase the default text when editing
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == topText && topText.text == " TOP ") {
            topText.text = ""
        } else if (textField == botText && botText.text == " BOTTOM ") {
            botText.text = ""
        }
    }
    
    //Function that allows the user to use the return key to escape from the text input
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func generateMemedImage() -> UIImage
    {
        toolBar.hidden = true
        navBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolBar.hidden = false
        navBar.hidden = false
        
        return memedImage
    }
    
    func save() {
        let memedImage = generateMemedImage()
        //Create the meme
        var meme = Meme(topText: self.topText.text!, botText: self.botText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                //Save the image
                self.save()
                //Dismiss the view controller
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
    }
}
