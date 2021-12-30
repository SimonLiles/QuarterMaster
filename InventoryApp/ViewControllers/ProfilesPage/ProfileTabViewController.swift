//
//  ProfileTabViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/14/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

class ProfileTabViewController: UITabBarController {
    
    // MARK: - Variables and Constants
    
    //Intake for profile to be used
    var profile: Profile = Profile(name: "", pantry: [], shoppingList: [])
    
    let profileIndex = ProfileModelController.shared.selectedIndex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profile = ProfileModelController.shared.profiles![profileIndex]
        
        //Initializes Notification observer to listen for updates from other view controllers
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: "reloadProfileNavBar"), object: nil)
        
        navigationItem.title = profile.name
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadView(notification: NSNotification) {
        
        navigationItem.title = ProfileModelController.shared.profiles![profileIndex].name        
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier {
        case "": //Pantry Tab data passed through here
            break
        case " ": //Shopping List Tab data passed through here
            break
        default: //If something breaks
            print("Your segues dont work, you idiot")
            print("Check ProfileTabViewController prepare(for segue:)")
        }
    }
    

}
