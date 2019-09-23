//
//  Post.swift
//  Bullet
//
//  Created by Christian Musial on 4/25/19.
//  Copyright © 2019 Abby Kramer. All rights reserved.
//
import Foundation
import CoreLocation

class Post {
    var title: String!
    var message: String!
    var timestamp: UInt64!
    var location: CLLocation!
    var key: String
    var comments: [String]
    
    init (title: String, message: String, location: CLLocation, key: String, timestamp: UInt64, comments: [String] = []) {
        self.title = title
        self.message = message
        self.location = location
        self.timestamp = timestamp
        self.key = key
        self.comments = comments
    }
}
