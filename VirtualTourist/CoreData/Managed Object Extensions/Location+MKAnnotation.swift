//
//  Location+Extensions.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 24/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import MapKit

extension Location: MKAnnotation {
    
    // MARK: Protocol
    
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
    
    // MARK: Constants
    
    struct Constants {
        static let CacheName = "locations"
    }
}
