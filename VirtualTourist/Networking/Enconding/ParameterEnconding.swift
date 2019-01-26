//
//  ParameterEnconding.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]

public protocol ParameterEnconder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil"
    case encondingFailed = "Parameters enconding failed"
    case missingURL = "URL is nil"
}
