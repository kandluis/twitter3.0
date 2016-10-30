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
    
    var tweet: Tweet! {
        didSet {
            if let date = tweet.createdAt {
                let formatter = DateFormatter()
                formatter.dateFormat = "DD/MM/YY"
                tweetTimestampLabel.text = formatter.string(from: date)
            }
            tweetTextLabel.text = tweet.text
            tweetUserName.text = tweet.user?.screenName
            
            // Avoid cell reuse issues.
            tweetUserImage.image = nil
            if let imageURL = tweet.user?.profileImageUrl {
                tweetUserImage.setImageWith(imageURL)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
