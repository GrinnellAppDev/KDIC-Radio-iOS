import UIKit

class ScheduleViewController: UIViewController ,  UITableViewDataSource {
    @IBOutlet weak var daySegmntCntrl: UISegmentedControl!
    
    var dayScheduleKeysArray = [String]()
    var dayScheduleValuesArray = [String]()
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    @IBOutlet weak var scheduleDataLoadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialTableData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayScheduleKeysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleTableCell
        
        let showTime = self.dayScheduleKeysArray[indexPath.row]
        let showName = self.dayScheduleValuesArray[indexPath.row]
        
        cell.showTime.text = showTime
        cell.showName.text = showName
        
        return cell
    }
    
    @IBAction func dayChanged(_ sender: Any) {
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
        
        /*
         FILL ME OUT !!!!!!!!!
         */
        
        self.dayScheduleKeysArray.append("5am")
        self.dayScheduleValuesArray.append("Where do we go from here?")
        
        scheduleDataLoadingIndicator.stopAnimating()
        scheduleDataLoadingIndicator.isHidden = true
        
        self.scheduleTableView.reloadData()
    }

}
