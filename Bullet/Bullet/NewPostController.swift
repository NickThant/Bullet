//
//  NewPostControllerViewController.swift
//  Bullet
//
//  Created by Abby Kramer on 4/23/19.
//  Copyright © 2019 Abby Kramer. All rights reserved.
//

import UIKit

class NewPostController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    let postTextPlaceholder = "Hello fellow onlookers..."
    let titleTextPlaceholder = "Would a bullet without a title shoot as fast...?"
    let postTextPlaceholderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    let postTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var titleTxt: String?
    var textBoxTxt: String?
    var btnTxt: String?
    var editingKey: String?
    
    @IBOutlet weak var titleBox: UITextField!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var shootButton: UIButton!
    var model: DataModel!
    @IBOutlet weak var pageTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textBox.layer.cornerRadius=5;
        titleBox.layer.cornerRadius=5;
        shootButton.layer.cornerRadius=5;
        
        textBox.delegate = self
        textBox.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        titleBox.delegate = self
        titleBox.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        if let t = titleTxt {
            titleBox.text = t
        }
        if let t = textBoxTxt {
            textBox.text = t
            shootButton.setTitle("Update", for: .normal)
            pageTitle.text = "Update your post."
            titleBox.textColor = postTextColor
            textBox.textColor = postTextColor
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == titleTextPlaceholder && textField.textColor == postTextPlaceholderColor {
            textField.text = ""
            textField.textColor = postTextColor
        }
        textField.becomeFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == postTextPlaceholder && textView.textColor == postTextPlaceholderColor {
            textView.text = ""
            textView.textColor = postTextColor
        }
        textView.becomeFirstResponder()
    }
    
    @IBAction func shootPost(_ sender: UIButton) {
        if(textBox.text == "" || textBox.text == "Hello fellow onlookers..."){
            let alert = UIAlertController(title: "Empty Contents?", message: "The contents are empty. Please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in }))
            self.present(alert, animated: true, completion: nil)
        }
        
        else if let postText = textBox.text {
            let alert = UIAlertController(title: "Send post?", message: "\"\(postText)\"", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                
                let isUpdate = (self.btnTxt == "Update")
                self.post(isUpdate: isUpdate)
            self.navigationController?.popViewController(animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    private func post(isUpdate: Bool) {
        if let postText = textBox.text {
            
                //Add the post to the database that stores current posts.
                if let _ = self.navigationController?.viewControllers[0] as? ViewController {
                
                    if let postTitle = titleBox.text {
                        //Do something with the title.
                    
                        if(titleBox.text == "" || titleBox.text == "Would a bullet without a title shoot as fast...?"){
                            if isUpdate {
                                model.updatePost(key: editingKey!, title: "", message: postText)
                            } else {
                                let key = model.addPost(title: "", message: postText)
                                if let k = key {
                                    save(id: k)
                                }
                            }
    
                        }
                        else{
                            if isUpdate {
                                print("thekey: \(editingKey)")
                                model.updatePost(key: editingKey!, title: postTitle, message: postText)
                                
                                // TODO
                            } else {
                                let key = model.addPost(title: postTitle, message: postText)
                                if let k = key {
                                    save(id: k)
                                }
                            }
                            
                        }
                        
                    }
                }
            
            }
        
    }
    
    
    private func save(id : String){
        
        let posted = Posted(context: AppDelegate.viewContext)
        posted.id = id;
        
        do{
            try AppDelegate.viewContext.save()
        }
        catch{
            print("save failed!")
        }
        print("saved")
        
    }
    
}
