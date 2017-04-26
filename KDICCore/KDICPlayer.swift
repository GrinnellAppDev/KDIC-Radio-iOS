import AVFoundation

private let streamURL = URL(string: "http://kdic.grinnell.edu/stream")!

open class KDICPlayer {
  static private(set) var isPlaying = false;
    
  private static var player: AVPlayer = freshPlayer()
    
  private class func freshPlayer() -> AVPlayer {
    let asset = AVURLAsset(url: streamURL)
    let playerItem = AVPlayerItem(asset: asset)
    return AVPlayer(playerItem: playerItem)
  }
  
  open class func live() {
    player = freshPlayer()
    unpause()
  }

  open class func unpause() {
    player.play()
    isPlaying = true
  }
  
  open class func pause() {
    player.pause()
    isPlaying = false
  }
  
  open class func toggle() {
    if isPlaying == true {
      pause()
    } else {
      unpause()
    }
  }
  
}
