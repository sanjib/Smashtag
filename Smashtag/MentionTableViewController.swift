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
                if tweet.media.count > 0 {
                    var mediaItems = [Mention]()
                    for mediaItem in tweet.media {
                        mediaItems.append(Mention.Image(mediaItem))
                    }
                    addMentions(mediaItems)
                }
                if tweet.hashtags.count > 0 {
                    var hashtags = [Mention]()
                    for hashtag in tweet.hashtags {
                        hashtags.append(Mention.Hashtag(hashtag))
                    }
                    addMentions(hashtags)
                }
                if tweet.urls.count > 0 {
                    var urls = [Mention]()
                    for url in tweet.urls {
                        urls.append(Mention.URL(url))
                    }
                    addMentions(urls)
                }
                if tweet.userMentions.count > 0 {
                    var userMentions = [Mention]()
                    for userMention in tweet.userMentions {
                        userMentions.append(Mention.UserMention(userMention))
                    }
                    addMentions(userMentions)
                }
            }
        }
    }
    
    private var mentions = [[Mention]]()
    private func addMentions(mentionsToInsert: [Mention]) {
        mentions.insert(mentionsToInsert, atIndex: mentions.count)
    }
    
    private enum Mention {
        case Image(MediaItem)
        case Hashtag(Tweet.IndexedKeyword)
        case URL(Tweet.IndexedKeyword)
        case UserMention(Tweet.IndexedKeyword)
        
        var indexedKeyword: Tweet.IndexedKeyword? {
            switch self {
            case .Image(_):
                return nil
            case .Hashtag(let hashtag):
                return hashtag
            case .URL(let url):
                return url
            case .UserMention(let userMention):
                return userMention
            }
        }
        
        var description: String {
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
        static let ShowImageSegue      = "Show Image"
    }
    
    private struct Constants {
        static let GoldenRatio = (1 + sqrt(5.0))/2
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return mentions[section].first!.description
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
            cell.mention = mention.indexedKeyword
            return cell
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ShowImageSegue {
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
        }
    }

}
