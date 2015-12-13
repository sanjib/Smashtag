//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Sanjib Ahmad on 12/8/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var spinner: UIActivityIndicatorView!    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
        }
    }
    private var imageView = UIImageView()
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            scrollView?.setZoomScale(scrollViewZoomScale, animated: false)
            scrollView?.setContentOffset(scrollViewcontentOffsetSize, animated: false)
            spinner?.stopAnimating()
        }
    }
    
    var imageURL: NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    var aspectRatio: Double?
    
    private func fetchImage() {
        if let imageURL = imageURL {
            spinner?.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if let imageData = NSData(contentsOfURL: imageURL) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if imageURL == self.imageURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.image = nil
                        }
                    }
                }
            }
        }
    }
    
    private var scrollViewcontentOffsetSize: CGPoint {
        if scrollView != nil {
            var x = scrollView.bounds.origin.x
            var y = scrollView.bounds.origin.y
            
            if scrollView.contentSize.width > scrollView.frame.width {
                x = (scrollView.contentSize.width - scrollView.frame.width) / 2
            } else {
                y = (scrollView.contentSize.height - scrollView.frame.height) / 2
            }
            return CGPointMake(x, y)
        }
        return CGPointZero
    }
    
    private var scrollViewZoomScale: CGFloat {
        if let scrollView = scrollView, aspectRatio = aspectRatio {
            
            let zoomToWidth = scrollView.frame.width / scrollView.contentSize.width
            let zoomToHeight = (scrollView.frame.height - topLayoutGuide.length - bottomLayoutGuide.length) / scrollView.contentSize.height
            
            if aspectRatio < Double(scrollView.frame.width / scrollView.frame.height) {
                scrollView.minimumZoomScale = zoomToHeight
                scrollView.maximumZoomScale = zoomToWidth * 2
                return zoomToWidth
            } else {
                scrollView.minimumZoomScale = zoomToWidth
                scrollView.maximumZoomScale = zoomToHeight * 2
                return zoomToHeight
            }
        }
        return 1
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
