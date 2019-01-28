//
//  Photo.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 26/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation

struct PhotoApiResponse: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perpage
        case total
        case photos = "photo"
    }
}

// MARK: - Container PhotoApiResponse

extension PhotoApiResponse {
    struct Container: Codable {
        let stat: String
        let photosResponse: PhotoApiResponse
        
        enum CodingKeys: String, CodingKey {
            case stat
            case photosResponse = "photos"
        }
    }
}

// MARK: - Photo Model

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    let mediumURL: String
    let mediumHeight: String
    let mediumWidth: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case mediumURL = "url_m"
        case mediumHeight = "height_m"
        case mediumWidth = "width_m"
    }
}
