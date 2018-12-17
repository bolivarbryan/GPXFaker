//
//  ViewController.swift
//  GPX
//
//  Created by Bryan Andres Bolivar Martinez on 7/26/17.
//  Copyright © 2017 Bryan Andres Bolivar Martinez. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var location = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        location.delegate = self
        location.allowsBackgroundLocationUpdates = true
        location.requestAlwaysAuthorization()
        location.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
}

