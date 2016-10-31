//
//  Tweet.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var id: String?
    var text: String?
    var createdAt: Date?
    var retweetCount: Int = 0
    var retweeted: Bool = false
    var retweet: Tweet?
    var favoritesCount: Int = 0
    var favorited: Bool = false
    var user: User?
    
    // A local-only tweet (ie, not from server).
    var local: Bool = false
    
    private var formatter = DateFormatter()
    
    init(dictionary: NSDictionary) {
        super.init()
        
        id = dictionary["id_str"] as? String
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        favorited = (dictionary["favorited"] as? Bool) ?? false
        if let userData = dictionary["user"] as? NSDictionary {
            user = User(dictionary: userData)
        }
        if let retweetData = dictionary["retweet_status"] as? NSDictionary {
            retweet = Tweet(dictionary:
                retweetData)
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
    
    private func getRetweet(tweetData: NSDictionary) {
        if let retweetId = getRetweetId(tweetData: tweetData) {
            TwitterClient.sharedInstance.getTweet(tweet_id: retweetId, success: {(tweet: Tweet) -> Void in
                self.retweet = tweet
            }, failure: { (error: Error) -> Void in
                print("Failed to retrieve retweets \(error.localizedDescription)")
            })
        }
        
    }
    
    // Recursively discovers the original tweet id_str.
    private func getRetweetId(tweetData: NSDictionary) -> String? {
        if let retweetData = tweetData["retweet_status"] as? NSDictionary {
            return getRetweetId(tweetData: retweetData)
        }
        else {
            return tweetData["id_str"] as? String
        }
    }
    
    func detailedTimestamp() -> String {
        formatter.dateFormat = "M/d/yyyy, hh:mm a"
        if let date = createdAt {
           return formatter.string(from: date)
        }
        else {
            return ""
        }
        
    }
    func timestamp() -> String {
        formatter.dateFormat = "M/d/yyyy"
        if let date = createdAt {
            let elapsedTime = date.timeIntervalSinceNow
            let ti = -Int(elapsedTime)
            let days = (ti / (60*60*25))
            let hours = (ti / (60*60)) % 24
            let minutes = (ti / 60) % 60
            let seconds = ti % 60
            if days > 3 {
                return formatter.string(from: date)
            }
            else if days > 0 {
                return "\(days) d"
            }
            else if hours > 0 {
                return "\(hours) h"
            }
            else if minutes > 0 {
                return "\(minutes) m"
            }
            else {
                return "\(seconds) s"
            }
        }
        else {
            return ""
        }
    }
}
