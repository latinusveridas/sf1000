//
//  EventDescription.swift
//  Geocoding
//
//  Created by Quentin on 29/11/2018.
//  Copyright © 2018 Quentin. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class EventDescriptionController: UIViewController {
    
    @IBOutlet weak var DescriptionMap: MKMapView!
    
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        LocationLabel.text = LocationData
        LatitudeLabel.text = LatitudeData
        LongitudeLabel.text = LongitudeData
        
        configureLocationServices()
        
    }
    
    
    private func configureLocationServices() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        
        print("STATUS IS: ",status.rawValue)
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        DescriptionMap.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    
    
    
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        DescriptionMap.setRegion(zoomRegion, animated: true)
    }
    
    
    
    var LocationData: String?
    var LatitudeData: String?
    var LongitudeData: String?
    
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var LatitudeLabel: UILabel!
    @IBOutlet weak var LongitudeLabel: UILabel!
    
    
}

extension EventDescriptionController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did get latest location")
        
        guard let latestLocation = locations.first else {return}
        
        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
        }
        
        
        currentCoordinate = latestLocation.coordinate
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("The status changed")
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
            
        }
        
    }
    
}
