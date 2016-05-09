//
//  SignUpVC.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/20/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SignUpVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameField: TextField1!
    @IBOutlet weak var emailField: TextField1!
    @IBOutlet weak var passwordField: TextField1!
    @IBOutlet weak var confirmPasswordField: TextField1!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameField.delegate = self
        self.emailField.delegate = self// Required to hide keyboard on "Return" key press
        self.passwordField.delegate = self// Required to hide keyboard on "Return" key press
        self.confirmPasswordField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard") // Recognize a screen tap in order to hide keyboard.
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //Sign Up Button
    @IBAction func signUpButton(sender: AnyObject) {
        
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "", let pwd2 = confirmPasswordField.text{
            var validFieldsError = validFields(email, pass1: pwd, pass2: pwd2)
            if validFieldsError == 0 {
                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {error, authData in
                    if error != nil {
                        print(error)
                        if error.code == STATUS_ACCOUNT_NONEXIST { // If account is not valid, we will create one.
                            print("hi")
                            DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: {error, result in
                                if error != nil {
                                    self.showErrorAlert("Could not create account", msg: "Problem creating account, try something else.")
                                } else {
                                    NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                    DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil)
                                    DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                        let user = ["provider": authData.provider!] // Creates a disctionary for Firebase user creation.
                                        DataService.ds.createFirebaseUser(authData.uid, user: user) // Creates a user in Firebase after a facebook login has been made.
                                    })
                                    //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                            })
                        } else if error.code == STATUS_ACCOUNT_EMAILINVALID {
                            self.showErrorAlert("Invalid Email Address!", msg: "Please enter a valid email address.")
                        }
                    }
                })
            }else{
                switch validFieldsError{
                case 1: showErrorAlert("Invalid email.", msg: "Please enter a valid email address.")
                case 2: showErrorAlert("Password is too short.", msg: "Please enter a password of at least 8 characters.")
                case 3: showErrorAlert("Passwords do not match.", msg: "Please make sure that the passwords match in the fields above.")
                default:
                    break
                }
            }
            
        }else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and password")
        }
    }
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    func validFields(email: String, pass1: String, pass2: String) -> Int {
        if isValidEmail(email) == false{
            return 1
        }else if pass1.characters.count < 8 {
            return 2
        }else if pass1 != pass2 {
            return 3
        }else {
            return 0
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    
    // Cancel button - segue off.
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
 
    // Alert Function
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //Function which hides the keyboard on "Return" key press.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Function which hides keyboard on external key press
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 8.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }

}
