//
//  UserPostsViewController.swift
//  Bullet
//
//  Created by Kaung Thant on 4/30/19.
//  Copyright © 2019 Abby Kramer. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import CoreLocation

class PostCell2 : UITableViewCell{
    @IBOutlet weak var titletext: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var posttext: UITextView!
    @IBOutlet weak var icon: UIImageView!
    var idx: Int!
    
    
}

class UserPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var keys : [String] = []
    var posts: [Post] = []
    var root: DatabaseReference!
    @IBOutlet weak var tableView: UITableView!
    var model: DataModel?
    var edit = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate=self
        tableView.dataSource=self
        
        tableView.layer.cornerRadius=10;
        
        self.root = Database.database().reference().child("locations")
        
        // Get user keys
        let query : NSFetchRequest<Posted> = Posted.fetchRequest()
        if let results = try? AppDelegate.viewContext.fetch(query){
            keys = results.map{$0.id!}
            print(keys)
        }
        
        for key in keys {
            let obs = self.root.child(key).observe(.value, with: {(snap) in
                if snap.exists() {
                    // Check if post exists
                    var postIdx = -1
                    for (idx, p) in self.posts.enumerated() {
                        if p.key == key {
                            postIdx = idx
                        }
                    }
                    // Do something with snap
                    let data = snap.value as! NSDictionary
                    // Get fields
                    let message = data.value(forKey: "post")! as! String
                    let title = data.value(forKey: "title")! as! String
                    let latLongArr = data.value(forKeyPath: "l")! as! NSArray
                    let latitude = latLongArr[0] as! Double
                    let longitude = latLongArr[1] as! Double
                    let timestamp = data.value(forKey: "timestamp") as! UInt64
                    let comments = data.value(forKey: "comments") as? [String]
                    
                    if postIdx != -1 {
                        // Update post
                        self.posts[postIdx].message = message
                        self.posts[postIdx].title = title
                    } else {
                        // Do something with snap
                        
                        
                        let post = Post(title: title, message: message, location: CLLocation(latitude: latitude, longitude: longitude), key: key, timestamp: timestamp, comments: comments ?? [])
                        
                        let idx = self.posts.firstIndex(where: {(p) in p.timestamp < post.timestamp})
                        self.posts.insert(post, at: idx ?? self.posts.count)
                    }
                }
            })
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // Get user posts
        
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            while self?.posts.count != self?.keys.count {}
            DispatchQueue.main.async { [weak self] in
                print("viewDidLoad table reloaded")
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postcell2", for: indexPath)
        if let cell = cell as? PostCell2{
            cell.arrow.image = #imageLiteral(resourceName: "Arrow-Right");
            cell.icon.image = #imageLiteral(resourceName: "Artboard 1");
            cell.posttext.text = posts[indexPath.row].message
            cell.titletext.text = posts[indexPath.row].title
            cell.idx = indexPath.row
        }
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.model?.deletePost(key: self.posts[indexPath.row].key)
            
          let query : NSFetchRequest<Posted> = Posted.fetchRequest()
            if let results = try? AppDelegate.viewContext.fetch(query){
                for r in results{
                    if(r.id == self.posts[indexPath.row].key){
                       print("deleted from Coredata")
                        AppDelegate.viewContext.delete(r);
                        try? AppDelegate.viewContext.save();
                    }
                }
            }
            
            self.keys.remove(at: indexPath.row)
            self.posts.remove(at: indexPath.row)
            tableView.reloadData();
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.edit = indexPath.row
            self.performSegue(withIdentifier: "editPost", sender: self)
            // share item at indexPath
        }
        
        share.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return [delete, share]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPostSegue" {
            if let dest = segue.destination as? ViewPostController {
                if let cell = sender as? PostCell2 {
                    dest.model = model
                    dest.post = posts[cell.idx]
                    //dest.postText = cell.postText.text ?? "";
                }
            }
        } else if segue.identifier == "editPost" {
            if let dest = segue.destination as? NewPostController {
                print("edit:\(edit)")
                let post = self.posts[edit]
                dest.titleTxt = post.title
                dest.textBoxTxt = post.message
                dest.btnTxt = "Update"
                print("\(post.key)")
                dest.editingKey = post.key
                dest.model = self.model
                //dest.shootButton.setTitle("Update", for: .normal)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "viewPostSegue" {
            if posts.count == 0 {
                return false
            }
        }
        return true
    }
}
