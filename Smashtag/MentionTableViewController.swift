//
//  MentionTableViewController.swift
//  Smashtag
//
//  Created by Sanjib Ahmad on 12/6/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class MentionTableViewController: UITableViewController {

    var tweet: Tweet? {
        didSet {
            if let tweet = tweet {
                title = tweet.user.name
                
                // Images
                if tweet.media.count > 0 {
                    var mediaItems = [Mention]()
                    for mediaItem in tweet.media {
                        mediaItems.append(Mention.Image(mediaItem))
                    }
                    addMentions(mediaItems)
                }
                
                // Hashtags
                if tweet.hashtags.count > 0 {
                    var hashtags = [Mention]()
                    for hashtag in tweet.hashtags {
                        hashtags.append(Mention.Hashtag(hashtag.keyword))
                    }
                    addMentions(hashtags)
                }
                
                // URLs
                if tweet.urls.count > 0 {
                    var urls = [Mention]()
                    for url in tweet.urls {
                        urls.append(Mention.URL(url.keyword))
                    }
                    addMentions(urls)
                }
                
                // Users
                var userMentions = [Mention]()
                userMentions.append(Mention.UserMention("@\(tweet.user.screenName)"))
                if tweet.userMentions.count > 0 {
                    for userMention in tweet.userMentions {
                        userMentions.append(Mention.UserMention(userMention.keyword))
                    }
                }
                addMentions(userMentions)
            }
        }
    }
    
    private var mentions = [[Mention]]()
    private func addMentions(mentionsToInsert: [Mention]) {
        mentions.insert(mentionsToInsert, atIndex: mentions.count)
    }
    
    private enum Mention {
        case Image(MediaItem)
        case Hashtag(String)
        case URL(String)
        case UserMention(String)
        
        var description: String {
            switch self {
            case .Image(let mediaItem):
                return mediaItem.url.absoluteString
            case .Hashtag(let hashtag):
                return hashtag
            case .URL(let url):
                return url
            case .UserMention(let userMention):
                return userMention
            }
        }
        
        var type: String {
            switch self {
            case .Image(_):
                return "Images"
            case .Hashtag(_):
                return "Hashtags"
            case .URL(_):
                return "URLs"
            case .UserMention(_):
                return "Users"
            }
        }
    }
    
    private struct Storyboard {
        static let ImageCellIdentifier = "Image Cell"
        static let TextCellIdentifier  = "Text Cell"
        static let TwitterSearchSegue  = "Twitter Search"
        static let ShowImageSegue      = "Show Image"
    }
    
    private struct Constants {
        static let GoldenRatio = (1 + sqrt(5.0))/2
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = mentions[indexPath.section][indexPath.row]
        switch mention {
        case .Image(_):
            return view.bounds.width / CGFloat(Constants.GoldenRatio)
        default:
            return UITableViewAutomaticDimension
        }        
    }

    // MARK: - UITableViewDatasource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].first!.type
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section][indexPath.row]
        
        switch mention {
        case .Image(let mediaItem):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath) as! MentionImageTableViewCell
            cell.mediaItem = mediaItem
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellIdentifier, forIndexPath: indexPath) as! MentionTextTableViewCell
            cell.mention = mention.description
            return cell
        }
    }

    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let indexPath = tableView.indexPathForSelectedRow {
            let mention = mentions[indexPath.section][indexPath.row]
            switch mention {
            case .URL(let urlString):
                if let url = NSURL(string: urlString) {
                    UIApplication.sharedApplication().openURL(url)
                }
                return false
            default: break
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case Storyboard.ShowImageSegue:
                if let ivc = segue.destinationViewController as? ImageViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let mention = mentions[indexPath.section][indexPath.row]
                        switch mention {
                        case .Image(let media):
                            ivc.imageURL = media.url
                            ivc.aspectRatio = media.aspectRatio
                        default: break
                        }
                    }
                }
            case Storyboard.TwitterSearchSegue:
                if let tvc = segue.destinationViewController as? TweetTableViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let mention = mentions[indexPath.section][indexPath.row]
                        tvc.setNewSearchRequest(mention.description)
                    }
                }
            default: break
            }
        }
    }

}
