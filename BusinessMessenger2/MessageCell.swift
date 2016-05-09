//
//  MessageCell.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/1/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var textMessage: UILabel!
    @IBOutlet weak var textMessageContainer: UIView!
    
    @IBOutlet weak var textMessageContainerContainer: UIView!
    
    var message: Message!

    override func awakeFromNib() {
        super.awakeFromNib()
        textMessage.numberOfLines = 0;
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(message: Message) {
        
        // Calculate the width of the screen.
        let screenSize: CGRect = UIScreen.mainScreen().bounds // Returns the screen size.
        let messageWidth: CGFloat = screenSize.width * 0.8 // Calculates 80% of the screen size.
        var messageWidthScreen:CGFloat = 0 // Initializes a value for the width of the text message.
        
        
        
        self.message = message
        self.textMessage.text = message.messageContent
        
        let labelWidth = textMessage.intrinsicContentSize().width //find the width of the string.
        if labelWidth < messageWidth {messageWidthScreen = labelWidth}else{messageWidthScreen = messageWidth} // Decide which width to use for the message based on which is smaller.
        
        //Create a constraint which stores the width for the mesage cell based on the calculation above.
        let messageCellWidth: NSLayoutConstraint = NSLayoutConstraint(item: textMessageContainer, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: messageWidthScreen + 16)
        self.textMessageContainer.addConstraint(messageCellWidth)
        
        
        /*if message.messageCellAlignment == true {
            let messageCellAlignRight: NSLayoutConstraint = NSLayoutConstraint(item: textMessageContainer, attribute: NSLayoutAttribute.TrailingMargin, relatedBy: NSLayoutRelation.Equal, toItem: textMessageContainerContainer.trailingAnchor, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1, constant: 0)
            self.textMessageContainer.addConstraint(messageCellAlignRight)
        }else{

        
        }*/
        //print(message.messageCellAlignment)
        
    }

}
