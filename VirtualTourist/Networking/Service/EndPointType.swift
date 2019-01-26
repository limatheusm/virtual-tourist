//
//  EndPointType.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}
