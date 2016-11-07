//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Luis Perez on 11/4/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var userTweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    var menuTitle = "Profile"
    
    var user: User?
    
    var tweets: [Tweet]?
    var isMoreDataLoading = false
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Auto-resize the cells.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // UIRefresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TweetsViewController.refreshAction), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // To show tweets.
        refreshAction()
        
        // Setup profile information
        setUpProfile()
        
    }
    
    private func setUpProfile() {
        let user  = self.user ?? User.currentUser!
        
        user.setProfileImage(imageView: userProfileImage)
        usernameLabel.text = user.name
        handleLabel.text = user.handle
        
        userTweetsLabel.text = String(user.tweetCount)
        followersLabel.text = String(user.followersCount)
        followingLabel.text = String(user.followingCount)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        cell.tweet = tweets![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func refreshAction() {
        let client = TwitterClient.sharedInstance
        let count = tweets?.count ?? 0
        var parameters = ["count": String(count + 20)]
        if let userId = user?.id {
            parameters["user_id"] = userId
        }
        if let username = user?.name {
            parameters["screen_name"] = username
        }
        client.userTweets(parameters: parameters, success: { (tweets: [Tweet]) in
            self.isMoreDataLoading = false
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }, failure: { (error: Error) in
            presentNotification(parentViewController: self, notificationTitle: "Network Request", notificationMessage: "Failed to retrieve new table data: \(error.localizedDescription)", completion: nil)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                refreshAction()
            }
        }
    }
    

}
