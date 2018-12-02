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
import CoreLocation


class EventDescriptionController: UIViewController {
    
    @IBOutlet weak var DescriptionMap: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    let regionInMeters: Double = 10000
    var LocationData: String?
    var LatitudeData: String?
    var LongitudeData: String?
    
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var LatitudeLabel: UILabel!
    @IBOutlet weak var LongitudeLabel: UILabel!
    
    override func viewDidLoad() {
        LocationLabel.text = LocationData
        LatitudeLabel.text = LatitudeData
        LongitudeLabel.text = LongitudeData
        
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            DescriptionMap.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            DescriptionMap.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
    
    
    
}

extension EventDescriptionController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        DescriptionMap.setRegion(region, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

