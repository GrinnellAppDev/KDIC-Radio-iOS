//
//  BlogUITableExtensionViewController.swift
//  KDIC
//
//  Created by Shaun Mataire on 4/24/16.
//  Copyright © 2016 Colin Tremblay. All rights reserved.
//

import UIKit
import SafariServices

extension BlogViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.articles.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BlogPostsCell", forIndexPath: indexPath) as! BlogTableCell
        
        cell.article = articles[indexPath.row]
        
        cell.selectionStyle = .None;
        
        return cell
    }
    
}

extension BlogViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let articleUrl = articles[indexPath.row].articleUrl
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: NSURL(string: articleUrl)!, entersReaderIfAvailable: true)
            
            self.presentViewController(svc, animated: true, completion: nil)
            
        } else {
            let url = NSURL(string: articleUrl)!
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
}