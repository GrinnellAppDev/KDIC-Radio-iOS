//
//  PlayerTabViewController.swift
//  KDIC
//
//  Created by Shaun Mataire on 12/26/15.
//  Copyright © 2015 Colin Tremblay. All rights reserved.
//

import UIKit

class PlayerTabViewController: UIViewController {

    @IBOutlet weak var radioControllButton: UIButton!
    
    @IBOutlet weak var playPauseImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func radioControlButtonDidPress(sender: UIButton) {
        togglePlayer()
    }
    
    //more actions
    @available(iOS 8.0, *)
    @IBAction func didPressMoreButton(sender: UIButton) {
        // Create the action sheet
        let myActionSheet = UIAlertController()
        
        // share action button
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default) { (action) in
            print("share")
        }
        
        // fav action button
        let favShowAction = UIAlertAction(title: "Favor Show", style: UIAlertActionStyle.Default) { (action) in
            print("fav")
        }
        
        // cancel action button
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
            //do nothing
        }
        
        // add action buttons to action sheet
        myActionSheet.addAction(shareAction)
        myActionSheet.addAction(favShowAction)
        myActionSheet.addAction(cancelAction)
        
        
        // present the action sheet
        self.presentViewController(myActionSheet, animated: true, completion: nil)
    }
    
    
    /**
     * Player controls
     **/
    func togglePlayer() {
        if KdicPlayer.sharedInstance.currentlyPlaying() {
            pauseRadio()
            playPauseImageView.image = UIImage(named: "playImage")
            
        } else {
            playRadio()
            playPauseImageView.image = UIImage(named: "pauseImage")
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
