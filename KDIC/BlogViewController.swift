import KDICCore
import SafariServices
import UIKit

class BlogViewController: UIViewController {
  @IBOutlet weak var blogPostTableView: UITableView!
  @IBOutlet weak var blogLoadActivityIndicator: UIActivityIndicatorView!
  
  var articles = [KDICArticle]()
}

extension BlogViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return articles.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BlogPostsCell", for: indexPath) as! BlogTableCell
    
    cell.article = articles[indexPath.row]
    
    cell.selectionStyle = .none;
    
    return cell
  }
  
}

extension BlogViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let articleUrl = articles[indexPath.row].URL
    if #available(iOS 9.0, *) {
      let svc = SFSafariViewController(URL: articleUrl, entersReaderIfAvailable: true)
      
      self.presentViewController(svc, animated: true, completion: nil)
      
    } else {
      UIApplication.sharedApplication().openURL(articleUrl)
    }
    
  }
}
