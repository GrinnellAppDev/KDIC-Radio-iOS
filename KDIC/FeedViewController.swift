import UIKit

class ScheduleViewController: UIViewController ,  UITableViewDataSource {
    @IBOutlet weak var daySegmntCntrl: UISegmentedControl!
    
    var dayScheduleKeysArray = [AnyObject]()
    var dayScheduleValuesArray = [AnyObject]()
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    var kdicScrapperReqs: KDICScrapperReqs?
    
    @IBOutlet weak var scheduleDataLoadingIndicator: UIActivityIndicatorView!
    
    var scheduleUrlStr = "http://kdic.grinnell.edu/scheduleScript.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kdicScrapperReqs = KDICScrapperReqs(urlStr: scheduleUrlStr, tableView: scheduleTableView, completionCall: loadInitialTableData)
        self.kdicScrapperReqs?.get_data_from_url()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayScheduleKeysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleTableCell
        
        let showTime = self.dayScheduleKeysArray[indexPath.row] as! String
        let showName = self.dayScheduleValuesArray[indexPath.row] as! String
        
        cell.showTime.text = showTime
        cell.showName.text = showName
        
        return cell
    }
    
    @IBAction func dayChanged(sender: AnyObject) {
        switch daySegmntCntrl.selectedSegmentIndex
        {
        case 0:
            loadTableData(day: "Monday")
        case 1:
            loadTableData(day: "Tuesday")
        case 2:
            loadTableData(day: "Wednesday")
        case 3:
            loadTableData(day: "Thursday")
        case 4:
            loadTableData(day: "Friday")
        case 5:
            loadTableData(day: "Saturday")
        case 6:
            loadTableData(day: "Sunday")
        default:
            break; 
        }
    }
   
    //method called after asynch req is done
    func loadInitialTableData(){
        loadTableData(day: "Monday")
    }
    
    func loadTableData(day: String){
        
        let jsonDict = self.kdicScrapperReqs!.jsonDictionary! as! Dictionary<AnyHashable, Any>
        let jsonDict2 = jsonDict["data"]! as! Dictionary<AnyHashable, Any>
        let scheduleDictionary = jsonDict2[day] as! Dictionary<AnyHashable, Any>
        
        self.dayScheduleKeysArray = Array(scheduleDictionary.keys) as [AnyObject]
        self.dayScheduleValuesArray = Array(scheduleDictionary.values) as [AnyObject]
        
        scheduleDataLoadingIndicator.stopAnimating()
        scheduleDataLoadingIndicator.isHidden = true
        
        self.scheduleTableView.reloadData()
    }

}
