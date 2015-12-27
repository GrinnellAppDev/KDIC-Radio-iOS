//
//  KdicPlayer.swift
//  KDIC
//
//  Created by Shaun Mataire on 11/9/15.
//  Copyright © 2015 AppDev. All rights reserved.
//

import Foundation
import AVFoundation

class KdicPlayer {
    static let sharedInstance = KdicPlayer()
    
    private var player = AVPlayer(URL: NSURL(string: "http://kdic.grinnell.edu:8001/stream")!)
    private var isPlaying = false
    
    func play() {
        player.play()
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    func toggle() {
        if isPlaying == true {
            pause()
        } else {
            play()
        }
    }
    
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
    
}
