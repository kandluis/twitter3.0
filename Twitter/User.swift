//
//  User.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit
import AFNetworking

class User: NSObject {
    
    var id: String?
    var name: String?
    var screenName: String?
    var profileImageUrl: URL?
    var tagline: String?
    
    var tweetCount: Int = 0
    var followingCount: Int = 0
    var followersCount: Int = 0

    
    var handle: String? {
        if let screenName = self.screenName {
            return "@\(screenName)"
        }
        return nil
    }
    
    var dictionary: NSDictionary!
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        
        // Deserialization.
        id = dictionary["id_str"] as? String
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let profileImageUrlString = dictionary["profile_image_url_https"] as? String {
            profileImageUrl = URL(string: profileImageUrlString)        }
        tagline = dictionary["description"] as? String
        tweetCount = (dictionary["statuses_count"] as? Int) ?? 0
        followersCount = (dictionary["followers_count"] as? Int) ?? 0
        followingCount = (dictionary["friends_count"] as? Int) ?? 0
        
    }
    
    func setProfileImage(imageView: UIImageView) {
        imageView.layer.cornerRadius = 3.0
        imageView.clipsToBounds = true
        
        if let profileImageUrl =
            profileImageUrl {
            imageView.image = nil
            let request = URLRequest(url: profileImageUrl)
            imageView.setImageWith(request, placeholderImage: #imageLiteral(resourceName: "anonymous"), success: { (request: URLRequest, response: HTTPURLResponse?, image: UIImage) in
                imageView.alpha = 0
                imageView.image = image
                UIView.animate(withDuration: 1, animations: { 
                    imageView.alpha = 1
                })
            }, failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) in
                print("Failed to set image. Error: \(error.localizedDescription)")
            })
        }
    }
    
    private static var _currentUser: User?
    static let didLogoutNotification = Notification.Name("UserDidLogout")
    
    class var currentUser: User? {
        get {
            if self._currentUser == nil {
                let defaults = UserDefaults.standard
                if let userData = defaults.object(forKey: "currentUserData") as? Data {
                    if let dictionary = (try! JSONSerialization.jsonObject(with: userData, options: [])) as? NSDictionary {
                        self._currentUser = User(dictionary: dictionary)
                    }
                }
            }
            return self._currentUser
        }
        
        set(user) {
            self._currentUser = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary, options: [])
                defaults.set(data, forKey: "currentUserData")
            }
            else {
                defaults.set(nil, forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
    
}
