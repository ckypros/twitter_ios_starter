//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Charles Kypros on 3/10/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    let tweetRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTweets()
        tweetRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = tweetRefreshControl
    }
    
    @objc func loadTweets() {
        numberOfTweets = 20
        getTweets()
        self.refreshControl?.endRefreshing()
    }
    
    func getTweets() {
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": numberOfTweets!] as [String : Any]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: params, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            
        }, failure: { Error in
            print("Error retrieving tweets")
        })
    }
    
    func loadMoreTweets() {
        numberOfTweets = numberOfTweets + 20
        getTweets()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= tweetArray.count - 3 {
            loadMoreTweets()
        }
    }

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
        
        let userData = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = userData["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageUrl = URL(string: (userData["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    // MARK: - Navigation

}
