//
//  NetworkManager.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

enum NetworkResponse: String {
    case success
    case authenticationError = "You need to be authenticated first"
    case badRequest = "Bad request"
    case outdated = "The url you requested is otdated"
    case failed = "Network request failed"
    case noData = "Response returned with no data to decode"
    case unableToDecode = "We could not decode the response"
    case poorNetworkConnection = "Please check your network connection"
    case okStatusNotFound = "Flickr API returned an error"
}

enum Result<T> {
    case success(T)
    case failure(String)
}

final class FlickrApiManager {
    
    // MARK: - Singleton
    static let sharedInstance = FlickrApiManager()
    private init () { }
    
    static let environment: NetworkEnvironment = .production
    static let FlickrAPIKey = FlickrApi.Constants.ParameterValues.APIKey
    private let router = Router<FlickrApi>()
    
    // MARK: - Convenience methods
    
    func getPhotos(latitude: Double, longitude: Double, completion: @escaping (_ result: Result<[Photo]>) -> Void) {
        router.request(.getPhotos(latitude: latitude, longitude: longitude)) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(.failure(NetworkResponse.poorNetworkConnection.rawValue))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkResponse.failed.rawValue))
                return
            }
            
            let result = self.handleNetworkResponse(response)
            switch result {
            case .success:
                guard let responseData = data else {
                    completion(.failure(NetworkResponse.noData.rawValue))
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(PhotoApiResponse.Container.self, from: responseData)
                    
                    guard apiResponse.stat == FlickrApi.Constants.ResponseValues.OKStatus else {
                        completion(.failure(NetworkResponse.okStatusNotFound.rawValue))
                        return
                    }
                    /* Generate random photos */
                    let photos = apiResponse.photosResponse.photos
                    let arrayOfRandomNumbers = self.generateRandomNumbers(max: photos.count, quantity: FlickrApi.Constants.numberOfPictures)
                    
                    completion(.success(self.generateRandomPhotos(photos, from: arrayOfRandomNumbers)))
                    
                } catch {
                    completion(.failure(NetworkResponse.unableToDecode.rawValue))
                }
                
            case .failure(let networkFailureError):
                completion(.failure(networkFailureError))
            }
            
        }
    }
    
}

// MARK: - Helpers

extension FlickrApiManager {
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<Bool> {
        switch response.statusCode {
        case 200...299: return .success(true)
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
    fileprivate func generateRandomNumbers(min: Int = 0, max: Int, quantity: Int) -> [Int] {
        var numbers = [Int]()
        while numbers.count < quantity {
            let randomNumber = Int.random(in: min..<max)
            if !numbers.contains(randomNumber) {
                numbers.append(randomNumber)
            }
        }
        return numbers
    }
    
    fileprivate func generateRandomPhotos(_ photos: [Photo], from randomNumbers: [Int]) -> [Photo] {
        var randomPhotos = [Photo]()
        for randomNumber in randomNumbers {
            randomPhotos.append(photos[randomNumber])
        }
        return randomPhotos
    }
}
