import UIKit
import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class EventsTableViewController: UITableViewController {
    
    var eventsList: [eventClass] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AlamoGetEvent{ eventsList in
            guard eventsList != nil else {return}
            self.eventsList = eventsList!
            self.tableView.reloadData()
        }
 
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func AlamoGetEvent (completion: @escaping ([eventClass]?) -> Void) {
        
        var targetURL = "http://83.217.132.102:3000/events/all"
        
        Alamofire.request(targetURL,method: .get)
            .validate()
            .responseJSON { response in
                print(response)
                
                guard response.result.isSuccess else {return completion(nil)}
                guard let rawInventory = response.result.value as? [[String:Any]?] else {return completion(nil)}
                
                let inventory = rawInventory.flatMap { EvenDict -> eventClass? in
                    var data = EvenDict!
                    return eventClass(data: data)
                }
                
                completion(inventory)
                
        }
        
    }
    
    
//////////////////DEBUG//////////
    @IBAction func DEBUG_action(_ sender: Any) {
        AlamoPicture{ myImage in
          
        }
    }
    
    
    
    func AlamoPicture(completion : @escaping (UIImage)-> Void) {
        
        print("in debug func")
        
        var firstPartURL = "http://83.217.132.102:3000/"
        
        //Conversion module
        var organizerID = eventsList[0].organizer
        
        var organizer_profile_picture = organizerID.replacingOccurrences(of: "_U_", with: "_UPP_")
        
        organizer_profile_picture = organizer_profile_picture + ".jpg"
        
        var OPP = firstPartURL + organizer_profile_picture
        
        print(OPP)

        Alamofire.request(OPP, method: .get).responseImage { response in
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            guard let image = response.result.value else {return}
            completion(image)
            
        }
            
        
        
    }
    
//////////////////DEBUG//////////
    
// ============================== TABLE FUNCTIONS ============================
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protoEventCell", for: indexPath) as! eventUICell
        cell.labelEvent_id.text = eventsList[indexPath.row].event_id
        cell.labelDate.text = eventsList[indexPath.row].date
        cell.labelLocation.text = eventsList[indexPath.row].location
        cell.labelSport.text = eventsList[indexPath.row].sport
        cell.labelSubscribed.text = "\(eventsList[indexPath.row].nb_part_sub)"
        cell.labelPart_max.text = "\(eventsList[indexPath.row].nb_part_max)"
        cell.labelPrice_max.text = "\(eventsList[indexPath.row].price_per_part)"
        if let organizerID = eventsList[indexPath.row].organizer
        //cell.UIImage_OPP.image = "\(eventsList[indexPath.row].organizerImage)"
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

// ================= CELL CONFIGURATION ================================
class eventUICell: UITableViewCell {
    
    @IBOutlet weak var labelEvent_id: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelSport: UILabel!
    @IBOutlet weak var labelSubscribed: UILabel!
    @IBOutlet weak var labelPart_max: UILabel!
    @IBOutlet weak var labelPrice_max: UILabel!
    @IBOutlet weak var UIImage_OPP: UIImageView!
    
}

// =========================== eventClass configuration ==============
public class eventClass {
    let event_id: String
    let date: String
    let location: String
    let sport: String
    let nb_part_sub : Int
    let nb_part_max : Int
    let price_per_part : Int
    let organizer : String
    //let organizerImage : Image
    
    init(data: [String:Any]) {
        self.event_id = data["event_id"] as! String
        self.date = data["date"] as! String
        self.location = data["location"] as! String
        self.sport = data["sport"] as! String
        self.nb_part_sub = data["nb_part_sub"] as! Int
        self.nb_part_max = data["nb_part_max"] as! Int
        self.price_per_part = data["price_per_part"] as! Int
        self.organizer = data["organizer"] as! String
        //self.organizerImage = data["organizerImage"] as Image
    }
    
}



