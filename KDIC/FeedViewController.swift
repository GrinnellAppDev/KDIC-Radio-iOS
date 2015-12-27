//
//  FeedViewController.swift
//  KDIC
//
//  Created by Shaun Mataire on 12/27/15.
//  Copyright © 2015 Colin Tremblay. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    @IBOutlet weak var feedWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let feedUrl = NSURL(string: "http://kdic.grinnell.edu")
        let request = NSURLRequest(URL: feedUrl!)
        feedWebView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
