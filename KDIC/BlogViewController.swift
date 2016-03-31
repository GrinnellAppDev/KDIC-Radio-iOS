import UIKit
import SafariServices

class BlogViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var blogPostTableView: UITableView!
    
    var blogsDict: NSArray?
    
    var kdicScrapperReqs: KdicScrapperReqs?
    
    @IBOutlet weak var blogLoadActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        
        self.kdicScrapperReqs = KdicScrapperReqs(urlStr: "https://kdic-scrapper.herokuapp.com/blogs", tableView: blogPostTableView, completionCall: getDataArray)
        
        self.kdicScrapperReqs!.get_data_from_url()
        
        
    }
    
    func getDataArray(){
        self.blogsDict = self.kdicScrapperReqs!.jsonDictionary!["articles"] as? NSArray;
        blogLoadActivityIndicator.stopAnimating()
        blogLoadActivityIndicator.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.blogsDict == nil){
            return 0
        }
        else{
            return (self.blogsDict?.count)!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let articleUrl = blogsDict![indexPath.row]["articleUrl"] as! String
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: NSURL(string: articleUrl)!, entersReaderIfAvailable: true)
            
            self.presentViewController(svc, animated: true, completion: nil)
            
        } else {
            //MARK: Fallback on earlier versions
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BlogPostsCell", forIndexPath: indexPath) as! BlogTableCell
     
        let postTitle = blogsDict![indexPath.row]["articleTitle"] as! String
        let postAuther = blogsDict![indexPath.row]["author"] as! String
        let datePosted = blogsDict![indexPath.row]["datePosted"] as! String
        let postText = blogsDict![indexPath.row]["articleText"] as! String
        
        cell.blogPostAuthor.text = postAuther;
        cell.blogPostTitle.text = postTitle;
        cell.datePosted.text = datePosted;
        cell.blogPostText.text = postText;
        
        cell.selectionStyle = .None;
        
        return cell
    }
    
    
    /*
    // MARK: - Navigation

  as String   // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
