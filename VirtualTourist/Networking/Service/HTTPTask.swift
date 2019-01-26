//
//  HTTPTask.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//
//

public typealias HTTPHeaders = [String: String]

/// HTTPTask is responsible for configuring parameters for a specific endPoint
public enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?, urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?, urlParameters: Parameters?, additionalHeaders: HTTPHeaders?)
    
    // case download, upload ... etc
}
