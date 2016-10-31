//
//  DetailsViewController.swift
//  Twitter
//
//  Created by Luis Perez on 10/30/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit
import AFNetworking

protocol DetailsViewControllerDelegate:class {
    func didFinishNewTweet(details: DetailsViewController, newTweet: Tweet)
    func didUpdateTweets(details: DetailsViewController, didUpdate: Bool)
}

class DetailsViewController: UIViewController, ComposeViewControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    
    var tweet: Tweet!
    weak var delegate: DetailsViewControllerDelegate?
    var directMessage: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.directMessage = false
        display(tweet: tweet)
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onFavoritePress(_ sender: Any) {
        if !tweet.favorited {
            favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "heart_colored"), for: .normal)
                favoriteLabel.text = String(tweet.favoritesCount + 1)
            
            TwitterClient.sharedInstance.markAsFavorite(tweet: tweet, success: updateTweet, failure: {(error: Error) -> Void in
                presentNotification(parentViewController: self, notificationTitle: "Favorite Failure", notificationMessage: "Failed to favorite the tweet with error: \(error.localizedDescription)", completion: nil)
            })
        }
        else {
            favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "heart"), for: .normal)
            favoriteLabel.text = String(tweet.favoritesCount - 1)
            TwitterClient.sharedInstance.unfavorite(tweet: tweet, success: updateTweet, failure: { (error: Error) in
                presentNotification(parentViewController: self, notificationTitle: "Favorite Failure", notificationMessage: "Failed to unfavorite the tweet with error: \(error.localizedDescription)", completion: nil)
            })
        }
    }
    @IBAction func onRetweetPress(_ sender: Any) {
        if !tweet.retweeted {
            retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet_colored"), for: .normal)
            retweetLabel.text = String(tweet.retweetCount + 1)
            
            TwitterClient.sharedInstance.retweet(tweet: tweet, success: updateTweet, failure: {(error: Error) -> Void in
                presentNotification(parentViewController: self, notificationTitle: "Retweet Failure", notificationMessage: "Failed to retweet the tweet with error: \(error.localizedDescription)", completion: nil)
            })
        }
        else {
            retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet"), for: .normal)
            retweetLabel.text = String(tweet.retweetCount - 1)
            
            TwitterClient.sharedInstance.unretweet(tweet: tweet, success: updateTweet, failure: {(error: Error) -> Void in
                presentNotification(parentViewController: self, notificationTitle: "Retweet Failure", notificationMessage: "Failed to unretweet the tweet with error: \(error.localizedDescription)", completion: nil)
            })
        }
    }
    
    @IBAction func onReplyNavigation(_ sender: Any) {
        onReplyPress(sender)
    }
    @IBAction func onReplyPress(_ sender: Any) {
        self.directMessage = false
        performSegue(withIdentifier: "detailsToComposeSegue", sender: self)
    }
    @IBAction func onDirectMessage(_ sender: Any) {
        self.directMessage = true
        performSegue(withIdentifier: "detailsToComposeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let compose = navigationController.viewControllers[0] as! ComposeViewController
        compose.navigationItem.title = (directMessage) ? "Compose Direct Message" : "Compose Reply"

        compose.delegate = self
        compose.tweet = tweet
    }
    
    // Only called on favorite and retweet.
    private func updateTweet(tweet: Tweet) {
        self.tweet.retweeted = tweet.retweeted
        self.tweet.retweet = tweet.retweet
        self.tweet.retweetCount = tweet.retweetCount
        
        self.tweet.favorited = tweet.favorited
        self.tweet.favoritesCount = tweet.favoritesCount
        
        self.delegate?.didUpdateTweets(details: self, didUpdate: true)
    }
    
    private func display(tweet: Tweet) {
        tweet.user?.setProfileImage(imageView: profileImageView)
        usernameLabel.text = tweet.user?.name
        handleLabel.text = tweet.user?.handle
        tweetTextLabel.text = tweet.text
        timestampLabel.text = tweet.detailedTimestamp()
        retweetLabel.text = String(tweet.retweetCount)
        favoriteLabel.text = String(tweet.favoritesCount)
        
        // Set images for tweet.
        if tweet.favorited {
            favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "heart_colored"), for: .normal)
        }
        if tweet.retweeted {
            retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet_colored"), for: .normal)
        }
    }
    
    func didFinishCompose(composer: ComposeViewController, didEnterText text: String?) {
        if let text = text {
            if directMessage {
                TwitterClient.sharedInstance.reply(tweet: tweet, withText: text, success: { (sentTweet: Tweet) in
                    self.delegate?.didFinishNewTweet(details: self, newTweet: sentTweet)
                    let _ = self.navigationController?.popViewController(animated: true)
                }, failure: { (error: Error) in
                    presentNotification(parentViewController: self, notificationTitle: "Message Failure", notificationMessage: "Failed to direct message with error: \(error.localizedDescription)", completion: {[unowned self] in
                        let _ = self.navigationController?.popViewController(animated: true)
                    })
                })
            }
            else {
                TwitterClient.sharedInstance.newTweet(tweetText: text, tweet: tweet, success: { (tweet: Tweet) in
                    self.delegate?.didFinishNewTweet(details: self, newTweet: tweet)
                    let _ = self.navigationController?.popViewController(animated: true)
                }, failure: { (error: Error) in
                    
                    presentNotification(parentViewController: self, notificationTitle: "Message Failure", notificationMessage: "Failed to reply to tweet with error: \(error.localizedDescription)", completion: {[unowned self] in
                        let _ = self.navigationController?.popViewController(animated: true)
                    })
                })
            }
        }
    }
}
