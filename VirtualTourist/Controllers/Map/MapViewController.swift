//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 21/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var editableMode = false
    var longGesture: UILongPressGestureRecognizer!
    var fetchedResultsController: NSFetchedResultsController<Location>?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpLongGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: - SetUp functions
    
    fileprivate func setUpFetchedResultsController() {
        /* Create a fetch request for Location */
        let locationFetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        
        /* Create a sort descriptor */
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        locationFetchRequest.sortDescriptors = [sortDescriptor]
        
        /* Instantiate fetched results controller */
        fetchedResultsController = NSFetchedResultsController(fetchRequest: locationFetchRequest, managedObjectContext: CoreDataStack.sharedInstance.viewContext, sectionNameKeyPath: nil, cacheName: Location.Constants.CacheName)
        
        do { try fetchedResultsController?.performFetch() }
        catch { displayError("The fetch could not be performed: \(error.localizedDescription)") }
        
        fetchedResultsController?.delegate = self
        self.setUpAnnotations()
    }
    
    fileprivate func setUpAnnotations() {
        if let annotations = fetchedResultsController?.fetchedObjects {
            /* Populate the map */
            mapView.addAnnotations(annotations)
        }
    }
    
    fileprivate func setUpLongGesture() {
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longGesture.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(longGesture)
    }
    
    // MARK: - User Interaction
    
    @objc func longPressAction(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            addLocation(from: coordinate)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func editTapped(_ sender: Any) {
        let initialPosition = CGAffineTransform(translationX: 0, y: 0)
        let top = CGAffineTransform(translationX: 0, y: -70)
        
        setUIEditable(!editableMode)
        
        UIView.animate(withDuration: 0.3) {
            self.mapView.transform = self.editableMode ? top : initialPosition
        }
    }
    
    // MARK: - Location functions
    
    func addLocation(from coordinate: CLLocationCoordinate2D) {
        /* Create Managed Object */
        let location = Location(context: CoreDataStack.sharedInstance.viewContext)
        location.latitude = coordinate.latitude as Double
        location.longitude = coordinate.longitude as Double
        
        /* Save Context */
        saveViewContext()
    }
    
    func removeLocation(_ location: Location) {
        CoreDataStack.sharedInstance.viewContext.delete(location)
        saveViewContext()
    }
}

// MARK: - MapKit Delegate

extension MapViewController: MKMapViewDelegate {
    
    // MARK: - MapKit Delegate
    
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
        
        mapView.deselectAnnotation(annotation, animated: true)

        if editableMode {
            removeLocation(annotation as! Location)
            return
        }
        
        // MARK: - Navigate to image list view
        
        let locationDetailsVC = LocationDetailsViewController.instanceFromStoryboard()
        locationDetailsVC.location = annotation as? Location
        self.navigationController?.pushViewController(locationDetailsVC, animated: true)
    }
}

// MARK: - Fetched Results Controller Delegate

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        guard let location = anObject as? Location else {
            preconditionFailure("All changes observed in the map view controller should be for Location instances")
        }
        
        switch type {
            case .insert:
                mapView.addAnnotation(location)
            case .delete:
                mapView.removeAnnotation(location)
            default:
                break
        }
    }
}

// MARK: - Helpers

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
    
    func displayError(_ error: String) {
        // TODO: - Show error to user
        print(error)
    }
    
    fileprivate func saveViewContext() {
        CoreDataStack.sharedInstance.saveViewContext { (error) in
            guard error == nil else {
                self.displayError("Error to save annotation: \(error!.localizedDescription)")
                return
            }
        }
    }
}
