//
//  MenuViewController.swift
//  KDIC
//
//  Created by Shaun Mataire on 12/27/15.
//  Copyright © 2015 Colin Tremblay. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuTable: UITableView!
    var menuItems: [String] = ["Schedule", "Feed", "Podcast", "Connect", "Settings",]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.menuTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "menuTableCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressCancelButton(sender: AnyObject) {
        let tmpController :UIViewController! = self.presentingViewController;
        
        self.dismissViewControllerAnimated(false, completion: {()->Void in
            print("done");
            tmpController.dismissViewControllerAnimated(false, completion: nil);
        });
    }
    
    //menu table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.menuTable.dequeueReusableCellWithIdentifier("menuTableCell")! as UITableViewCell
        
        cell.textLabel?.text = self.menuItems[indexPath.row]
        cell.textLabel?.font =  UIFont.systemFontOfSize(30)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //start appropriate segue
        switch indexPath.row{
        case 0:
            self.performSegueWithIdentifier("scheduleSegue", sender:self)
        case 1:
            self.performSegueWithIdentifier("feedSegue", sender:self)
        case 2:
            self.performSegueWithIdentifier("podcastSegue", sender:self)
        case 3:
            self.performSegueWithIdentifier("connectSegue", sender:self)
        case 4:
            self.performSegueWithIdentifier("settingsSegue", sender:self)
        default:
            print("error with menu cases")
        }
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
