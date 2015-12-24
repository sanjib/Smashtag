//
//  TweetCollectionViewCell.swift
//  Smashtag
//
//  Created by Sanjib Ahmad on 12/14/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

protocol TweetCollectionViewDataSource: class {
    func getCachedImage(sender: TweetCollectionViewCell) -> UIImage?
    func setCachedImage(sender: TweetCollectionViewCell)
}

class TweetCollectionViewCell: UICollectionViewCell {
    weak var dataSource: TweetCollectionViewDataSource?
    
    var mediaItem: MediaItem? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var image: UIImage? {
        didSet {
            imageView.image = image
            dataSource?.setCachedImage(self)
            activityIndicator?.stopAnimating()
        }
    }
    
    private func updateUI() {
        imageView?.image = nil
        
        if let mediaItem = mediaItem {
            if let image = dataSource?.getCachedImage(self) {
                self.image = image
            } else {
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                activityIndicator.startAnimating()
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    if let imageData = NSData(contentsOfURL: mediaItem.url) {
                        dispatch_async(dispatch_get_main_queue()) {
                            if mediaItem.url == self.mediaItem?.url {
                                self.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
