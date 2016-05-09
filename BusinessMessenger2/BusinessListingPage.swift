//
//  BusinessListingPage.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 3/19/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class BusinessListingPage: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var placesClient: GMSPlacesClient?
    var placePicker: GMSPlacePicker?
    var currentPlaceID = String()
    var placeInfo = [String:String]()
    var locationManager = CLLocationManager()
    var currentLoc = CLLocationCoordinate2D()
    var searchButtonPressed = false
    var newConvoID = String()
    //Dictionary which holds ConversationID:BusinessID! Required to see if the user already has a conversation with the current business!
    var userCurrentConversations = [String:String]()
    

    @IBOutlet weak var searchField: TextField1!
    
    @IBAction func searchButton(sender: AnyObject) {
        self.view.endEditing(true)
        if let searchText = searchField.text {
            placeAutocomplete(searchText)
        }else{
            print("Enter a search in the field above!")
        }
    }
    
    @IBAction func searchNearbyButton(sender: AnyObject) {
        
        // Ask for Authorisation from the User.
        if CLLocationManager.authorizationStatus() == .NotDetermined{
            self.locationManager.requestWhenInUseAuthorization()
            self.searchButtonPressed = true
        }else if CLLocationManager.authorizationStatus() == .Denied {
            showErrorAlert("You've denied Location Services", msg: "Unfortunately, you must turn on location services in the application settings to be able to use this feature. Go to Settings > BloomChat > Location to enable this feature.")
        }else{
        
        let center = self.currentLoc
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
                //print(place.types)
                //self.placeInfo["attributions"] = place.attributions
                //self.performSegueWithIdentifier("selectedBusiness", sender: self)
                self.startConversation()
            } else {
                print("No place selected")
            }

        })
        }
    }
        
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLoc = locValue
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if searchButtonPressed == true {
            searchNearbyButton(self)
            searchButtonPressed = false
        }
    }
    


    
    override func viewDidAppear(animated: Bool) {
        super.viewDidLoad()
        self.searchField.delegate = self// Required to hide keyboard on "Return" key press
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard") // Recognize a screen tap in order to hide keyboard.
        view.addGestureRecognizer(tap)
        
        searchField.delegate = self
        placesClient = GMSPlacesClient()
        updateUserCurrentConversations()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager,didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
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
    
    func searchFieldGoogle() {
        
    }
    
    func placeAutocomplete(searchString: String){
        var place = String()
        let filter = GMSAutocompleteFilter()
        filter.type = .Establishment
        placesClient?.autocompleteQuery(searchString, bounds: nil, filter: filter, callback: { (results, error: NSError?) -> Void in
            guard error == nil else {
                print("Autocomplete error \(error)")
                return
            }
            
            for result in results! {
                if self.currentPlaceID == "" {
                self.currentPlaceID = result.placeID!
                }
                print("\(self.currentPlaceID)")
            }
            self.placesClient!.lookUpPlaceID(self.currentPlaceID, callback: { (place: GMSPlace?, error: NSError?) -> Void in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                if let place = place {
                    print("Place coordinates \(place.coordinate)")
                    
                    let center = place.coordinate
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
                            //self.placeInfo["attributions"] = place.attributions

                            self.startConversation()

                            //self.performSegueWithIdentifier("selectedBusiness", sender: self)
                        } else {
                            print("No place selected")
                        }
                    })
                } else {
                    print("No place details for \(self.currentPlaceID)")
                }
            })
            
        })
    }
    
    func startConversation() {
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
            // Assuming the business does not exist yet!!! Will need to come back and create a verification.
            let newBusinessID = createNewBusinessListing()
            let newConvoID = createConversation(newBusinessID)
            print("business ID: \(newBusinessID) convo ID: \(newConvoID)")
            //2. IF the above ID is created successfully, create a reference to the conversation on the user & business side.
            if newConvoID != "" && "\(newBusinessID)" != "" {
                //Add a conversation reference from the user.
                let firebaseNewUserConvo = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
                firebaseNewUserConvo.setValue(true)
                //Add a conversation reference from the business.
                let firebaseNewBusinessConvo = DataService.ds.REF_BusinessListing.childByAppendingPath("\(newBusinessID)").childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
                firebaseNewBusinessConvo.setValue(true)
                self.newConvoID = newConvoID
                performSegueWithIdentifier("selectedBusiness2", sender: self)
            }else{
                print("Something went wrong... Failed to create conversation!")
            }
        }
        
    }
    
    
    
    
    func createNewBusinessListing() -> String {
        let business: Dictionary<String, AnyObject> = [
            "title": self.placeInfo["name"]!,
            "description": self.placeInfo["address"]!,
            "PlaceID": self.placeInfo["ID"]!,
            "type": self.placeInfo["type"]!
        ]
        let firebaseText = DataService.ds.REF_BusinessListing.childByAutoId()
        firebaseText.setValue(business)
        let postId = firebaseText.key
        if postId != nil {
            return postId
        } else {
            return ""
        }
    }
    
    func createConversation(to: String) -> String {
        let conversation: Dictionary<String, AnyObject> = [
            "to": to,
            "from": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String,
        ]
        let firebaseText = DataService.ds.REF_CONVOS.childByAutoId()
        firebaseText.setValue(conversation)
        let postId = firebaseText.key
        if postId != nil {
            return postId
        } else {
            return ""
        }
    }
    
    //Function used to update the user conversations as well as linked businesses stored in Firebase.
    func updateUserCurrentConversations() {
        DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").observeEventType(.ChildAdded, withBlock: {snapshot in
            // snapshot.key holds the ID of a conversation at this point.
            // We need to retrieve the associated businesslisting with this conversation!
            let firebaseUserConvos = DataService.ds.REF_CONVOS.childByAppendingPath("\(snapshot.key)").observeEventType(.Value, withBlock: {snapshot2 in
                //print("ID: \(snapshot2.value.objectForKey("to")!)")
                if let businessIDpotential = snapshot2.value.objectForKey("to") {
                    self.userCurrentConversations[snapshot.key] = "\(businessIDpotential as! String)"
                }
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectedBusiness") {
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! SelectedBusinessVC // 2
            chatVc.businessAddress = placeInfo["address"]!
            chatVc.businessPlaceID = placeInfo["ID"]!
            chatVc.businessName = placeInfo["name"]!
            chatVc.businessType = placeInfo["type"]!
        }else if(segue.identifier == "selectedBusiness2"){
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! MessagesFeedVC // 2
            chatVc.senderId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
            chatVc.senderDisplayName = "" // 4
            chatVc.convoID = newConvoID
            chatVc.convoTitle = placeInfo["name"]!
        }
    }
    
    // Alert Function
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}
