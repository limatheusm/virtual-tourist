//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 21/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var editableMode = false
    var longGesture: UILongPressGestureRecognizer!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureLongGesture()
    }
    
    // MARK: Actions
    @IBAction func editTapped(_ sender: Any) {
        let initialPosition = CGAffineTransform(translationX: 0, y: 0)
        let top = CGAffineTransform(translationX: 0, y: -70)
        
        setUIEditable(!editableMode)
        
        UIView.animate(withDuration: 0.3) {
            self.mapView.transform = self.editableMode ? top : initialPosition
        }
    }
    
    // MARK: User Interaction
    fileprivate func configureLongGesture() {
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longGesture.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(longGesture)
    }
}

// MARK: MapKit Delegate and Map functions
extension MapViewController: MKMapViewDelegate {
    
    // MARK: Map Functions
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func removeAnnotation(_ annotation: MKAnnotation) {
        mapView.removeAnnotation(annotation)
    }
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if editableMode {
            removeAnnotation(annotation)
            return
        }
        
        
    }
}

// MARK: Helpers
extension MapViewController {
    func setUIEditable(_ editable: Bool) {
        editableMode = editable
        
        if editableMode {
            editButton.title = "Done"
            editButton.style = .done
        } else {
            editButton.title = "Edit"
            editButton.style = .plain
        }
    }
}
