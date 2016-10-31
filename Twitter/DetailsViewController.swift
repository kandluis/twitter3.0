//
//  DetailsViewController.swift
//  Twitter
//
//  Created by Luis Perez on 10/30/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit
import AFNetworking

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
    var directMessage: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        display(tweet: tweet)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onFavoritePress(_ sender: Any) {
        favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "heart_colored"), for: .normal)
            favoriteLabel.text = String(tweet.favoritesCount + 1)
        
        TwitterClient.sharedInstance.markAsFavorite(tweet: tweet, success: updateTweet, failure: {(error: Error) -> Void in
            print("Could not favorite \(error.localizedDescription)")
            // Reset
        })
    }
    @IBAction func onRetweetPress(_ sender: Any) {
        if !tweet.retweeted {
            retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet_colored"), for: .normal)
            retweetLabel.text = String(tweet.retweetCount + 1)
            
            TwitterClient.sharedInstance.retweet(tweet: tweet, success: updateTweet, failure: {(error: Error) -> Void in
                print("Could not retweet \(error.localizedDescription)")
            })
        }
        else {
            retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet"), for: .normal)
            retweetLabel.text = String(tweet.retweetCount - 1)
            
            TwitterClient.sharedInstance.unretweet(tweet: tweet, success: updateTweet, failure: {(error: Error) -> Void in
                print("Could not unretweet \(error.localizedDescription)")
            })
        }
    }
    
    @IBAction func onReplyNavigation(_ sender: Any) {
        onReplyPress(sender)
    }
    @IBAction func onReplyPress(_ sender: Any) {
        performSegue(withIdentifier: "detailsToComposeSegue", sender: self)
    }
    @IBAction func onDirectMessage(_ sender: Any) {
        self.directMessage = true
        onReplyPress(sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let compose = navigationController.viewControllers[0] as! ComposeViewController
        compose.delegate = self
        compose.tweet = tweet
    }
    
    private func updateTweet(tweet: Tweet) {
        print("tweet updated")
        self.tweet = tweet
    }
    
    private func display(tweet: Tweet) {
        tweet.user?.setProfileImage(image: profileImageView)
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
                    print("sent reply!")
                }, failure: { (error: Error) in
                    print("failed to reply: \(error.localizedDescription)")
                })
            }
            else {
                TwitterClient.sharedInstance.newTweet(tweetText: text, tweet: tweet, success: { (tweet: Tweet) in
                    print("replied to tweet!")
                }, failure: { (error: Error) in
                    print("Failed to reply to tweet! Error \(error.localizedDescription)")
                })
            }
        }
    }
}
