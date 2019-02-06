//
//  ImageCell.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 29/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var uiImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static let identifier = "imageCellId"
    var imageURL = ""
}
