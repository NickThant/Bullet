//
//  ViewController.swift
//  Bullet
//
//  Created by Abby Kramer on 4/20/19.
//  Copyright © 2019 Abby Kramer. All rights reserved.
//
import CoreLocation
import UIKit

class PostCell : UITableViewCell {
    //@IBOutlet weak var postText: UILabel!
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    
    var idx: Int!
    
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    public var recentPosts : [Post] = []
    var locationManager = CLLocationManager()
    var model: DataModel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recentPosts.count > 0 {
            return recentPosts.count
        }
        return 1
    }
    
    @objc func clickPost() {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if recentPosts.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath)
            if let myCell = cell as? PostCell {
                myCell.arrow.image=#imageLiteral(resourceName: "Arrow-Right")
                myCell.icon.image = #imageLiteral(resourceName: "Artboard 1")
                myCell.postText.text = recentPosts[indexPath.row].message
                myCell.idx = indexPath.row
                myCell.titleText.text = recentPosts[indexPath.row].title
                
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath)
            if let myCell = cell as? PostCell {
                myCell.icon.image = nil
                myCell.postText.text = "Try increasing post view distance in settings."
                myCell.idx = indexPath.row
                myCell.titleText.text = "Hmmm, nothing to see here."
            }
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated);
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        postButton.backgroundColor = UIColor.white;
        
        settingsButton.setImage(#imageLiteral(resourceName: "settings icon"), for: UIControl.State.normal)
        
        tableView.layer.cornerRadius = 10
        postButton.layer.cornerRadius = 5
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action:
            #selector(handleRefreshPosts), for: .valueChanged)
        
        locationManager.delegate = self
        
        model = DataModel(mainVC: self)
        
        
        
        
        startTracking()
        //Post(message: "hello")
    }
    
    @objc func handleRefreshPosts() {
        locationManager.startUpdatingLocation()
        tableView.refreshControl?.endRefreshing()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location updated
        print("[DEBUG] Location updated.")
        model.currLocation = locations.last
        model.setRadius(radiusMiles: model.radius)
        model.setLocationAsName()
        locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startTracking()
        }
    }
    
    func startTracking() {
        let status = CLLocationManager.authorizationStatus()
        
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        } else if (status == .denied || status == .restricted) {
            let alert = UIAlertController(title: "Location Services", message: "Please enable location services to post/view posts in your area.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true)
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newPostSegue" {
            if let dest = segue.destination as? NewPostController {
                dest.model = self.model
            }
        } else if segue.identifier == "viewPostSegue" {
            if let dest = segue.destination as? ViewPostController {
                if let cell = sender as? PostCell {
                    dest.model = self.model
                    dest.post = recentPosts[cell.idx]
                    //dest.postText = cell.postText.text ?? "";
                }
            }
        } else if segue.identifier == "settingsSegue" {
            if let dest = segue.destination as? SettingsController {
                dest.mainVC = self
                dest.model = self.model
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "newPostSegue" {
            let status = CLLocationManager.authorizationStatus()
            
            if (status == .authorizedAlways || status == .authorizedWhenInUse) {
                return true
            }
            startTracking()
        } else if identifier == "viewPostSegue" {
            if recentPosts.count == 0 {
                return false
            }
        }
        return true
    }
}

