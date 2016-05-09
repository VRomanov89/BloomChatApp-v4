//
//  UserSettings.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 3/25/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import Firebase

class UserSettings: UIViewController {
    @IBAction func userLogout(sender: AnyObject) {
        DataService.ds.REF_BASE.unauth()
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
        self.performSegueWithIdentifier("userLogout", sender: nil)
    }

    @IBAction func changePsswordButton(sender: UIButton) {
        self.showErrorAlertV2("Enter a new password", msg: "Please enter an 8 character password in the field below", fieldPlaceholder: "Password", secure: true, email: false)
    }
    
    @IBAction func changeEmailButton(sender: UIButton) {
        self.showErrorAlertV2("Enter an email address", msg: "Please enter a valid email address in the field below", fieldPlaceholder: "Email address", secure: false, email: true)
    }
    @IBOutlet weak var userEmailField: TextField1!
    @IBOutlet weak var userPasswordField: TextField1!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Alert Function
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Alert Function
    func showErrorAlertV2(title: String, msg: String, fieldPlaceholder: String, secure: Bool, email: Bool) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        //let textField = UITextField
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = fieldPlaceholder
            textField.secureTextEntry = secure
        })
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            print(textField.text)
            if (email == true){
                if textField.text != nil {
                    self.changeEmail(textField.text!)
                }
            }else{
                if textField.text != nil {
                    self.changePassword(textField.text!)
                }
            }
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func changeEmail(email: String) {
        let ref = DataService.ds.REF_BASE
        let userCurrentEmail = userEmailField.text!
        let userCurrentPass = userPasswordField.text!
        ref.changeEmailForUser(userCurrentEmail,password: userCurrentPass, toNewEmail: email, withCompletionBlock: { error in
                if error != nil {
                    // There was an error processing the request
                    print(error)
                    if error.code == STATUS_ACCOUNT_EMAILINVALID {
                        self.showErrorAlert("Invalid Email Address!", msg: "Please enter a valid email address.")
                    }else if error.code == STATUS_ACCOUNT_NONEXIST {
                        self.showErrorAlert("Invalid Account Credentials!", msg: "Please verify the email and password you have entered!")
                    }else if error.code == STATUS_ACCOUNT_PASSWORDINVALID {
                        self.showErrorAlert("Invalid Password!", msg: "Please verify the password you have entered!")
                    }
                } else {
                    // Email changed successfully
                    self.showErrorAlert("Your email has been changed to \(email)", msg: "Use the new credentials to login.")
                }
        })
    }
    
    func changePassword(pass: String) {
        if pass.characters.count > 7 {
        let ref = DataService.ds.REF_BASE
        let userCurrentEmail = userEmailField.text!
        let userCurrentPass = userPasswordField.text!
        ref.changePasswordForUser(userCurrentEmail, fromOld: userCurrentPass, toNew: pass, withCompletionBlock: { error in
                if error != nil {
                    // There was an error processing the request
                    print(error)
                    if error.code == STATUS_ACCOUNT_EMAILINVALID {
                        self.showErrorAlert("Invalid Email Address!", msg: "Please enter a valid email address.")
                    }else if error.code == STATUS_ACCOUNT_NONEXIST {
                        self.showErrorAlert("Invalid Account Credentials!", msg: "Please verify the email and password you have entered!")
                    }else if error.code == STATUS_ACCOUNT_PASSWORDINVALID {
                        self.showErrorAlert("Invalid Password!", msg: "Please verify the password you have entered!")
                    }
                } else {
                    // Password changed successfully
                    self.showErrorAlert("Your password has been changed.", msg: "Use the new credentials to login.")
                }
        })
        }else{
            self.showErrorAlert("Invalid password", msg: "Please enter a password of at least 8 characters")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
