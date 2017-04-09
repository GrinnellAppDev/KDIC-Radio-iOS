import KDICCore
import AVKit

class PlayerViewController: UIViewController {
  var player: KDICPlayer!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!

  @IBAction func togglePlayerButtonWasTapped(_ sender: Any) {
    KDICPlayer.toggle()
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.imageView.image = UIImage(named: "Equalizer")
    
    button.setImage(imgShell1, forState:.Normal);
    button.setImage(coin, forState:.Highlighted);
    
    button.setBackgroundImage(resizeImageWithAspect(UIImage(data: data!)!,size:button.bounds.size), forState: .Normal);
    button.contentMode = UIViewContentMode.ScaleAspectFit;
    button.clipsToBounds = true;
    
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("About to play")
    KDICPlayer.play()
    print("Playing!")
  }
    
    func resizeImageWithAspect(image: UIImage,size: CGSize)->UIImage
    {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? size.width / oldWidth : size.height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSizeMake(newWidth, newHeight);
        
        if UIScreen.mainScreen().respondsToSelector(#selector(NSDecimalNumberBehaviors.scale)){
            UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.mainScreen().scale);
        }
        else
        {
            UIGraphicsBeginImageContext(newSize);
        }
        
        image.drawInRect(CGRectMake(0, 0, newSize.width, size.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    

}
