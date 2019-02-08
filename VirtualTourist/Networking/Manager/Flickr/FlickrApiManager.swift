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
    
    func getPhotos(latitude: Double, longitude: Double, pages: Int?, completion: @escaping (_ result: Result<[Photo]>, _ pages: Int?) -> Void) {
        var randomPage: Int {
            if let pages = pages {
                let page = min(pages, 4000 / FlickrApi.Constants.ParameterValues.PerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        router.request(.getPhotos(latitude: latitude, longitude: longitude, page: randomPage )) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(.failure(NetworkResponse.poorNetworkConnection.rawValue), nil)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkResponse.failed.rawValue), nil)
                return
            }
            
            let result = self.handleNetworkResponse(response)
            switch result {
            case .success:
                guard let responseData = data else {
                    completion(.failure(NetworkResponse.noData.rawValue), nil)
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(PhotoApiResponse.Container.self, from: responseData)
                    
                    guard apiResponse.stat == FlickrApi.Constants.ResponseValues.OKStatus else {
                        completion(.failure(NetworkResponse.okStatusNotFound.rawValue), nil)
                        return
                    }

                    completion(.success(apiResponse.photosResponse.photos), apiResponse.photosResponse.pages)
                } catch {
                    completion(.failure(NetworkResponse.unableToDecode.rawValue), nil)
                }
                
            case .failure(let networkFailureError):
                completion(.failure(networkFailureError), nil)
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
