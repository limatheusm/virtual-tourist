
//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 25/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

extension FlickrClient {
    func getPhotos(from latitude: Double, _ longitude: Double, completion: @escaping (Result<[String: AnyObject]>) -> Void) {
        /* Set parameters */
        let parameters = [
            FlickrApi.Constants.ParameterKeys.BoundingBox: "FlickrApi.bboxString(from: latitude, longitude)",
            FlickrApi.Constants.ParameterKeys.SafeSearch: FlickrApi.Constants.ParameterValues.UseSafeSearch,
            FlickrApi.Constants.ParameterKeys.Extras: FlickrApi.Constants.ParameterValues.MediumURL,
            FlickrApi.Constants.ParameterKeys.Format: FlickrApi.Constants.ParameterValues.ResponseFormat,
            FlickrApi.Constants.ParameterKeys.NoJSONCallback: FlickrApi.Constants.ParameterValues.DisableJSONCallback
        ] as [String: AnyObject]
        
        /* Make the request */
        taskForGET(method: FlickrApi.Constants.ParameterValues.SearchMethod, parameters: parameters) { (result) in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completion(.Error(NSError(domain: "getPhotos", code: 1, userInfo: userInfo)))
            }
            
            switch result {
            case .Error(let error):
                sendError(error.localizedDescription)
                
            case .Success(let parsedResult):
                
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = parsedResult[FlickrApi.Constants.ResponseKeys.Status] as? String, stat == FlickrApi.Constants.ResponseValues.OKStatus else {
                    sendError("Flickr API returned an error.")
                    return
                }
                /* GUARD: Is "photos" key in our result? */
                guard let photosDictionary = parsedResult[FlickrApi.Constants.ResponseKeys.Photos] as? [String:AnyObject] else {
                    sendError("Cannot find keys '\(FlickrApi.Constants.ResponseKeys.Photos)' in \(String(describing: parsedResult))")
                    return
                }
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary[FlickrApi.Constants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                    sendError("Cannot find key '\(FlickrApi.Constants.ResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }
                
                if photosArray.count == 0 {
                    sendError("No Photos Found. Search Again.")
                    return
                } else {
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
//                    let photoTitle = photoDictionary[Constants.ResponseKeys.Title] as? String
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoDictionary[FlickrApi.Constants.ResponseKeys.MediumURL] as? String else {
                        sendError("Cannot find key '\(FlickrApi.Constants.ResponseKeys.MediumURL)' in \(photoDictionary)")
                        return
                    }
                    
                    // if an image exists at the url, set the image and title
//                    let imageURL = URL(string: imageUrlString)
//                    if let imageData = try? Data(contentsOf: imageURL!) {
//                        DispatchQueue.main.async {
//                            self.setUIEnabled(true)
//                            self.photoImageView.image = UIImage(data: imageData)
//                            self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//                        }
//                    } else {
//                        displayError("Image does not exist at \(String(describing: imageURL))")
//                    }
                }
            }
        }
    }
}

// MARK: - Helpers

extension FlickrClient {
    private func bboxString(from latitude: Double, _ longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - FlickrApi.Constants.SearchBBoxHalfWidth, FlickrApi.Constants.SearchLonRange.0)
        let minimumLat = max(latitude - FlickrApi.Constants.SearchBBoxHalfHeight, FlickrApi.Constants.SearchLatRange.0)
        let maximumLon = min(longitude + FlickrApi.Constants.SearchBBoxHalfWidth, FlickrApi.Constants.SearchLonRange.1)
        let maximumLat = min(latitude + FlickrApi.Constants.SearchBBoxHalfHeight, FlickrApi.Constants.SearchLatRange.1)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}
