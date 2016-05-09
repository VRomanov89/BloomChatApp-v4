//
//  PasswordRecoveryVC.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/21/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import Firebase

class PasswordRecoveryVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: TextField1!
    @IBAction func sendEmailButton(sender: AnyObject) {
        if let email = emailField.text where email != ""{
            DataService.ds.REF_BASE.resetPasswordForUser(email, withCompletionBlock: {error in
                if error != nil {
                    if let errorCode = FAuthenticationError(rawValue: error.code) {
                        switch (errorCode) {
                        case .UserDoesNotExist:
                            print("Handle invalid user")
                            self.showErrorAlert("Invalid Email!", msg: "We were unable to find the email you've entered in our database. Please try again or enter a valid email.")
                        case .InvalidEmail:
                            print("Handle invalid email")
                        case .InvalidPassword:
                            print("Handle invalid password")
                        default:
                            print("Handle default situation")
                        }
                    }
                }else{
                    self.showErrorAlert("Password Recovered!", msg: "We've sent a new password to \(email).")
                    print("Password recovery successful. Email sent to \(email)")
                }
            })
        }else {
            showErrorAlert("Email Required", msg: "You must enter an email in the field above")
        }
    }
    
    // Cancel button - segue off.
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailField.delegate = self// Required to hide keyboard on "Return" key press
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard") // Recognize a screen tap in order to hide keyboard.
        view.addGestureRecognizer(tap)
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
}
