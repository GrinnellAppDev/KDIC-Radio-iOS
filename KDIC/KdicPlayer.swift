import Foundation
import AVFoundation

public class KDICPlayer {
    static let sharedInstance = KDICPlayer()
    
    private var player = AVPlayer(URL: NSURL(string: "http://kdic.grinnell.edu:8001/stream")!)
    public private(set) var isPlaying = false
    
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
}
