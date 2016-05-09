//
//  BusinessSelectionVC.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 4/2/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
//import Answers

class BusinessSelectionVC: UIViewController, CLLocationManagerDelegate {
    
    // The search button will display the Google search bar and allow the user to search independently from their location.
    @IBAction func searchButton(sender: Button1) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }
    
    var locationManager = CLLocationManager()
    var currentLoc = CLLocationCoordinate2D()
    var placePicker: GMSPlacePicker?
    var placeInfo = [String:String]()
    var displayOnce = Bool()
    var displayOnce2 = true
    var alertOnce = Bool()
    //Dictionary which holds ConversationID:BusinessID! Required to see if the user already has a conversation with the current business!
    var userCurrentConversations = [String:String]()
    var newConvoID = String()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidLoad()
        updateUserCurrentConversations()
        askUserForLocationPermission()
        if displayOnce2 == true {
            displayOnce = true
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidLoad() {
        alertOnce = true
    }
    
    //LOCATION HANDLING ---------------------------
    
    func askUserForLocationPermission(){
        // Ask for Authorisation from the User.
        if CLLocationManager.authorizationStatus() == .NotDetermined{
            self.locationManager.requestWhenInUseAuthorization()
            askUserForLocationPermission()
        }else if CLLocationManager.authorizationStatus() == .Denied {
            if(alertOnce == true){
            showErrorAlert("You've denied Location Services", msg: "Unfortunately, you must turn on location services in the application settings to be able to use this feature. Go to Settings > BloomChat > Location to enable this feature.")
                alertOnce = false
            }
        }else{
            //displayGoogleMap()
        }
    }
    func displayGoogleMap2(center: CLLocationCoordinate2D, dismiss: Bool){
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.002, center.longitude + 0.002)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.002, center.longitude - 0.002)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        self.placePicker = GMSPlacePicker(config: config)
        
        self.placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.placeInfo["name"] = place.name
                self.placeInfo["address"] = place.formattedAddress
                self.placeInfo["ID"] = place.placeID
                if place.types[0] != "" {
                    self.placeInfo["type"] = place.types[0]
                }else{
                    self.placeInfo["type"] = "unknown"
                }
                //self.startConversation()
                self.newBusinessQuery()
            } else {
                print("No place selected")
                if dismiss == true {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            
        })
    }
    
    func displayGoogleMap(dismiss: Bool){
        let center = self.currentLoc
        displayGoogleMap2(center, dismiss: dismiss)
    }
    
    func displayGoogleMap(businessID:CLLocationCoordinate2D, dismiss: Bool){
        let center = businessID
        displayGoogleMap2(center, dismiss: dismiss)
    }
    
    func locationManager(manager: CLLocationManager,didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLoc = locValue
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        if(displayOnce == true){
            displayGoogleMap(false)
            displayOnce = false
        }
    }
    
    //END LOCATION HANDLING
    
    // BEGIN - New Business Query Handling
    func newBusinessQuery() {
        
        //Step 1 - Test for existing business.
        let ref = DataService.ds.REF_BusinessListing
        ref.queryOrderedByKey().queryEqualToValue(self.placeInfo["ID"]).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                //Step 2 - Create a business listing
                print("creating listing")
                self.createNewBusinessListing()
                self.conversationInitiation()
            }else{
                //Step 3 - Business already exists! DO NOT CREATE ONE - Start conversation instead.
                print("creating convo")
                self.conversationInitiation()
            }
        })
    }
    
    //Step 2 - Create a business listing
    func createNewBusinessListing(){
        let business: Dictionary<String, AnyObject> = [
            "title": self.placeInfo["name"]!,
            "description": self.placeInfo["address"]!,
            "PlaceID": self.placeInfo["ID"]!,
            "type": self.placeInfo["type"]!
        ]
        DataService.ds.REF_BusinessListing.childByAppendingPath(self.placeInfo["ID"]).setValue(business)
    }
    
    func conversationInitiation() {
        var newConvoRequired = true
        for (convo, business) in userCurrentConversations {
            if business == self.placeInfo["ID"] {
                newConvoID = convo
                newConvoRequired = false
            }
        }
        if newConvoRequired == false {
            performSegueWithIdentifier("currentConvoFromBusiness", sender: self)
        }else {
            var newConvoID = createConversation(self.placeInfo["ID"]!)
            let firebaseNewUserConvo = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
            firebaseNewUserConvo.setValue(true)
            let firebaseNewBusinessConvo = DataService.ds.REF_BusinessListing.childByAppendingPath("\(self.placeInfo["ID"]!)").childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
            firebaseNewBusinessConvo.setValue(true)
            self.newConvoID = newConvoID
            performSegueWithIdentifier("currentConvoFromBusiness", sender: self)
        }
    }
    
    func updateUserCurrentConversations() {
        DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").observeEventType(.ChildAdded, withBlock: {snapshot in
            let firebaseUserConvos = DataService.ds.REF_CONVOS.childByAppendingPath("\(snapshot.key)").observeEventType(.Value, withBlock: {snapshot2 in
                if let businessIDpotential = snapshot2.value.objectForKey("to") {
                    self.userCurrentConversations[snapshot.key] = "\(businessIDpotential as! String)"
                }
            })
        })
    }
    
    func createConversation(to: String) -> String {
        let conversation: Dictionary<String, AnyObject> = [
            "to": to,
            "from": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String,
        ]
        let firebaseText = DataService.ds.REF_CONVOS.childByAutoId()
        firebaseText.setValue(conversation)
        var postId = firebaseText.key
        
        if postId != nil {
            return postId
        } else {
            return ""
        }
    }
    
    // END - New Business Query Handling
    
    
    
    
    
    
    // Alert Display Function
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: {
            self.displayOnce2 = false
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "currentConvoFromBusiness") {
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! MessagesFeedVC // 2
            chatVc.senderId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
            chatVc.senderDisplayName = "" // 4
            chatVc.convoID = newConvoID
            chatVc.convoTitle = self.placeInfo["name"]!
        }
    }

}

extension BusinessSelectionVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        self.displayGoogleMap(place.coordinate, dismiss: true)
        //self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}
