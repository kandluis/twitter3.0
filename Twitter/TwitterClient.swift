//
//  TwitterClient.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    static let consumerKey: String = "33Sp8Lx26it146Eec7fHN6rWO" // "LQuzgzLBbZXt64rThNnW72pHx" //
    static let consumerSecret: String = "hpp2yHqULGuZ64FxhrNZKOPLW6R9ARxWpMSHNIEOAgREzZ2UzA" // "OL5X9QImY03C5Av7KVMBSGL6uYIolbzH3RaePDQeIY4ruPgCOE" // 

    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: consumerKey, consumerSecret:consumerSecret)
    
    var loginSuccess: ((Void) -> Void)?
    var loginFailure: ((Error?) -> Void)?
    
    func homeTimeline(parameters: [String: String], success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (_, response: Any?) in
                if let tweetsArray = response as? [NSDictionary] {
                    success(Tweet.tweetsWithArray(dictionaries: tweetsArray))
                }
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            })
    }
    
    func currentAccount(success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (_, response: Any?) in
            if let userDictionary = response as? NSDictionary {
                success(User(dictionary: userDictionary))
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func login(success: @escaping (Void) -> Void, failure: @escaping ((Error?) -> Void)) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "mytwitter://oath"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) -> Void in
            if let token = requestToken?.token {
                let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")
                UIApplication.shared.open(url!)
            }
            else {
                print("Failed to extract token!")
            }
            
        }, failure: failure)
    }
    
    func logout() {
        deauthorize()
        User.currentUser = nil
        
        NotificationCenter.default.post(name: User.didLogoutNotification, object: nil)
    }
    
    func newTweet(tweetText text: String, tweet: Tweet?, success: @escaping (Tweet) -> Void , failure: @escaping (Error) -> Void) {
        post("1.1/statuses/update.json", parameters: [
            "status": text,
            "in_reply_to_status_id" : tweet?.id
            ], progress: nil, success: {(session: URLSessionDataTask, response: Any?) -> Void in
            if let tweetData = response as? NSDictionary {
                success(Tweet(dictionary: tweetData))
            }
            else {
                failure(NSError(domain: "New tweet response not parsable", code: 1, userInfo: nil))
            }
        }, failure: {(session: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func markAsFavorite(tweet: Tweet, success: @escaping (Tweet) -> Void , failure: @escaping (Error) -> Void){
        post("1.1/favorites/create.json", parameters: [ "id" : tweet.id ], progress: nil, success: {(session: URLSessionDataTask, response: Any?) -> Void in
            if let tweetData = response as? NSDictionary {
                success(Tweet(dictionary: tweetData))
            }
            else {
                failure(NSError(domain: "Favorite response not parsable", code: 1, userInfo: nil))
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func retweet(tweet: Tweet, success: @escaping (Tweet) -> Void , failure: @escaping (Error) -> Void){
        if let id = tweet.id {
            post("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: {(session: URLSessionDataTask, response: Any?) -> Void in
                if let tweetData = response as? NSDictionary {
                    success(Tweet(dictionary: tweetData))
                }
                else {
                    failure(NSError(domain: "Retweet response not parsable", code: 1, userInfo: nil))
                }
            }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure(error)
            })
        }
    }
    
    func unretweet(tweet: Tweet, success: @escaping (Tweet) -> Void , failure: @escaping (Error) -> Void){
        if let id = tweet.id {
            post("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: {(session: URLSessionDataTask, response: Any?) -> Void in
                if let tweetData = response as? NSDictionary {
                    success(Tweet(dictionary: tweetData))
                }
                else {
                    failure(NSError(domain: "Unretweet response not parsable", code: 1, userInfo: nil))
                }
            }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure(error)
            })
        }
    }
    
    func reply(tweet: Tweet, withText reply: String, success: @escaping (Tweet) -> Void , failure: @escaping (Error) -> Void){
        post("1.1/direct_message/new.json", parameters: [
            "user_id": tweet.user?.id,
            "screen_name": tweet.user?.screenName,
            "text": reply], progress: nil, success: {(session: URLSessionDataTask, response: Any?) -> Void in
            if let tweetData = response as? NSDictionary {
                success(Tweet(dictionary: tweetData))
            }
            else {
                failure(NSError(domain: "Unretweet response not parsable", code: 1, userInfo: nil))
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }

    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { [unowned self](credential: BDBOAuth1Credential?) in
            // Grab the current user.
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: {(error: Error) in
                self.loginFailure?(error)
            })
        }, failure: loginFailure)
    }
}
