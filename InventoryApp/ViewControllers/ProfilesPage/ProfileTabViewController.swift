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
    
    var profileIndex = ProfileModelController.shared.selectedIndex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileIndex = ProfileModelController.shared.selectedIndex
        profile = ProfileModelController.shared.profiles![profileIndex]
        
        //Initializes Notification observers to listen for updates from other view controllers
        
        //Listens for updates to reload Nav Bar
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: "reloadProfileNavBar"), object: nil)
        
        //Listens for updates on receiving new Data
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name(rawValue: "received_data"), object: nil)
        
        navigationItem.title = profile.name
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadView(notification: NSNotification) {
        
        navigationItem.title = ProfileModelController.shared.profiles![profileIndex].name        
        
    }
    
    //Receive data from P2P controller and save it into Profile Model Controller
    @objc func updateProfile(notification: NSNotification) {
        print("updateProfile() called")
        DispatchQueue.main.sync {
            print("Entering DispatchQueue.main.sync in updateFields()")
            
            let receivedData = MultipeerSession.instance.receivedData
            
            var newProfile = Profile(name: "", pantry: [], shoppingList: [])
            newProfile = newProfile.decode(data: receivedData!)
            
            print("New Data Finished decoding")
            
            //Update user data
            let currentProfile = ProfileModelController.shared.profiles![profileIndex]
            
            if (ProfileModelController.shared.shouldUpdate(currentData: currentProfile, receivedData: newProfile)) {
                ProfileModelController.shared.profiles![profileIndex] = newProfile
            }
            
            //Update all views that display shareable data
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: ProfileModelController.shared.profiles![self.profileIndex].pantry)
            print("Notification for 'reloadPantrys' sent")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: ProfileModelController.shared.profiles![profileIndex].shoppingList)
            print("Notification for 'reloadShoppingList' sent")
        }
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
            print("No implementation provided for given segue in ProfileTabViewController prepare(for segue:)")
        }
    }
    

}
