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
        var enteredAddress = Field_Address.text
        AlamoLogin(address: enteredAddress!)
    }
    
    
    
    
}


func AlamoLogin(address: String) {
    
    var targetURL = "http://83.217.132.102:3000/events/geo"
    let parameters: Parameters = [
        "address": address
    ]
    
    Alamofire.request(targetURL, method: .post ,parameters: parameters, encoding: URLEncoding.httpBody)
        .validate()
        .responseString { response in
            print(response)
    }
    
    
    
}
