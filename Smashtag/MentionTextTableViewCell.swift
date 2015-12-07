//
//  MentionTextTableViewCell.swift
//  Smashtag
//
//  Created by Sanjib Ahmad on 12/7/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class MentionTextTableViewCell: UITableViewCell {

    var mention: Tweet.IndexedKeyword? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var mentionKeyword: UILabel!
    
    private func updateUI() {
        mentionKeyword?.text = mention?.keyword
    }
    
}
