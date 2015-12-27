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
    
    /**
     * Player controls
     **/
    func togglePlayer() {
        if KdicPlayer.sharedInstance.currentlyPlaying() {
            pauseRadio()
            radioControllButton.setImage(UIImage(named: "play_button"), forState: UIControlState.Normal)
            
        } else {
            playRadio()
            radioControllButton.setImage(UIImage(named: "pause_button"), forState: UIControlState.Normal)
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
