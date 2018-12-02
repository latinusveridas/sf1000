//
//  Login.swift
//  Geocoding
//
//  Created by Quentin on 18/11/2018.
//  Copyright © 2018 Quentin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class LoginView: UIViewController {
    
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        print("START DEBUG : Stored JWT2 in UserDefault Memory: ", defaults.string(forKey: "jwt2"))
    }

    
    
    @IBOutlet weak var field_email: UITextField!
    @IBOutlet weak var field_password: UITextField!
    
    @IBAction func Action_Go(_ sender: Any) {
        
        AlamoLogin(email: field_email.text!, password: field_password.text!) { jwt1 in
            let defaults = UserDefaults.standard
            defaults.set(jwt1, forKey: "jwt1")
            print("Stored JWT1 in UserDefault Memory: ", defaults.string(forKey: "jwt1")!)
        }
    }
    
    @IBAction func closebutton(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
    
    @IBAction func Action_Refresh(_ sender: Any) {
        
        let MemJwt1 = UserDefaults.standard.string(forKey: "jwt1")
        
        //FOR DEBUG IT WAS jwt1: MemJwt1!
        RefreshRequest(jwt1: MemJwt1!) { jwt2 in
            
            // Retrieve UserDefaults Data Object
            let defaults = UserDefaults.standard
            // Adding jwt2 data in UserDefaults
            defaults.set(jwt2, forKey: "jwt2")
            // Testing : Getting the UserDefault data stored in the memory
            print("Stored JWT2 in UserDefault Memory: ", defaults.string(forKey: "jwt2")!)
            
        }
        
    }
    
    @IBAction func Protected_Area_Action(_ sender: Any) {
        
        let MemJwt2 = UserDefaults.standard.string(forKey: "jwt2")
        
        ProtectedRequest(jwt2: MemJwt2!) { resJSON in
        print(resJSON)
            
            
        }
    
    }
    

// ======================================== Main functions ================================================

    
    func ProtectedRequest (jwt2: String, completion: @escaping ([String:Any]) -> Void) {
        let targetURL = "http://83.217.132.102:3000/auth/all"
        let url = URL(string: targetURL)!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue(jwt2, forHTTPHeaderField: "jwt2")
        
        Alamofire.request(request).responseJSON{ response in
            print(response)
            guard let json = response.result.value as? [String:Any] else {return}
            print(json.description)
            completion(json)

        }
    }
    
    func RefreshRequest (jwt1: String, completion: @escaping (String) -> Void) {
        
        let targetURL = "http://83.217.132.102:3000/auth/refresh"
        let url = URL(string: targetURL)!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue(jwt1, forHTTPHeaderField: "jwt1")
        
        Alamofire.request(request).responseJSON { response in
            
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(MainResStruct.self, from: response.data!)
                
                completion(model.data!.jwt2!)
                
                if model.success == 1 {
                    let alertController = UIAlertController(title: "Welcome", message: "Refreshed", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController,animated: true,completion: nil)
                }
                
            } catch {
                
                let alertController = UIAlertController(title: "Failure", message: "Refresh failed", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController,animated: true,completion: nil)
            }

        }
        
        
        
    }
    
    func AlamoLogin(email: String, password: String, completion: @escaping (String) -> Void) {
        
        let targetURL = "http://83.217.132.102:3000/auth/login"
        let payloadDict = [
            "email" : email,
            "password" : password
        ]
        
        guard let payLoad = try? JSONSerialization.data(withJSONObject: payloadDict, options: .prettyPrinted) else {return}
        //print(String(data: payLoad, encoding: String.Encoding.utf8))
        
        let url = URL(string: targetURL)!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = payLoad
        
        Alamofire.request(request).responseJSON { response in
            //print("MY RESPONSE IS: ", response)
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(MainResStruct.self, from: response.data!)
                
                //print(model)
                completion(model.data!.jwt1!)
                
                if model.success == 1 {
                    let alertController = UIAlertController(title: "Welcome", message: "You're logged", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController,animated: true,completion: nil)
                }
 
            } catch {
                let alertController = UIAlertController(title: "Failure", message: "You're logging failed", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController,animated: true,completion: nil)
            }
 
        }
        
    }
    

    
}


// =========================== Response Codable Structure ==============


struct MainResStruct: Codable {
    let error: Int
    let errorDescription: String
    let success: Int
    let typeData: String
    let data: AuthData?
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
        case success
        case typeData = "type_data"
        case data
    }
}

struct AuthData: Codable {
    let fieldCount: Int?
    let affectedRows: Int?
    let insertId: Int?
    let serverStatus: Int?
    let warningCount: Int?
    let message: String?
    let protocol41: Bool?
    let changedRows: Int?
    let jwt1 : String?
    let jwt2 : String?
    
    enum CodingKeys: String, CodingKey {
        case fieldCount
        case affectedRows
        case insertId
        case serverStatus
        case warningCount
        case message
        case protocol41
        case changedRows
        case jwt1 = "JWT1"
        case jwt2 = "JWT2"
    }
}




