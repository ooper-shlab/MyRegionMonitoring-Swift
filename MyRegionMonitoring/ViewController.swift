//
//  ViewController.swift
//  MyRegionMonitoring
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/5.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt.
//

//http://stackoverflow.com/questions/15590655/how-to-use-geo-based-push-notifications-on-ios

import UIKit
import CoreLocation

private let JS_LAT: CLLocationDegrees = 34.649394
private let JS_LON: CLLocationDegrees = 135.001478

private let REGION_RADIUS: CLLocationDistance = 300
private let coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: JS_LAT, longitude: JS_LON)
private let FILTERED_DISTANCE: CLLocationDistance = 10
private let ARRIVAL_DISTANCE: CLLocationDistance = 50

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var textField: UITextField!
    
    private let locationManger: CLLocationManager = CLLocationManager()
    private let region: CLCircularRegion = CLCircularRegion(center: coord, radius: REGION_RADIUS, identifier: "JS")
    
    private var notificationPresented: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManger.delegate = self
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            locationManger.requestAlwaysAuthorization()
        }
        
        if #available(iOS 9.0, *) {
            locationManger.allowsBackgroundLocationUpdates = true
        }
        locationManger.startMonitoring(for: region)
        
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.distanceFilter = FILTERED_DISTANCE
        locationManger.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NSLog(#function)
        locationManger.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog(#function)
        locationManger.stopUpdatingLocation()
        DispatchQueue.main.async {
            self.textField.text = "Exited"
        }
        notificationPresented = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog(#function)
        if let location = locations.last {
            if !self.region.contains(location.coordinate) {
                locationManger.stopUpdatingLocation()
                DispatchQueue.main.async {
                    self.textField.text = "Exited"
                }
                notificationPresented = false
            } else if !notificationPresented {
                if location.distance(from: CLLocation(latitude: JS_LAT, longitude: JS_LON)) < ARRIVAL_DISTANCE {
                    notificationPresented = true
                    let message = "Arrived at \(region.identifier) on \(Date())"
                    DispatchQueue.main.async {
                        self.textField.text = message
                    }
                    
                    let localNotification = UILocalNotification()
                    localNotification.alertBody = message
                    localNotification.alertAction = "Arrived at destination!"
                    localNotification.hasAction = true
                    UIApplication.shared.presentLocalNotificationNow(localNotification)
                } else {
                    let message = "Near \(region.identifier)"
                    DispatchQueue.main.async {
                        self.textField.text = message
                    }
                }
            }
        }
    }
}

