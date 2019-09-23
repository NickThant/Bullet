//
//  SettingsController.swift
//  Bullet
//
//  Created by Abby Kramer on 4/30/19.
//  Copyright © 2019 Abby Kramer. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var viewPostsButton: UIButton!
    @IBOutlet weak var radius: UILabel!
    
    //For displaying location
    @IBOutlet weak var locationTextView: UITextView!
    var model: DataModel!
    var mainVC: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPostsButton.layer.borderColor = UIColor.white.cgColor
        viewPostsButton.layer.borderWidth = 1;
        locationTextView.text = model.currLocationName
        radiusSlider.value = Float(model.radius)
        radius.text = String(format: "%.0f", radiusSlider.value) + " miles";
        // Do any additional setup after loading the view.
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        model.radius = Double(sender.value)
        model.setRadius(radiusMiles: model.radius)
        radius.text = String(format: "%.0f", radiusSlider.value) + " miles";
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewUserPosts" {
            if let dest = segue.destination as? UserPostsViewController {
                dest.model = model;
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
