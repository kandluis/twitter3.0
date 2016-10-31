//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Luis Perez on 10/29/16.
//  Copyright © 2016 Luis PerezBunnyLemon. All rights reserved.
//

import UIKit
import AFNetworking

let MAX_TWEET_CHARACTERS = 140

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var tweetCountBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = User.currentUser {
            usernameLabel.text = user.name
            handleLabel.text = user.handle
            if let url = user.profileImageUrl {
                userProfileImageView.setImageWith(url)
            }
        }
        
        // To update values at least once.
        textViewDidChange(messageTextView)
        
        messageTextView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically show text for input.
        messageTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        tweetCountBarButton.title = String(count)
        let color = (count > MAX_TWEET_CHARACTERS) ? UIColor.red : UIColor.lightGray
        tweetCountBarButton.setTitleTextAttributes([NSForegroundColorAttributeName : color], for: .normal)
    }
    
    @IBAction func onCancelPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSendPress(_ sender: Any) {
        let client = TwitterClient.sharedInstance
        
        if let text = messageTextView.text {
            client.newTweet(tweetText: text, success: {[unowned self] in
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error: Error) in
                // TODO (alert the user that the tweet failed to post -- retry later.
                print("error posting tweet \(error.localizedDescription)")
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
