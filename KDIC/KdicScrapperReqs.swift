import UIKit
import Foundation

class KdicScrapperReqs{
    var urlStr: String
    var jsonDictionary: NSDictionary?
    var requestError : NSError?
    var requestResponse : NSURLResponse?
    var requestData : NSData?
    var tableView: UITableView?
    var completionCall: ()->()
    
    init(urlStr: String, tableView: UITableView, completionCall: ()->()){
        self.urlStr = urlStr
        self.tableView = tableView
        self.completionCall = completionCall
    }
    
    
    func get_data_from_url() {
        let timeout = 15.0
        let url = NSURL(string: urlStr)
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeout)
        
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest( urlRequest, queue: queue,
            completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) in
                
                if ((data!.length > 0) && (error == nil)){
                    do{
                        self.jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        self.do_table_refresh()
                    }catch{
                        //MARK; handle exception
                    }
                }
                else if ((data!.length == 0) && (error == nil)){
                    print("Nothing was downloaded")
                }
                else if (error != nil){
                    print("Error happened = \(error)")
                }
            }
        )
    }
    
    func do_table_refresh(){
        dispatch_async(dispatch_get_main_queue(), {
            self.completionCall()
            self.tableView!.reloadData()
            return
        })
    }
}