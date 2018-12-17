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

    @IBOutlet weak var labelY: NSTextField!
    @IBOutlet weak var labelX: NSTextField!

    var annotations = [Artwork]()

    @IBOutlet weak var secondsPicker: NSPopUpButtonCell!
    @IBOutlet weak var clear: NSButton!

    @IBAction func clearData(_ sender: Any) {
        self.annotations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        labelY.stringValue = "--"
        labelX.stringValue = "--"
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationAuthorizationStatus()

        let gestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.numberOfClicksRequired = 1
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(gestureReconizer: NSClickGestureRecognizer) {
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)

        mapView.removeAnnotations(mapView.annotations)

        let artwork = Artwork(title: "",
                              locationName: "",
                              discipline: "",
                              coordinate: coordinate)

        annotations.append(artwork)

        mapView.delegate = self
        var locations = annotations.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        mapView?.addOverlay(polyline)


        mapView.addAnnotations(annotations)


        mapView.showAnnotations(annotations, animated: true)
        
        labelX.stringValue = "\(coordinate.latitude)"
        labelY.stringValue = "\(coordinate.longitude)"

        export()
    }


    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldReceive touch: NSTouch) -> Bool {
        return true
    }


    let regionRadius: CLLocationDistance = 1000


    // MARK: - location manager to authorize user location for Maps app
    var location = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        location.delegate = self
        location.startUpdatingLocation()
        mapView.showsUserLocation = true
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = NSColor.red
        renderer.lineWidth = 4.0

        return renderer
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = NSColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = NSColor.blue
            renderer.lineWidth = 2
            return renderer

        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = NSColor.orange
            renderer.lineWidth = 3
            return renderer
        }
        
        return MKOverlayRenderer()
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
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
            }
            return view
        }
        return nil
    }

    func export(){
        let file = "file.gpx"

        var text = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<gpx version=\"1.1\" creator=\"gpx-poi.com\">\n"


        let isoFormatter = ISO8601DateFormatter()

        let numberFormatter = NumberFormatter()

        var i = 10.0
        for annotation in annotations {
            i = i + (numberFormatter.number(from: (self.secondsPicker.selectedItem?.title)!)?.doubleValue)!
            text = text + "<wpt lat=\"\(annotation.coordinate.latitude)\" lon=\"\(annotation.coordinate.longitude)\">\n<time>\(isoFormatter.string(from: Date().addingTimeInterval(i)))</time>\n<name>mmm</name>\n</wpt>\n"
        }

        text = text + "</gpx>"

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let path = dir.appendingPathComponent(file)

            do {
                try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {}
            do {
                let _ = try String(contentsOf: path, encoding: String.Encoding.utf8)
            }
            catch {}
        }
    }

}

class Artwork: NSObject, MKAnnotation {
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let date = Date()
    var title: String?

    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.title = title
        super.init()
    }


}
