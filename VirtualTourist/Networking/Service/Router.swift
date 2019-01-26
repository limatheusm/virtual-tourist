//
//  Router.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

class Router<EndPoint: EndPointType>: NetworkRouter {
    private var task: URLSessionTask?
    
    // MARK: - EndPointType Protocol
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try self.buildRequest(from: route)
            task = session.dataTask(with: request, completionHandler: completion)
        } catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
}

// MARK: - Helpers

extension Router {
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        request.httpMethod = route.httpMethod.rawValue
        
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
            case .requestParameters(bodyParameters: let bodyParameters, urlParameters: let urlParameters):
                try configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
                
            case .requestParametersAndHeaders(bodyParameters: let bodyParameters, urlParameters: let urlParameters, additionalHeaders: let additionHeaders):
                addAdditionalHeaders(additionHeaders, request: &request)
                try configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
            }
            
            return request
        } catch {
            throw error
        }
    }
    
    /// Responsible for enconding the parameters for request
    ///
    /// - Parameters:
    ///   - bodyParameters: Body parameters from request
    ///   - urlParameters: URL parameters from request
    ///   - request: Request instance that is being created
    /// - Throws: Enconding erros
    fileprivate func configureParameters(bodyParameters: Parameters?, urlParameters: Parameters?, request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    
    /// Responsible for adding headers to request
    ///
    /// - Parameters:
    ///   - additionalHeaders: HTTP Headers to be add
    ///   - request: Request instance that is being created
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}
