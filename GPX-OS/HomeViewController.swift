//
//  HomeViewController.swift
//  GPX
//
//  Created by Bryan Andres Bolivar Martinez on 7/26/17.
//  Copyright © 2017 Bryan Andres Bolivar Martinez. All rights reserved.
//

import Cocoa
import CoreLocation
import MapKit

class HomeViewController: NSViewController, NSGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)

    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationAuthorizationStatus()

        let gestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.numberOfClicksRequired = 1
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)

    }

    
    func handleTap(gestureReconizer: NSClickGestureRecognizer) {
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)

        mapView.removeAnnotations(mapView.annotations )

        let artwork = Artwork(title: "King David Kalakaua",
                              locationName: "Waikiki Gateway Park",
                              discipline: "Sculpture",
                              coordinate: coordinate)
        mapView.addAnnotation(artwork)
        mapView.delegate = self
        centerMapOnLocation(location: initialLocation)

    }


    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldReceive touch: NSTouch) -> Bool {
        return true
    }


    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // MARK: - location manager to authorize user location for Maps app
    var location = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        location.delegate = self
        location.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
}

extension HomeViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Artwork {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                //view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }

}

class Artwork: NSObject, MKAnnotation {
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    var title: String?

    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.title = title
        super.init()
    }


}
