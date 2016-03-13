//
//  PlayerViewController.swift
//  KDIC
//
//  Created by Shaun Mataire on 12/26/15.
//  Copyright © 2015 Colin Tremblay. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    
    
    @IBOutlet weak var playerButton: UIButton!
    
    @IBOutlet weak var djNameLable: UILabel!
    @IBOutlet weak var showNamelable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigation bar color
        self.navigationController!.navigationBar.barTintColor = UIColor.redColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        
        //let kdicScrapperReqs = KdicScrapperReqs(urlStr: "https://kdic-scrapper.herokuapp.com/blogs")
        //kdicScrapperReqs.makeApiCall()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func didPressPlayer(sender: AnyObject) {
        togglePlayer()
    }
    
    /**
     * Player controls
     **/
    func togglePlayer() {
        if KdicPlayer.sharedInstance.currentlyPlaying() {
            pauseRadio()
            playerButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
            
        } else {
            playRadio()
            playerButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
        }
    }
    
    func playRadio() {
        KdicPlayer.sharedInstance.play()
    }
    
    func pauseRadio() {
        KdicPlayer.sharedInstance.pause()
        
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
