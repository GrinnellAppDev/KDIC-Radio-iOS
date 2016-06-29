import UIKit
import SafariServices

class BlogViewController: UIViewController {
    
    @IBOutlet weak var blogPostTableView: UITableView!
    
    var articles = [Article]()
    
    var kdicScrapperReqs: KDICScrapperReqs?
    
    var blogJsonUrl = "https://kdic-scrapper.herokuapp.com/blogs"
    
    @IBOutlet weak var blogLoadActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        
        self.kdicScrapperReqs = KDICScrapperReqs(urlStr: blogJsonUrl, tableView: blogPostTableView, completionCall: getDataArray)
        
        self.kdicScrapperReqs!.get_data_from_url()
        
    }
    
    func getDataArray(){
        if let articlesArray = kdicScrapperReqs!.jsonDictionary!["articles"] as? Array<Dictionary<String, String>> {
            for articleDict in articlesArray {
                let article = Article(articleDict)
                self.articles.append(article)
                
            }
        }
        blogLoadActivityIndicator.stopAnimating()
        blogLoadActivityIndicator.hidden = true
    }
    
}
