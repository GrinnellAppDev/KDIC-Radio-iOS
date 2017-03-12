import UIKit
import AVFoundation

private let streamURL = URL(string: "http://kdic.grinnell.edu/stream")!

let kdicInstance = KDICPlayer();

private var isPlaying = false;

open class KDICPlayer {
  private static var player: AVPlayer = {
    let asset = AVURLAsset(url: streamURL)
    let playerItem = AVPlayerItem(asset: asset)
    // 
    return AVPlayer(playerItem: playerItem)
  }()
  
  
  open class func play() {
    player.play()
    isPlaying = true
  }
  
  open class func pause() {
    player.pause()
    isPlaying = false
  }
  
    /** to fix **/
  open class func toggle() {
    if isPlaying == true {
      pause()
    } else {
      play()
    }
  }
    
    open func currentlyPlaying() -> Bool {
        return isPlaying
    }
  
}
