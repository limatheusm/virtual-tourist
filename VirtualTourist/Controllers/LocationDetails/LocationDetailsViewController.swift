//
//  LocationDetailsViewController.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 29/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var location: Location?
    var fetchedResultsController: NSFetchedResultsController<Picture>?
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    
    // MARK: - View Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        setUpPictures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
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
    
    fileprivate func setUpPictures() {
        if fetchedResultsController?.fetchedObjects?.count == 0 {
            fetchAndStorePhotos()
        }
    }
    
    fileprivate func setUpFetchedResultsController() {
        guard let location = location else { return }
        let pictureFetchRequest: NSFetchRequest<Picture> = Picture.fetchRequest()
        pictureFetchRequest.predicate = NSPredicate(format: "location == %@", location)
        
        let sortDescriptor = NSSortDescriptor(key: "imageURL", ascending: false)
        pictureFetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: pictureFetchRequest, managedObjectContext: CoreDataStack.sharedInstance.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        fetchedResultsController?.delegate = self
    }
    
    // MARK: - Fetch and Store methods
    
    fileprivate func fetchAndStorePhotos() {
        activityIndicator.startAnimating()
        guard let location = location else { return }
        
        FlickrApiManager.sharedInstance.getPhotos(latitude: location.latitude, longitude: location.longitude) { (result) in
            switch result {
            case .failure(let errorMessage):
                self.displayError(errorMessage)
            case .success(let photos):
                print("size: \(photos.count)")
                self.storePhotos(photos)
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    fileprivate func storePhotos(_ photos: [Photo]) {
        // TODO: - Verificar se eh possivel fazer no BG
        for photo in photos {
            let picture = Picture(context: CoreDataStack.sharedInstance.viewContext)
            picture.image = nil
            picture.imageURL = photo.mediumURL
            picture.location = self.location
        }
        self.saveViewContext()
    }
}
