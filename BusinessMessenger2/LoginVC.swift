//
//  ViewController.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 12/21/15.
//  Copyright © 2015 EEEnthusiast. All rights reserved.
//
// TO DO LIST
// 1. Email verification - User Firebase (-8 = no account, -5
// 2. Password verification
// DONE 3. Keyboard closure
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {

    struct defaultsKeys {
        static let keyOne = "firstStringKey"
        static let keyTwo = "secondStringKey"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self// Required to hide keyboard on "Return" key press
        self.passwordField.delegate = self// Required to hide keyboard on "Return" key press
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard") // Recognize a screen tap in order to hide keyboard.
        view.addGestureRecognizer(tap)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Check performed to see if the user is already logged in
        print("\(NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID))")
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }

    // Facebook Login Button code wer rr
    @IBAction func fbBtnPressed(sender:UIButton!){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"]) {(facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            if facebookError != nil {
                print("Facebook login failed! Error \(facebookError)")
            }else{
                if let accessToken: FBSDKAccessToken = FBSDKAccessToken.currentAccessToken() {
                    print("Succesfully loged in. \(accessToken)")
                    DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken.tokenString, withCompletionBlock: {error, authData in
                        if error != nil {
                            print("Login Failed. \(error)")
                        }else {
                            print("Logged in. \(authData)")
                            let user = ["provider": authData.provider!] // Creates a disctionary for Firebase user creation.
                            DataService.ds.createFirebaseUser(authData.uid, user: user) // Creates a user in Firebase after a facebook login has been made.
                            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                            NSUserDefaults.standardUserDefaults().synchronize()
                            let test = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String
                            if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        }
                    })
                }
            }
        }
    }
    

    @IBAction func attemptLogin(sender: UIButton!) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {error, authData in
                if error != nil {
                print(error)
                    if error.code == STATUS_ACCOUNT_NONEXIST { // If account is not valid, we will create one.
                        //print("hi")
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: {error, result in
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account, try something else.")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil)
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                    let user = ["provider": authData.provider!] // Creates a disctionary for Firebase user creation.
                                    DataService.ds.createFirebaseUser(authData.uid, user: user) // Creates a user in Firebase after a password login has been made.
                                })
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                    } else if error.code == STATUS_ACCOUNT_EMAILINVALID {
                        self.showErrorAlert("Invalid Email Address!", msg: "Please enter a valid email address.")
                    }
                }else{
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                }
            })
        }else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and password")
        }
    }
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
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

