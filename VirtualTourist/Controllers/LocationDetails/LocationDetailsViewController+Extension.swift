//
//  LocationDetailsViewController+Extension.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 04/02/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import UIKit
import MapKit
import CoreData
var count = 0
// MARK: - UICollectionViewDelegateFlowLayout

extension LocationDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        
        guard let aPicture = fetchedResultsController?.object(at: indexPath) else {
            return imageCell
        }
        
        // Configure image cell
        imageCell.backgroundColor = .lightGray
        imageCell.uiImage.image = nil
        imageCell.imageURL = aPicture.imageURL ?? ""
        imageCell.activityIndicator.startAnimating()
        
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let picture = fetchedResultsController?.object(at: indexPath) else { return }
        guard let imageCell = cell as? ImageCell else { return }
        
        if let uiImage = picture.image {
            imageCell.uiImage.image = uiImage
            imageCell.activityIndicator.stopAnimating()
        } else {
            self.downloadImage(from: imageCell.imageURL) { (imageData, errorString) in
                /* Check errors */
                guard errorString == nil else {
                    return self.displayError(errorString!)
                }
                guard let imageData = imageData else {
                    return self.displayError("No image data")
                }
                
                /* Create UIImage and set */
                let uiImageFromData = UIImage(data: imageData)
                DispatchQueue.main.async {
                    /* Configure Cell */
                    imageCell.uiImage.image = uiImageFromData
                    imageCell.activityIndicator.stopAnimating()
                    /* Save UIImage in bgContext */
                    CoreDataStack.sharedInstance.performBackgroundTask({ (bgContext) in
                        let bgPicture = bgContext.object(with: picture.objectID) as! Picture
                        bgPicture.image = uiImageFromData
                        try? bgContext.save()
                    })
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LocationDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize / 3, height: collectionViewSize / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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

// MARK: - NSFetchedResultsControllerDelegate

extension LocationDetailsViewController: NSFetchedResultsControllerDelegate {
    /* Create auxiliary arrays to updates */
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
    }
    
    /* Update local array with changes */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            insertedIndexPaths.append(newIndexPath)
        case .delete:
            guard let indexPath = indexPath else { return }
            deletedIndexPaths.append(indexPath)
        default:
            break
        }
    }
    
    /* Perform collection view changes */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
        }, completion: nil)
    }
}


// MARK: - Helpers

extension LocationDetailsViewController {
    func displayError(_ error: String) {
        // TODO: Show error to user
        print(error)
    }
    
    internal func saveViewContext() {
        CoreDataStack.sharedInstance.saveViewContext { (error) in
            guard error == nil else {
                self.displayError("Error to save data: \(error!.localizedDescription)")
                return
            }
        }
    }
    
    fileprivate func downloadImage(from url: String, completion: @escaping (_ data: Data?, _ errorString: String?) -> Void ) {
        /* Execute in background thread */
        DispatchQueue.global(qos: .background).async {
            guard let imageURL = URL(string: url) else {
                completion(nil, "Image URL error")
                return
            }
            
            if let imageData = try? Data(contentsOf: imageURL) {
                completion(imageData, nil)
            } else {
                completion(nil, "Image does not exist at \(String(describing: imageURL))")
                return
            }
        }
    }
}
