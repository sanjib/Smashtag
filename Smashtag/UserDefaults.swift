//
//  UserDefaults.swift
//  Smashtag
//
//  Created by Sanjib Ahmad on 12/13/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import Foundation

class UserDefaults {
    static let sharedInstance = UserDefaults()
    private init() {}

    struct Constants {
        static let RecentSearchesKey = "RecentSearches"
        static let MaxSearchesToSave = 100
        static let DefaultRecentSearch = "#stanford"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - Recent Searches
    
    private var recentSearches: [String] {
        get {
            if let recentSearches = defaults.objectForKey(Constants.RecentSearchesKey) as? [String] {
                return recentSearches
            } else {
                return [String]()
            }
        }
        set {
            defaults.setObject(newValue, forKey: Constants.RecentSearchesKey)
            defaults.synchronize()
        }
    }
    
    var allRecentSearches: [String] {
        return recentSearches
    }
    
    var latestRecentSearch: String {
        if let latestSearch = recentSearches.first {
            return latestSearch
        } else {
            return Constants.DefaultRecentSearch
        }
    }
    
    func insertRecentSearch(searchQuery: String) {
        // Keep recent searches unique
        let matches = recentSearches.filter { $0 == searchQuery }
        if matches.first != nil {
            // it's enough to remove the first match, since we ensure only unique
            // searches are saved (matches will never contain more than 1 item)
            if let indexToRemove = recentSearches.indexOf(matches.first!) {
                recentSearches.removeAtIndex(indexToRemove)
            }
        }
        
        // Limit recent search save count
        if recentSearches.count >= Constants.MaxSearchesToSave {
            recentSearches.removeLast()
        }
        recentSearches.insert(searchQuery, atIndex: 0)
    }
    
    func removeRecentSearch(index: Int) {
        recentSearches.removeAtIndex(index)
    }
    
}