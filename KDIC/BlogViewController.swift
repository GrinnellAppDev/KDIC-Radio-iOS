import UIKit
import SafariServices

class BlogViewController: UIViewController{

    @IBOutlet weak var blogPostTableView: UITableView!
    
    var blogsDict: NSArray?
    
    var kdicScrapperReqs: KDICScrapperReqs?
    
    var blogJsonUrl = "https://kdic-scrapper.herokuapp.com/blogs"
    
    @IBOutlet weak var blogLoadActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        
        self.kdicScrapperReqs = KDICScrapperReqs(urlStr: blogJsonUrl, tableView: blogPostTableView, completionCall: getDataArray)
        
        self.kdicScrapperReqs!.get_data_from_url()
        
        
    }
    
    func getDataArray(){
        self.blogsDict = self.kdicScrapperReqs!.jsonDictionary!["articles"] as? NSArray;
        blogLoadActivityIndicator.stopAnimating()
        blogLoadActivityIndicator.hidden = true
    }

}
