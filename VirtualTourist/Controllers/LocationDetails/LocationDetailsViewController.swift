//
//  LocationDetailsViewController.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 29/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import UIKit
import MapKit

class LocationDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var location: Location?
    
    // MARK: - View Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpLocation()
    }
    
    // MARK: - Class methods
    
    class func instanceFromStoryboard() -> LocationDetailsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LocationDetails") as! LocationDetailsViewController
        return controller
    }
    
    // MARK: - Set up methods
    
    fileprivate func setUpLocation() {
        guard let location = location else { return }
        mapView.addAnnotation(location)
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let latitudinalMeters: CLLocationDistance = 300000
        let longitudinalMeters: CLLocationDistance = 300000
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
        self.mapView.setRegion(region, animated: false)
    }
}

// MARK: MapKit Delegate

extension LocationDetailsViewController: MKMapViewDelegate {
    
    // MARK: MapKit Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let reuseId = "PinAnnotation"
        var pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinAnnotation == nil {
            pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinAnnotation?.pinTintColor = .blue
            pinAnnotation?.animatesDrop = true
        } else {
            pinAnnotation?.annotation = annotation
        }
        
        return pinAnnotation
    }
}
