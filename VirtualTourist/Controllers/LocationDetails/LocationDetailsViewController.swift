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
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: - Properties
    
    var location: Location?
    var fetchedResultsController: NSFetchedResultsController<Picture>?
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var editable = false
    var pages: Int? = nil
    
    // MARK: - View Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.allowsMultipleSelection = true
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
    
    // MARK: - Actions
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        if editable {
            // Remove selected Pictures
            if let selectedIndexPathsPictures = collectionView.indexPathsForSelectedItems {
                deletePictures(from: selectedIndexPathsPictures)
                setUIEditableMode(false)
            }
        } else {
            // New Collection
            fetchNewCollection()
        }
    }
    
    // MARK: - Fetch, Store and Delete methods
    
    fileprivate func fetchAndStorePhotos() {
        setUILoading(true)
        guard let location = location else { return }
        
        FlickrApiManager.sharedInstance.getPhotos(latitude: location.latitude, longitude: location.longitude, pages: pages) { (result, pages) in
            switch result {
            case .failure(let errorMessage):
                self.displayError(errorMessage)
            case .success(let photos):
                self.pages = pages
                self.storePhotos(photos)
            }
            
            DispatchQueue.main.async {
                self.setUILoading(false)
            }
        }
    }
    
    fileprivate func storePhotos(_ photos: [Photo]) {
        for photo in photos {
            let picture = Picture(context: CoreDataStack.sharedInstance.viewContext)
            picture.image = nil
            picture.imageURL = photo.mediumURL
            picture.location = self.location
        }
        saveViewContext()
    }
    
    fileprivate func deletePictures(from indexPaths: [IndexPath]) {
        guard let fRC = fetchedResultsController else { return }
        for selectedIndexPath in indexPaths {
            let picToDelete = fRC.object(at: selectedIndexPath)
            CoreDataStack.sharedInstance.performViewTask { (viewContext) in
                viewContext.delete(picToDelete)
            }
        }
        saveViewContext()
    }
    
    fileprivate func deletePictures(_ pictures: [Picture]) {
        for picture in pictures {
            CoreDataStack.sharedInstance.performViewTask { (viewContext) in
                viewContext.delete(picture)
            }
        }
        saveViewContext()
    }
    
    fileprivate func fetchNewCollection() {
        guard let location = location else { return }
        guard let pictures = location.pictures else { return }
        setUILoading(true)
        deletePictures(pictures.allObjects as! [Picture])
        fetchAndStorePhotos()
    }
}
