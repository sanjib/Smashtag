//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Sanjib Ahmad on 12/5/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    private func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from tweet (if any)
        if let tweet = tweet {
            
            tweetTextLabel?.text = tweet.text
            if tweetTextLabel?.text != nil {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    if let imageData = NSData(contentsOfURL: profileImageURL) {
                        dispatch_async(dispatch_get_main_queue()) {
                            // now that the imageData has been fetched over the network (maybe after a short delay)
                            // check if profileImageURL is still equal to the current object's profileImageURL
                            // correct check:   if profileImageURL == self.tweet?.user.profileImageURL
                            // incorrect check: if profileImageURL == tweet.user.profileImageURL
                            if profileImageURL == self.tweet?.user.profileImageURL {
                                self.tweetProfileImageView?.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
    }
    
    
}
