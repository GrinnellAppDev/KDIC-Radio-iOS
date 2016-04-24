import UIKit

class BlogTableCell: UITableViewCell {
    
  
    @IBOutlet weak var blogPostTitle: UILabel!
    @IBOutlet weak var blogPostAuthor: UILabel!
    @IBOutlet weak var datePosted: UILabel!
    @IBOutlet weak var blogPostText: UILabel!
    
    var article: Article!{
        didSet{
            self.blogPostTitle.text = article.articleTitle
            self.blogPostAuthor.text = article.author
            self.datePosted.text = article.datePosted
            self.blogPostText.text = article.articleText
        }
    }
}