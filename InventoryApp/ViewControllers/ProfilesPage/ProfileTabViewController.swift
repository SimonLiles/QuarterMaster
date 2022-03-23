//
//  ProfileTabViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/14/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class ProfileTabViewController: UITabBarController {
    
    // MARK: - Variables and Constants
    
    //Intake for profile to be used
    var profile: Profile = Profile(name: "", pantry: [], shoppingList: [])
    
    var profileIndex = userData.selectedIndex
    
    //Object to collect and store logs.
    let log = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileIndex = userData.selectedIndex
        profile = userData.profiles![profileIndex]
        
        //Initializes Notification observers to listen for updates from other view controllers
        
        //Listens for updates to reload Nav Bar
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: "reloadProfileNavBar"), object: nil)
        
        //Listens for updates on receiving new Data
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name(rawValue: "received_data"), object: nil)
        
        navigationItem.title = profile.name
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadView(notification: NSNotification) {
        
        navigationItem.title = userData.profiles![profileIndex].name        
        
    }
    
    //Receive data from P2P controller and save it into Profile Model Controller
    @objc func updateProfile(notification: NSNotification) {
        log.info("updateProfile() called in ProfileTabViewController")
        
        DispatchQueue.main.sync {
            self.log.info("Entering DispatchQueue.main.sync in updateFields()")
            /*
            let receivedData = MultipeerSession.instance.receivedData
            
            var newProfile = Profile(name: "", pantry: [], shoppingList: [])
            newProfile = newProfile.decode(data: receivedData!)
            
            /*
            //Send current device copy of data, if received data does not match
            if(receivedData! != userData.profiles![userData.selectedIndex].encode()) {
                log.info("ProfileTabViewController responding to new receivedData")
                log.info("receivedData did NOT match current data")
                log.info("ProfileTabViewController sending current data in response")
                userData.sendProfile()
            } else {
                log.info("ProfileTabViewController responding to new receivedData")
                log.info("receivedData did match current data")
                log.info("ProfileTabViewController will NOT send data in response")
            }*/
            
            self.log.info("New Data Finished decoding")
            
            //Update user data
            let currentProfile = userData.profiles![profileIndex]
            
            //If there is a slot to update into, push the updated data
            if (userData.shouldUpdate(currentData: currentProfile, receivedData: newProfile)) {
                //This code produces duplicate efforts that in certain cases breaks everything
                //newProfile = ProfileModelController().updateMerge(currentData: currentProfile, receivedData: newProfile)
                //userData.profiles![profileIndex] = newProfile
            } else {
                //Check if there is a slot for the data to be fed into, if so, fill that slot
                var index = 0
                for profile in userData.profiles! {
                    if (newProfile == profile) {
                        break
                    }
                    
                    index += 1
                }
                
                if(index >= userData.profiles!.endIndex) {
                    //Ask if user wants to accept a new profile
                    //Create the alert
                    let alertTitle = "New profile invite"
                    let alertMessage = "Connected peer would like to share profile data with you. "
                    
                    let newProfileAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

                    let acceptAction = UIAlertAction(title: "Accept", style: .default, handler: { action in
                        self.log.info("User chose accept action")
                        userData.profiles!.append(newProfile)
                    })
                    
                    newProfileAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    newProfileAlert.addAction(acceptAction)
                    
                    self.log.info("presenting newProfileAlert from ProfileTabViewController")
                    present(newProfileAlert, animated: true)
                }
            }
            */
            //Update all views that display shareable data
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![self.profileIndex].pantry)
            log.info("Notification for 'reloadPantrys' sent")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)
            log.info("Notification for 'reloadShoppingList' sent")
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
            log.fault("No implementation provided for given segue in ProfileTabViewController prepare(for segue:)")
        }
    }
    

}
