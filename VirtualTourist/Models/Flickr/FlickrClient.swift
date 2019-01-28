//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 25/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

final class FlickrClient {
    
    // MARK: - Singleton
    
    static let sharedInstance = FlickrClient()
    private init() { }
    
    // MARK: - Properties
    
    var session = URLSession.shared
    
    // MARK: - Methods
    
    func taskForGET(method: String, parameters: [String: AnyObject], completion: @escaping (Result<[String: AnyObject]>) -> Void) {
        /* Build the URL and configure the request */
        var parametersCopy = parameters
        parametersCopy[FlickrApi.Constants.ParameterKeys.Method] = method as AnyObject
        parametersCopy[FlickrApi.Constants.ParameterKeys.APIKey] = FlickrApi.Constants.ParameterValues.APIKey as AnyObject
        parametersCopy[FlickrApi.Constants.ParameterKeys.Format] = FlickrApi.Constants.ParameterValues.ResponseFormat as AnyObject
        
        let request = NSMutableURLRequest(url: createURL(from: parametersCopy))
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completion(.Error(NSError(domain: "taskForGET", code: 1, userInfo: userInfo)))
            }
            
            guard error == nil else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Status code over 2xx")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
//            do {
//                let apiResponse = try JSONDecoder().decode(Photos.Container.self, from: data)
//                print(apiResponse.photos.photo[0])
//            } catch {
//                print(error)
//            }
            
            /* Parse the data and use the data (happens in completion handler) */
            self.convertData(data, completion: completion)
        }
        
        task.resume()
    }
    
}

// MARK: - Helpers

extension FlickrClient {
    enum Result<T> {
        case Success(T)
        case Error(NSError)
    }
    
    /* Substitute the key for the value that is contained within the method name */
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    /* Decode JSON */
    private func convertData(_ data: Data, completion: (Result<[String: AnyObject]>) -> Void) {
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            completion(.Success(parsedResult))
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completion(.Error(NSError(domain: "convertData", code: 1, userInfo: userInfo)))
        }
    }
    
    /* Create a URL from parameters */
    func createURL(from parameters: [String :AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrApi.Constants.APIScheme
        components.host = FlickrApi.Constants.APIHost
        components.path = FlickrApi.Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.url!
    }
}
