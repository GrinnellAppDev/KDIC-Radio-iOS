import KDICCore
import AVKit

class PlayerViewController: UIViewController {
  var player: KDICPlayer!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var button: UIButton!
  @IBAction func togglePlayerButtonWasTapped(_ sender: Any) {
    KDICPlayer.toggle()
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("About to play")
    KDICPlayer.live()
    print("Playing!")
  }
    

}
