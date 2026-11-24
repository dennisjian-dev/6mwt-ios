//
//  LocationManager.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/4/12.
//

import Foundation
import CoreLocation
class LocationManager: NSObject, CLLocationManagerDelegate{
    private let lm = CLLocationManager()
    private var latitude:CLLocationDegrees?
    private var longitude:CLLocationDegrees?
    private var altitude:CLLocationDegrees?
    override init(){
        super.init()
        lm.requestWhenInUseAuthorization()
        lm.requestAlwaysAuthorization()
        lm.delegate = self
    }
    func start(){
        lm.startUpdatingLocation()
    }
    func stop(){
        lm.stopUpdatingLocation()
    }
    func requestLocation(){
        self.lm.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        guard let location = locations.last else{
            return
        }
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
//        print("latitude \(location.coordinate.latitude)")
//        print("longitude \(location.coordinate.longitude)")
//        print("altitude \(location.altitude)")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
    func getLatitude()->String{
        if let latitude = self.latitude{
            return "\(latitude)"
        }
        return ""
    }
    func getLongitude()->String{
        if let longitude = self.longitude{
            return "\(longitude)"
        }
        return ""
    }
    func getAltitude()->String{
        if let altitude = self.altitude{
            return "\(altitude)"
        }
        return ""
    }
    
}
