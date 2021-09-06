//
//  LocationService.swift
//  StepCountApp
//
//  Created by MAC105 on 25/08/21.
//

import UIKit
import CoreLocation
import CoreMotion
import Firebase
import FirebaseAnalytics

class LocationService: NSObject, CLLocationManagerDelegate{
    
    public static var sharedInstance = LocationService()
    let locationManager: CLLocationManager
    var timerForWalking = Timer()
    var firstLocation : CLLocation?
    var lastLocation : CLLocation?
    let pedometer = CMPedometer()
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0.5
        locationManager.activityType = .fitness
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
		locationManager.startMonitoringSignificantLocationChanges()
        super.init()
        locationManager.delegate = self
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if firstLocation == nil {
            firstLocation = locations.last
        }else {
            lastLocation = locations.last
        }
        self.startTimer()
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates")
    }
    
    func startTimer() {
        timerForWalking.invalidate()
        timerForWalking = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        self.checkPedometerIsAvailableOrNot()
        print("timerAction fireed")
    }
    
    func checkPedometerIsAvailableOrNot() {
        if CMPedometer.isStepCountingAvailable() {
            let calendar = Calendar.current
            guard let firstL = firstLocation, let lastL = lastLocation else {
                return
            }
            pedometer.queryPedometerData(from: calendar.startOfDay(for: firstL.timestamp), to: lastL.timestamp) { (data, error) in
                self.addCustomEventFor(steps: data!.numberOfSteps)
            }
            pedometer.startUpdates(from: firstL.timestamp) { (data, error) in
                self.addCustomEventFor(steps: data!.numberOfSteps)
            }
        }
    }
    
    func addCustomEventFor(steps : NSNumber)  {
        guard let firstL = firstLocation, let lastL = lastLocation else {
            return
        }
        var param : [String : Any] = [:]
        param["StartLocation"] = firstL
        param["lastLocation"] =  lastL
        param["NumberOfSteps"] =  steps
        Analytics.logEvent("Recording Event", parameters: param)
        timerForWalking.invalidate()
        firstLocation = nil
        lastLocation = nil
    }
}
