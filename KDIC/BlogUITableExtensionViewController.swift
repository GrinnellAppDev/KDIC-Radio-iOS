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
        
        if(self.blogsDict == nil){
            return 0
        }
        else{
            return (self.blogsDict?.count)!
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BlogPostsCell", forIndexPath: indexPath) as! BlogTableCell
        
        let postTitle = blogsDict![indexPath.row]["articleTitle"] as! String
        let postAuther = blogsDict![indexPath.row]["author"] as! String
        let datePosted = blogsDict![indexPath.row]["datePosted"] as! String
        let postText = blogsDict![indexPath.row]["articleText"] as! String
        
        cell.blogPostAuthor.text = postAuther;
        cell.blogPostTitle.text = postTitle;
        cell.datePosted.text = datePosted;
        cell.blogPostText.text = postText;
        
        cell.selectionStyle = .None;
        
        return cell
    }
    
}

extension BlogViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let articleUrl = blogsDict![indexPath.row]["articleUrl"] as! String
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: NSURL(string: articleUrl)!, entersReaderIfAvailable: true)
            
            self.presentViewController(svc, animated: true, completion: nil)
            
        } else {
            let url = NSURL(string: articleUrl)!
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
}