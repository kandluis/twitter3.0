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
    static let consumerKey: String = "33Sp8Lx26it146Eec7fHN6rWO"
    static let consumerSecret: String = "hpp2yHqULGuZ64FxhrNZKOPLW6R9ARxWpMSHNIEOAgREzZ2UzA"

    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: consumerKey, consumerSecret:consumerSecret)
    
    var loginSuccess: ((Void) -> Void)?
    var loginFailure: ((Error?) -> Void)?
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (_, response: Any?) in
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
