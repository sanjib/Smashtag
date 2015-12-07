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
    
    // Attributes for highlighting tweet text: hashtags, urls, and user mentions
    private struct Attributes {
        static let Hashtags = [
            // hex: FF 95 00
            NSForegroundColorAttributeName: UIColor.init(red: 0xFF/155, green: 0x95/255, blue: 0x00/255, alpha: 1.0)
        ]
        static let Urls = [
            // hex: 1D 62 F0
            NSForegroundColorAttributeName: UIColor.init(red: 0x1D/255, green: 0x62/255, blue: 0xF0/255, alpha: 1.0)
        ]
        static let UserMentions = [
            // hex: 4C D9 64
            NSForegroundColorAttributeName: UIColor.init(red: 0x4C/255, green: 0xD9/255, blue: 0x64/255, alpha: 1.0)
        ]
    }
    
    private func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from tweet (if any)
        if let tweet = tweet {
            
            // Tweet Text
            let tweetText = NSMutableAttributedString(string: tweet.text)
            tweetText.addAttributes(Attributes.Hashtags, indexedKeywords: tweet.hashtags)
            tweetText.addAttributes(Attributes.Urls, indexedKeywords: tweet.urls)
            tweetText.addAttributes(Attributes.UserMentions, indexedKeywords: tweet.userMentions)
            for _ in tweet.media {
                tweetText.appendAttributedString(NSAttributedString(string: " 📷"))
            }
            tweetTextLabel?.attributedText = tweetText
            
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

// An example of creating elegant code through private extensions
private extension NSMutableAttributedString {
    func addAttributes(attrs: [String : AnyObject], indexedKeywords: [Tweet.IndexedKeyword]) {
        for indexedKeyword in indexedKeywords {
            self.addAttributes(attrs, range: indexedKeyword.nsrange)
        }
    }
}