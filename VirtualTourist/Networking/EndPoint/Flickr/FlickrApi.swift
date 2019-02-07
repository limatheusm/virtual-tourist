//
//  FlickrApi.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
    case qa
    case production
    case staging
}

public enum FlickrApi {
    case getPhotos(latitude: Double, longitude: Double)
}

// MARK: - EndPointType Protocol

extension FlickrApi: EndPointType {
    var environmentBaseURL : String {
        switch FlickrApiManager.environment {
            case .production: return Constants.BaseURLProduction
            case .qa: return ""
            case .staging: return ""
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.") }
        return url
    }
    
    var path: String {
        switch self {
            case .getPhotos:
                return ""
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            case .getPhotos:
                return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            case .getPhotos(let latitude, let longitude):
                let urlParameters: Parameters = [
                    Constants.ParameterKeys.Method: Constants.ParameterValues.SearchMethod,
                    Constants.ParameterKeys.APIKey: Constants.ParameterValues.APIKey,
                    Constants.ParameterKeys.Format: Constants.ParameterValues.ResponseFormat,
                    Constants.ParameterKeys.BoundingBox: bboxString(from: latitude, longitude),
                    Constants.ParameterKeys.SafeSearch: Constants.ParameterValues.UseSafeSearch,
                    Constants.ParameterKeys.Extras: Constants.ParameterValues.MediumURL,
                    Constants.ParameterKeys.NoJSONCallback: Constants.ParameterValues.DisableJSONCallback
//                    Constants.ParameterKeys.PerPage: Constants.ParameterValues.PerPage
                ]
                return .requestParameters(bodyParameters: nil, urlParameters: urlParameters)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    
}

// MARK: - Helpers

extension FlickrApi {
    private func bboxString(from latitude: Double, _ longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.1)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}
