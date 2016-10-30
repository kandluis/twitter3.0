//
//  Tweet.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text: String?
    var createdAt: Date?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?
    
    private var formatter = DateFormatter()
    
    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
        if let userData = dictionary["user"] as? NSDictionary {
            user = User(dictionary: userData)
        }
        
        if let timestampString = dictionary["created_at"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            
            createdAt = formatter.date(from: timestampString)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        return dictionaries.map({ (dict: NSDictionary) -> Tweet in
            Tweet(dictionary: dict)
        })
    }

}
