//
//  TweetCollectionViewController.swift
//  Smashtag
//
//  Created by Sanjib Ahmad on 12/22/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class TweetCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, TweetCollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    var tweets = [Tweet]()
    var mediaItems = [MediaItem]()
    let twitterRequestFetcher = TwitterRequestFetcher()
    
    private struct Storyboard {
        static let TweetImageCellIdentifier = "Tweet Image Cell"
        static let TweetSegueIdentifier     = "Show Tweet"
    }
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Items per Row
    
    private var itemsPerRow: CGFloat = 3
    private let maxItemsPerRow: CGFloat = 10
    private let minItemsPerRow: CGFloat = 1
    @IBAction func changeItemsPerRow(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            itemsPerRow = scaleToItemsPerRow(gesture.scale)
            collectionView.collectionViewLayout.invalidateLayout()
            gesture.scale = 1
        case .Ended:
            itemsPerRow = floor(itemsPerRow)
            collectionView.collectionViewLayout.invalidateLayout()
        default: break
        }
    }
    private func scaleToItemsPerRow(scale: CGFloat) -> CGFloat {
        let possibleItemsPerRow = (itemsPerRow / (scale))
        if possibleItemsPerRow > maxItemsPerRow {
            return maxItemsPerRow
        } else if possibleItemsPerRow < minItemsPerRow {
            return minItemsPerRow
        } else {
            return possibleItemsPerRow
        }
    }
    
    // MARK: - Cache
    
    private var cache = NSCache()
    
    func getCachedImage(sender: TweetCollectionViewCell) -> UIImage? {
        if let key = sender.mediaItem?.url, image = cache.objectForKey(key) as? UIImage {
            return image
        }
        return nil
    }
    
    func setCachedImage(sender: TweetCollectionViewCell) {
        if let key = sender.mediaItem?.url, image = sender.imageView?.image, data = UIImageJPEGRepresentation(image, 1.0) {
            let cost = data.length/1024
            cache.setObject(image, forKey: key, cost: cost)
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh control
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.alwaysBounceVertical = true
        collectionView?.addSubview(refreshControl)
        
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Search
    
    private func refresh() {
        refreshControl.beginRefreshing()
        refresh(refreshControl)
    }
    
    func refresh(sender: UIRefreshControl?) {
        if twitterRequestFetcher.searchText != nil {
            twitterRequestFetcher.fetchRequest { tweets in
                if tweets.count > 0 {
                    self.tweets += tweets
                    for tweet in tweets {
                        for mediaItem in tweet.media {
                            self.mediaItems.insert(mediaItem, atIndex: 0)
                        }
                    }
                    self.collectionView?.reloadData()
                }
                sender?.endRefreshing()
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = twitterRequestFetcher.searchText
        }
    }
    
    @IBAction func search() {
        refreshControl.beginRefreshing()
        textFieldShouldReturn(searchTextField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            twitterRequestFetcher.searchText = textField.text
            if twitterRequestFetcher.searchText != nil {
                UserDefaults.sharedInstance.insertRecentSearch(twitterRequestFetcher.searchText!)
            }
            cache.removeAllObjects()
            tweets.removeAll()
            mediaItems.removeAll()
            collectionView?.reloadData()
            refresh()
        }
        return true
    }
    
    // MARK: - Collection view delegates and data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.TweetImageCellIdentifier, forIndexPath: indexPath) as! TweetCollectionViewCell
        cell.dataSource = self
        cell.mediaItem = mediaItems[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Storyboard.TweetSegueIdentifier, sender: self)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth = view.bounds.size.width / itemsPerRow
        return CGSizeMake(itemWidth, itemWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.TweetSegueIdentifier {
            if let indexPath = collectionView.indexPathsForSelectedItems()?.first {
                let selectedMediaItem = mediaItems[indexPath.row]
                tweetLoop: for tweet in tweets {
                    for mediaItem in tweet.media {
                        if mediaItem.url == selectedMediaItem.url {
                            if let mtvc = segue.destinationViewController as? MentionTableViewController {
                                mtvc.tweet = tweet
                                break tweetLoop
                            }
                        }
                    }
                }
            }
        }
    }

}
