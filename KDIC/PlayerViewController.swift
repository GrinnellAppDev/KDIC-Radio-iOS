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
           
    }

    @IBAction func didPressPlayer(sender: AnyObject) {
        togglePlayer()
    }
    
    func togglePlayer() {
        if KDICPlayer.sharedInstance.isPlaying {
            pauseRadio()
            playerButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
            
        } else {
            playRadio()
            playerButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
        }
    }
    
    func playRadio() {
        KDICPlayer.sharedInstance.play()
    }
    
    func pauseRadio() {
        KDICPlayer.sharedInstance.pause()
        
    }

}
