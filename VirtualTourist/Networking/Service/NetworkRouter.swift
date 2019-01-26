//
//  NetworkRouter.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()

protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType // here as we want our Router to be able to handle any EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func cancel()
}
