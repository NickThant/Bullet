//
//  DataModel.swift
//  Bullet
//
//  Created by Christian Musial on 4/25/19.
//  Copyright © 2019 Abby Kramer. All rights reserved.
//

import Firebase
import GeoFire
import CoreLocation


class DataModel {
    let root: DatabaseReference!
    let geoFire: GeoFire!
    let locationManager: CLLocationManager!
    let mainVC: ViewController!
    
    var currLocationName: String = "Unknown Location"
    var currLocation: CLLocation!
    var queryKeys: [String] = []
    var radius = 1.0
    
    init (mainVC: ViewController) {
        self.root = Database.database().reference().child("locations")
        self.geoFire = GeoFire(firebaseRef: root)
        self.locationManager = CLLocationManager()
        self.mainVC = mainVC
    }
    
    func setLocationAsName() {
        if let loc = currLocation {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) in
                if let pm = placemarks?[0] {
                    self.currLocationName = "\(pm.locality ?? "Unknown"), \(pm.administrativeArea ?? "Unknown")"
                } else {
                    self.currLocationName = "Unknown, Unknown"
                }
                //print("\(placemarks![0].locality!)")
                //print("\(placemarks![0].administrativeArea!)")
            })
        }
    }
    func updatePost(key: String, title: String, message: String) {
        let post = root.child("\(key)")
        print("\(title):\(post)")
        post.updateChildValues(["title":title, "post": message])
        // TODO update in firebase
    }
    
    func deletePost(key: String) {
        let post = root.child("\(key)")
        post.removeValue()
    }
    
    func addComment(post: Post, comment: String) {
        let ref = root.child("\(post.key)/comments")
        post.comments.append(comment)
        ref.setValue(post.comments)
    }
    
    func addPost(title: String, message: String) -> String? {
        // Get any data necessary to add to a Post
        let ref = root.childByAutoId()
        let timestamp = UInt64(round(NSDate().timeIntervalSince1970 * 1000))
        
        if let key = ref.key {
            // Create Post object
            let post = Post(title: title, message: message, location: currLocation, key: ref.key!, timestamp: timestamp)
            
            // Insert into DB
            ref.setValue(["post":message, "title": title, "timestamp": post.timestamp, "comments": []])
            geoFire.setLocation(currLocation, forKey: ref.key!, withCompletionBlock: nil)
            
            // Handle UI changes
            self.mainVC.recentPosts.insert(post, at: 0)
            self.mainVC.tableView.reloadData()
            
            return ref.key!
        } else {
            // Error
            return nil
        }
    }
    
    func setRadius(radiusMiles: Double) {
        let latitude = currLocation.coordinate.latitude
        let longitude = currLocation.coordinate.longitude
        let radiusKM = radiusMiles * 1.61
        
        let center = CLLocation(latitude: latitude, longitude: longitude)
        let circleQuery = geoFire.query(at: center, withRadius: radiusKM)
        mainVC.recentPosts = []
        queryKeys = []
        self.mainVC.tableView.reloadData()
        print("\(center)")
        let queryHandle = circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            if !self.queryKeys.contains(key) {
                self.queryKeys.append(key)
            }
        })
        
        // Callback for when query is done
        circleQuery.observeReady {
            circleQuery.removeObserver(withFirebaseHandle: queryHandle)
            
            // Add all posts to VC
            for key in self.queryKeys {
                self.root.child(key).observe(.value, with: {(snap) in
                    if self.mainVC.recentPosts.contains(where: {(post) in post.key == key }) {
                        for (idx, p) in self.mainVC.recentPosts.enumerated() {
                            if p.key == key {
                                if let data = snap.value as? NSDictionary {
                                    let message = data.value(forKey: "post")! as! String
                                    let title = data.value(forKey: "title")! as! String
                                    let comments = data.value(forKey: "comments") as? [String]
                                    
                                    p.title = title
                                    p.message = message
                                    p.comments = comments ?? []
                                } else {
                                    // Post was deleted
                                }
                            }
                        }
                    }
                    else {
                        let data = snap.value as! NSDictionary
                        let message = data.value(forKey: "post")! as! String
                        let title = data.value(forKey: "title")! as! String
                        let latLongArr = data.value(forKeyPath: "l")! as! NSArray
                        let latitude = latLongArr[0] as! Double
                        let longitude = latLongArr[1] as! Double
                        let timestamp = data.value(forKey: "timestamp") as! UInt64
                        let comments = data.value(forKey: "comments") as? [String]
                        //let latitude = data.value(forKey: "latitude")!
                        // TODO fix
                        let post = Post(title: title, message: message, location: CLLocation(latitude: latitude, longitude: longitude), key: key, timestamp: timestamp, comments: comments ?? [])
                        
                        let idx = self.mainVC.recentPosts.firstIndex(where: {(p) in p.timestamp < post.timestamp})
                        self.mainVC.recentPosts.insert(post, at: idx ?? self.mainVC.recentPosts.count)
                    }
                    
                })
            }
            //it keeps crashing here
            // All posts have been added to VC
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                while self?.mainVC.recentPosts.count != self?.queryKeys.count {}
                DispatchQueue.main.async { [weak self] in
                    self?.mainVC.tableView.reloadData()
                }
            }
        }
        
    }
    
}
