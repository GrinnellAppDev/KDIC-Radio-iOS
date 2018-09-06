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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.articles.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogPostsCell", for: indexPath as IndexPath) as! BlogTableCell
        
        cell.article = articles[indexPath.row]
        
        cell.selectionStyle = .none;
        
        return cell
    }
    
}

extension BlogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let articleUrl = articles[indexPath.row].articleUrl
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: URL(string: articleUrl)!, entersReaderIfAvailable: true)
            
            self.present(svc, animated: true, completion: nil)
            
        } else {
            let url = URL(string: articleUrl)!
            UIApplication.shared.openURL(url)
        }
        
    }
}
