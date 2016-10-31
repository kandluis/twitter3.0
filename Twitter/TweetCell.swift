//
//  TweetCell.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var tweetUserImage: UIImageView!
    @IBOutlet weak var tweetUserName: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetTimestampLabel: UILabel!
    @IBOutlet weak var tweetUserHandle: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    
    var tweet: Tweet! {
        didSet {
            reset()
            displayTweet()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func displayTweet() {
        // Reload new data.
        tweetTextLabel.text = tweet.text
        tweetTimestampLabel.text = tweet.timestamp()
        tweetUserName.text = tweet.user?.name
        tweetUserHandle.text = tweet.user?.handle
        favoriteLabel.text = String(tweet.favoritesCount)
        retweetLabel.text = String(tweet.retweetCount)
        tweet.user?.setProfileImage(imageView: tweetUserImage)
        
        // Set images for tweet.
        if tweet.favorited {
            favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "heart_colored"), for: .normal)
        }
        if tweet.retweeted {
            retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet_colored"), for: .normal)
        }
        
        if tweet.local {
            let color = UIColor(displayP3Red: 26/255.0, green: 161/255.0, blue: 242.0/255.0, alpha: 0.3).cgColor
            UIView.animate(withDuration: 2.0, animations: {[unowned self] in
                self.contentView.layer.borderColor = color
                self.contentView.layer.borderWidth = 2
            })
            
        }
    }
    
    func reset() {
        // Clear previous data
        tweetTimestampLabel.text = ""
        tweetUserName.text = ""
        tweetTextLabel.text = ""
        tweetUserHandle.text = ""
        favoriteLabel.text = "0"
        retweetLabel.text = "0"
        
        contentView.layer.borderColor = nil
        contentView.layer.borderWidth = 0
        
        // reset images
        replyButton.setBackgroundImage(#imageLiteral(resourceName: "reply"), for: .normal)
        retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet"), for: .normal)
        favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "heart"), for: .normal)
    }

}
