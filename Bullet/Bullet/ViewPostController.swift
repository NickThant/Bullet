//
//  ViewPostController.swift
//  Bullet
//
//  Created by Abby Kramer on 4/25/19.
//  Copyright © 2019 Abby Kramer. All rights reserved.
//

import UIKit

class CommentCell : UITableViewCell {
    @IBOutlet weak var commentText: UITextView!
    
}

class ViewPostController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    let commentPlaceholder = "Enter a comment..."
    let commentPlaceholderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    let commentColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var postComments: UITableView!
    @IBOutlet weak var newCommentBox: UITextView!
    @IBOutlet weak var commentButton: UIButton!
    var postText : String = ""
    var allComments : [String] = []
    var post: Post!
    var model: DataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentButton.layer.cornerRadius=5
        
        postTitle.layer.cornerRadius=5
        postContent.layer.cornerRadius=5
        postComments.layer.cornerRadius=10
        newCommentBox.layer.cornerRadius=5
        
        postContent.text = post.message
        postTitle.text = post.title
        allComments = post.comments
        self.postComments.delegate = self;
        self.postComments.dataSource = self;
        newCommentBox.textColor = commentPlaceholderColor
        newCommentBox.text = commentPlaceholder
        newCommentBox.delegate = self
        
        postComments.refreshControl = UIRefreshControl()
        postComments.refreshControl?.addTarget(self, action:
            #selector(handleRefreshPosts), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func handleRefreshPosts() {
        allComments = post.comments
        postComments.reloadData()
        postComments.refreshControl?.endRefreshing()
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == commentPlaceholder && textView.textColor == commentPlaceholderColor {
            textView.text = ""
            textView.textColor = commentColor
        }
        textView.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allComments.isEmpty ? 1 : allComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postComments.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath)
        if let myCell = cell as? CommentCell {
            if !allComments.isEmpty {
                myCell.commentText.text = allComments[indexPath.row]
            } else {
                myCell.commentText.text = "No comments to show yet!"
            }
            
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func addComment(_ sender: Any) {
        if let text = newCommentBox.text {
            allComments.append(text)
            model.addComment(post: post, comment: text)
            postComments.reloadData()
            newCommentBox.text = "";
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     print("got here.")
     }
     */
    
}
