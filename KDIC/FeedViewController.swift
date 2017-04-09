import UIKit

class ScheduleViewController: UIViewController ,  UITableViewDataSource {
    @IBOutlet weak var daySegmntCntrl: UISegmentedControl!
    
    var dayScheduleKeysArray = [AnyObject]()
    var dayScheduleValuesArray = [AnyObject]()
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    @IBOutlet weak var scheduleDataLoadingIndicator: UIActivityIndicatorView!
    
    var scheduleUrlStr = "http://kdic.grinnell.edu/scheduleScript.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
    
    @IBAction func dayChanged(_ sender: AnyObject) {
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
    
    func loadTableData(_ day: String){
       // let scheduleDictionary = self.kdicScrapperReqs!.jsonDictionary!["data"]![day]! as! NSDictionary as Dictionary
        
      //  self.dayScheduleKeysArray = Array(scheduleDictionary.keys)
       // self.dayScheduleValuesArray = Array(scheduleDictionary.values)
        
        scheduleDataLoadingIndicator.stopAnimating()
        scheduleDataLoadingIndicator.isHidden = true
        
        self.scheduleTableView.reloadData()
    }


}
