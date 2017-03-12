import UIKit
import AVFoundation

private let streamURL = URL(string: "http://kdic.grinnell.edu/stream")!

open class KDICPlayer {
  private static var player: AVPlayer = {
    let asset = AVURLAsset(url: streamURL)
    let playerItem = AVPlayerItem(asset: asset)
    return AVPlayer(playerItem: playerItem)
  }()
  
  open static var isPlaying = player.rate != 0
  
  open class func play() {
    player.play()
  }
  
  open class func pause() {
    player.pause()
  }
  
    /** to fix **/
  open class func toggle() {
    if isPlaying {
      pause()
    } else {
      play()
    }
  }
  
}
