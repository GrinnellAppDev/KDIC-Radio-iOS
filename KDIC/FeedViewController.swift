import UIKit

class ScheduleViewController: UIViewController ,  UITableViewDataSource {
    @IBOutlet weak var daySegmntCntrl: UISegmentedControl!
    
    var dayScheduleKeysArray = [AnyObject]()
    var dayScheduleValuesArray = [AnyObject]()
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    var kdicScrapperReqs: KdicScrapperReqs?
    
    @IBOutlet weak var scheduleDataLoadingIndicator: UIActivityIndicatorView!
    
    var scheduleUrlStr = "http://kdic.grinnell.edu/scheduleScript.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kdicScrapperReqs = KdicScrapperReqs(urlStr: scheduleUrlStr, tableView: scheduleTableView, completionCall: loadInitialTableData)
        self.kdicScrapperReqs?.get_data_from_url()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayScheduleKeysArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell", forIndexPath: indexPath) as! ScheduleTableCell
        
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
            loadTableData("Monday")
        case 1:
            loadTableData("Tuesday")
        case 2:
            loadTableData("Wednesday")
        case 3:
            loadTableData("Thursday")
        case 4:
            loadTableData("Friday")
        case 5:
            loadTableData("Saturday")
        case 6:
            loadTableData("Sunday")
        default:
            break; 
        }
    }
   
    //method called after asynch req is done
    func loadInitialTableData(){
        loadTableData("Monday")
    }
    
    func loadTableData(day: String){
        let scheduleDictionary = self.kdicScrapperReqs!.jsonDictionary!["data"]![day]! as! NSDictionary as Dictionary
        
        self.dayScheduleKeysArray = Array(scheduleDictionary.keys)
        self.dayScheduleValuesArray = Array(scheduleDictionary.values)
        
        scheduleDataLoadingIndicator.stopAnimating()
        scheduleDataLoadingIndicator.hidden = true
        
        self.scheduleTableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
