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
            scrollView.minimumZoomScale = 0.5
            scrollView.maximumZoomScale = 3.0
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
            scrollView?.zoomScale = zoomScaleToFit()
            scrollView?.contentSize = imageView.frame.size
            scrollView?.scrollRectToVisible(visibleRect(), animated: false)
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
    
    private func visibleRect() -> CGRect {
        var x: CGFloat = 0
        var y: CGFloat = 0
        // view.center.x = view.frame.width / 2
        // view.center.y = view.frame.height / 2
        if scrollView?.contentSize.width > view.frame.width {
            x = (scrollView?.contentSize.width)! / 2 - view.center.x
        } else {
            y = (scrollView?.contentSize.height)! / 2 - view.center.y
        }
        return CGRectMake(x, y, view.frame.width, view.frame.height)
    }
    
    private func zoomScaleToFit() -> CGFloat {
        if let aspectRatio = aspectRatio, imageSize = image?.size {
            if aspectRatio > Double(scrollView.frame.width / scrollView.frame.height) {
                return (scrollView.frame.height - topLayoutGuide.length) / imageSize.height
            } else {
                return scrollView.frame.width / imageSize.width
            }
        } else {
            return 1.0
        }
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
