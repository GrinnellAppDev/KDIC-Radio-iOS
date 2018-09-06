import UIKit
import Foundation

class KDICScrapperReqs{
    var urlStr: String
    var jsonDictionary: NSDictionary?
    var requestError : NSError?
    var requestResponse : URLResponse?
    var requestData : NSData?
    var tableView: UITableView?
    var completionCall: ()->()
    
    init(urlStr: String, tableView: UITableView, completionCall: @escaping ()->()){
        self.urlStr = urlStr
        self.tableView = tableView
        self.completionCall = completionCall
    }
    
    
    func get_data_from_url() {
        let timeout = 15.0
        let url = URL(string: urlStr)
        let urlRequest = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeout)
        
        let queue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue,
                                                 completionHandler: {(response: URLResponse?, data: Data?, error: Error?) in
                
                                                    if ((data!.count > 0) && (error == nil)){
                    do{
                        self.jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        
                        self.do_table_refresh()
                    }catch{
                        //MARK; handle exceptio
                    }
                }
                                                    else if ((data!.count == 0) && (error == nil)){
                    print("Nothing was downloaded")
                }
                else if (error != nil){
                                                        print("Error happened = \(error ?? "mysterious error" as! Error)")
                }
            }
        )
    }
    
    func do_table_refresh(){
        DispatchQueue.main.async {
            self.completionCall()
            self.tableView!.reloadData()
            return
        }
    }
}
