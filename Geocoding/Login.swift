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

class LoginView: UIViewController {
    
    
    @IBOutlet weak var field_email: UITextField!
    @IBOutlet weak var field_password: UITextField!
    @IBAction func Action_Go(_ sender: Any) {
        AlamoLogin()
    }
    
    
    
    
    
    
// ====== Main functions ===================
    func AlamoLogin () {
        
        var targetURL = "http://83.217.132.102:3000/doubletoken/login"
        Alamofire.request(targetURL)
        .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Validation success")
                case .failure(let error):
                    print(error)
                }
                
        }
        
    }
    
    
}



