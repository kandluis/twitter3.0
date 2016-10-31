//
//  ViewController.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeViewControllerDelegate {
    
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
            print(error.localizedDescription)
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
                }
            }
        }
        if let root = segue.destination as? UINavigationController {
            if let compose = root.viewControllers[0] as? ComposeViewController {
                // Receive tweet text!
                compose.delegate = self
            }
        }
        
     }
    
    func didFinishCompose(composer: ComposeViewController, didEnterText text: String?) {
        if let text = text {
            TwitterClient.sharedInstance.newTweet(tweetText: text, tweet: nil, success: {[unowned self] (tweet: Tweet) in
                self.tweets?.insert(tweet, at: 0)
                }, failure: { (error: Error) in
                    // TODO (alert the user that the tweet failed to post -- retry later.
                    print("error posting tweet \(error.localizedDescription)")
                    self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func onCompose(_ sender: Any) {
        self.performSegue(withIdentifier: "composeSegue", sender: self)
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
}

