//
//  ViewController.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeViewControllerDelegate, DetailsViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        client.homeTimeline(parameters: ["count": String(count + 20)], success: { (tweets: [Tweet]) in
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
    
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailsViewController {
            if let cell = sender as? UITableViewCell {
                if let indexPath = tableView.indexPath(for: cell) {
                    vc.tweet = tweets?[indexPath.row]
                    vc.delegate = self
                }
            }
        }
        if let root = segue.destination as? UINavigationController {
            if let compose = root.viewControllers[0] as? ComposeViewController {
                // Receive tweet text!
                compose.navigationItem.title = "Compose New Message"
                compose.delegate = self
            }
        }
        
     }
    
    func didFinishCompose(composer: ComposeViewController, didEnterText text: String?) {
        if let text = text {
            TwitterClient.sharedInstance.newTweet(tweetText: text, tweet: nil, success: {[unowned self] (tweet: Tweet) in
                self.insertTweet(tweet: tweet)
                }, failure: { (error: Error) in
                    presentNotification(parentViewController: self, notificationTitle: "New Tweet", notificationMessage: "Failed to post new tweet with error: \(error.localizedDescription)", completion: nil)
            })
        }
    }
    
    func didFinishNewTweet(details: DetailsViewController, newTweet: Tweet) {
        insertTweet(tweet: newTweet)
    }
    
    func didUpdateTweets(details: DetailsViewController, didUpdate: Bool) {
        if didUpdate {
            tableView.reloadData()
        }
    }
    
    private func insertTweet(tweet: Tweet){
        tweet.local = true
        tweets?.insert(tweet, at: 0)
        tableView.reloadData()
    }
    
    @IBAction func onCompose(_ sender: Any) {
        self.performSegue(withIdentifier: "composeSegue", sender: self)
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
}

