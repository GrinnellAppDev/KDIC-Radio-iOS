import Foundation

private let endpointURL = URL(string: "https://kdic-scrapper.herokuapp.com/blogs")!

open class KDICArticle {
  static var cache = Set<KDICArticle>()
  
  open let title: String
  open let author: String
  open let datePosted: Date
  open let fulltext: String?
  open let URL: Foundation.URL
  
  init(title: String, author: String, datePosted: Date, fulltext: String, URL: Foundation.URL) {
    self.title = title
    self.author = author
    self.datePosted = datePosted
    self.fulltext = fulltext
    self.URL = URL
  }
  
  convenience init(fromDictionary dict: NSDictionary) {
    self.init(title: "", author: "", datePosted: Date(), fulltext: "", URL:Foundation.URL(string:"")!) //TODO: Parse dictionary
  }
  
  
  open class func fetchArticles(_ completion:@escaping (([KDICArticle]?, Error?)->Void)) {
    URLSession().dataTask(with: endpointURL, completionHandler: { (data, _, error) in
      if let error = error {
        completion(nil, error)
      } else if let data = data {
        //let objects = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        print(data)
        // TODO: Convert JSON to Articles
        // TODO: Add articles to cache
        // TODO: Return articles to callback
      }
    }) 
  }
}

/*!
 * We know our URLs will be unique, so we can base article equality on that fact
 */
extension KDICArticle : Equatable {}

public func == (lhs: KDICArticle, rhs: KDICArticle) -> Bool {
  return lhs.URL == rhs.URL
}

extension KDICArticle : Hashable {
  public var hashValue: Int {
    return URL.hashValue
  }
}
