//
//  ViewController.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Auto-resize the cells.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // UIRefresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TweetsViewController.refreshAction), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // To show tweets.
        refreshAction(refreshControl: refreshControl)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
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
    
    func refreshAction(refreshControl: UIRefreshControl) {
        let client = TwitterClient.sharedInstance
        client.homeTimeline(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
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
        
     }
    
    @IBAction func onCompose(_ sender: Any) {
        self.performSegue(withIdentifier: "composeSegue", sender: self)
    }
}

