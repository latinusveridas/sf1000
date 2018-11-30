//
//  FirstViewController.swift
//  Geocoding
//
//  Created by Quentin on 18/11/2018.
//  Copyright © 2018 Quentin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class FirstViewController: UIViewController {
    
    @IBOutlet weak var Field_Address: UITextField!

    @IBAction func Action_Send(_ sender: Any) {
        var enteredAddress = Field_Address.text!
        
        SendGeoCoding(UserAddress: enteredAddress) { response in
            
            if response != "0" {
                let alertController = UIAlertController(title: "Success", message: "Posting succeed", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dimiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                
                let alertController = UIAlertController(title: "Fail", message: "Posting failed", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dimiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                
            }
            
        }
 
    }
    
    
    
    
}








func SendGeoCoding (UserAddress: String, completion: @escaping (String) -> Void) {
    
    // OUTPUT : VALIDATION OF THE POST THROUGH AFFECTED ROWS
    
    //PREPARATION OF REQUEST
    let payloadDict = [
        "address": UserAddress
    ]
    
    print(UserAddress)
    
    guard let payLoad = try? JSONSerialization.data(withJSONObject: payloadDict, options: .prettyPrinted) else {return}
    
    let targetURL = "http://83.217.132.102:3000/events/geo"
    let url = URL(string: targetURL)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.httpBody = payLoad
    
    Alamofire.request(request).responseJSON { response in
        print(response.result.value)
        do {
            
            let decoder = JSONDecoder()
            let model = try decoder.decode(resStructGeo.self, from: response.data!)
            
            completion(String(model.data!.affectedRows!))
            
        } catch {
            
            print("Error on decoding")
            
        }
        
        
        
    }
    
}

struct resStructGeo: Codable {
    let error: Int?
    let errorDescription: String?
    let typeData: String?
    let success: Int?
    let data: dataSQL?
    
    enum CodingsKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
        case typeData = "type_data"
        case success
        case data
    }
}


