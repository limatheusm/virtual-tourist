//
//  JSONParameterEncoder.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

/// Takes parameters and makes them safe to be passed as JSON body parameters
public struct JSONParameterEncoder: ParameterEnconder {
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
        } catch {
            throw NetworkError.encondingFailed
        }
    }
}
