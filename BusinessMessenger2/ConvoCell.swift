//
//  ConvoCell.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 1/1/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import JSQMessagesViewController

class ConvoCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newMessageLabel: UILabel!
    @IBOutlet weak var newMessageTime: UILabel!
    
    var convo: ConvoListing!
    var request: Request?
    static var imageCache = NSCache()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(convo: ConvoListing) {
        self.convo = convo
        if let title = convo.businessTitle{
            self.title.text = "\(title)"
        }
        self.newMessageLabel!.text = convo.newestMessage
        self.newMessageTime!.text = JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(convo.newestMessageTimestamp2).string
        
        //Updating the profile image.
        if let businessType = convo.businessType {
            switch (businessType) {
            case "unknown":
                self.profileImg.image = UIImage(named: "businessType_default")
            case "accounting":
                self.profileImg.image = UIImage(named: "businessType_accounting")
            case "amusement_park":
                self.profileImg.image = UIImage(named: "businessType_amusement_park")
            case "aquarium":
                self.profileImg.image = UIImage(named: "businessType_amusement_aquarium")
            case "bakery":
                self.profileImg.image = UIImage(named: "businessType_amusement_bakery")
            case "amusement_bank":
                self.profileImg.image = UIImage(named: "businessType_amusement_bank")
            case "bar":
                self.profileImg.image = UIImage(named: "businessType_bar")
            case "beauty_salon":
                self.profileImg.image = UIImage(named: "businessType_beauty_salon")
            case "bicycle_store":
                self.profileImg.image = UIImage(named: "businessType_bicycle_store")
            case "bowling_alley":
                self.profileImg.image = UIImage(named: "businessType_bowling_alley")
            case "cafe":
                self.profileImg.image = UIImage(named: "businessType_cafe")
            case "bowling_alley":
                self.profileImg.image = UIImage(named: "businessType_bowling_alley")
            case "car_dealer":
                self.profileImg.image = UIImage(named: "businessType_carDealer")
            case "car_repair":
                self.profileImg.image = UIImage(named: "businessType_carRepair")
            case "casino":
                self.profileImg.image = UIImage(named: "businessType_casino")
            case "clothing_store":
                self.profileImg.image = UIImage(named: "businessType_clothing_store")
            case "dentist":
                self.profileImg.image = UIImage(named: "businessType_dentist")
            case "doctor":
                self.profileImg.image = UIImage(named: "businessType_doctor")
            case "electrician":
                self.profileImg.image = UIImage(named: "businessType_electrician")
            case "electronics_store":
                self.profileImg.image = UIImage(named: "businessType_electronics_store")
            case "florist":
                self.profileImg.image = UIImage(named: "businessType_florist")
            case "funeral_home":
                self.profileImg.image = UIImage(named: "businessType_funeral_home")
                
                
            case "pharmacy":
                self.profileImg.image = UIImage(named: "businessType_pharmacy")
            
            
            
            case "dentist":
                self.profileImg.image = UIImage(named: "businessType_dentist")
            case "doctor":
                self.profileImg.image = UIImage(named: "businessType_doctor")
            case "grocery_or_supermarket":
                self.profileImg.image = UIImage(named: "businessType_grocery")
            case "gym":
                self.profileImg.image = UIImage(named: "businessType_gym")
            case "hair_care":
                self.profileImg.image = UIImage(named: "businessType_hairCare")
            case "laundry":
                self.profileImg.image = UIImage(named: "businessType_laundry")
            case "pharmacy":
                self.profileImg.image = UIImage(named: "businessType_pharmacy")
            default:
                self.profileImg.image = UIImage(named: "businessType_default")
                break
                
            }
        }
        
    }
}
