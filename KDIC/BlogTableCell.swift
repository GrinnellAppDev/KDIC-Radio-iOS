import KDICCore
import UIKit

class BlogTableCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fulltextLabel: UILabel!
    
    var article: KDICArticle! {
        didSet{
            self.titleLabel.text = article.title
            self.authorLabel.text = article.author
            self.dateLabel.text = "\(article.datePosted)"
            self.fulltextLabel.text = article.fulltext
        }
    }
}