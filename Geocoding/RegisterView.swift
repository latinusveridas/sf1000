//
//  RegisterView.swift
//  Geocoding
//
//  Created by Quentin on 28/11/2018.
//  Copyright © 2018 Quentin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class RegisterView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.HideKeyboard()
    }
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func Register_Action(_ sender: Any) {
        
        RegisterRequest(firstname: firstNameField.text!, lastname: lastNameField.text!, email: emailField.text!, password: passwordField.text!) { response in
        
            if response != "0" {
                
                let alertController = UIAlertController(title: "Welcome", message: "Welcome to StreetFit", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController,animated: true,completion: nil)
                
            } else {
                
                let alertController = UIAlertController(title: "Failure", message: "You're register failed", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController,animated: true,completion: nil)
                
            }
            
        }
        
    }
    
    @IBAction func Dismiss_action(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
    
}

 // =========================== MAIN FUNCTIONS ==========================================    

func RegisterRequest (
    firstname:String,
    lastname:String,
    email: String,
    password: String,
    completion: @escaping (String) -> Void) {
    
    let payloadDict = [
        "first_name": firstname,
        "last_name": lastname,
        "email" : email,
        "password" : password
    ]
    
    guard let payLoad = try? JSONSerialization.data(withJSONObject: payloadDict, options: .prettyPrinted) else {return}
    
    let targetURL = "http://83.217.132.102:3000/auth/register"
    let url = URL(string: targetURL)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.httpBody = payLoad
    
    Alamofire.request(request).responseJSON { response in
        do {
            let decoder = JSONDecoder()
            let model = try decoder.decode(resStructRegister.self, from: response.data!)
            completion(String(model.data!.affectedRows!))
            
        } catch {
            print("Error on decoding")
            
        }
        
    }
    
}

struct resStructRegister: Codable {
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

struct dataSQL: Codable {
    let fieldCount: Int?
    let affectedRows: Int?
    let insertId: Int?
    let serverStatus: Int?
    let warningCount: Int?
    let message: String?
    let protocol41: Bool?
    let changedRows: Int?
}

extension UIViewController {
    
    func HideKeyboard(){
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        
        view.addGestureRecognizer(Tap)
        
    }
    
    @objc func DismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    
}
