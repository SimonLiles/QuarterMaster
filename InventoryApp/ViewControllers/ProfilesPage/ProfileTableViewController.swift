//
//  ProfileTableViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/13/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class ProfileTableViewController: UITableViewController {

    // MARK: - Constants and Variables
    
    var profiles: [Profile] = []
        
    //Search bar constants and Variables
    let searchController = UISearchController(searchResultsController: nil)
    var filteredProfiles: [Profile] = [] //Holds pantryItems that are being searched for
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    //Object to collect and store logs.
    let log = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initializes Notification observer to listen for updates from other view controllers
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "reloadProfiles"), object: nil)
        
        //Listens for updates on receiving new Data
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name(rawValue: "received_data"), object: nil)

        //Initialize user data on start up
        if let savedProfiles = ProfileModelController().loadProfileData() {
            userData.profiles = savedProfiles
        } else {
            userData.profiles = ProfileModelController().loadSampleProfile()
            profiles = userData.profiles!
            performSegue(withIdentifier: "addNewProfileSegue", sender: nil)
        }
        
        profiles = userData.profiles!
        
        //Initialization of Search Bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Profiles"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //Allows user to tap out of editing
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(tableView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadTable(notification: NSNotification) {
        profiles = userData.profiles!
        userData.selectedIndex = 0
        
        tableView.reloadData()
    }
    
    //Receive data from P2P controller and save it into Profile Model Controller
    @objc func updateProfile(notification: NSNotification) {
        log.info("updateProfile() called in ProfileTableViewController")
        DispatchQueue.main.sync {
            self.log.info("Entering DispatchQueue.main.sync in updateProfile()")
            
            let receivedData = MultipeerSession.instance.receivedData
            
            var newProfile = Profile(name: "", pantry: [], shoppingList: [], categories: [], locations: [], units: [])
            newProfile = newProfile.decode(data: receivedData!)
            
            self.log.info("New Data Finished decoding")
            
            //Update user data
            
            //Check if there is a slot for the data to be fed into, if so, fill that slot
            var index = 0
            for profile in profiles {
                if (newProfile == profile) {
                    break
                }
                
                index += 1
            }
                        
            if (profiles.contains(newProfile)) {
                let currentProfile = userData.profiles![index]
                
                if (userData.shouldUpdate(currentData: currentProfile, receivedData: newProfile)) {
                    newProfile = ProfileModelController().updateMerge(currentData: currentProfile, receivedData: newProfile)
                    userData.profiles![index] = newProfile
                    tableView.reloadData()
                }
            } else {
                //Ask if user wants to accept a new profile
                //Create the alert
                let alertTitle = "New profile invite"
                let alertMessage = "Connected peer would like to share profile data with you. "
                
                let newProfileAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

                let acceptAction = UIAlertAction(title: "Accept", style: .default, handler: { action in
                    self.log.info("User chose accept action")
                    //newProfile.name = "\(newProfile.originalAuthor): \(newProfile.name)"
                    self.log.info("Appending profile from: \n\(newProfile.originalAuthor)")
                    userData.profiles!.append(newProfile)
                    self.profiles = userData.profiles!
                    self.tableView.reloadData()
                })
                
                newProfileAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                newProfileAlert.addAction(acceptAction)
                
                log.info("presenting newProfileAlert from ProfileTableViewController")
                present(newProfileAlert, animated: true)
            }
            
            profiles = userData.profiles!
            tableView.reloadData()
        }
    }
    
    // MARK: - Search Bar Functionality
    
    //Function to filter for search results
    func filterContentForSearchText(_ searchText: String) {
        
        filteredProfiles = profiles.filter { (profile: Profile) -> Bool in
        
            return profile.name.lowercased().contains(searchText.lowercased())
        }
      
      tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if (isFiltering) {
            return filteredProfiles.count
        }
        
        return profiles.count
    }

    //Sets section header titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //activates when search bar is used
        if isFiltering {
            if (filteredProfiles.count <= 0) {
                return "No Results found"
            } else {
                return "Searching Profiles"
            }
        }
        
        return ""
    }
    
    //Configure table view cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileTableViewCell", for: indexPath)

        // Configure the cell...
        
        if (isFiltering) {
            cell.textLabel?.text = filteredProfiles[indexPath.row].name
            
            //Set subtitle to indicate source of the profile
            if(filteredProfiles[indexPath.row].originalAuthorSimple == UIDevice.current.name) {
                cell.detailTextLabel?.text = "From: This Device"
            } else {
                cell.detailTextLabel?.text = "From: \(filteredProfiles[indexPath.row].originalAuthorSimple)"
            }
        } else {
            cell.textLabel?.text = profiles[indexPath.row].name
            
            //Set subtitle to indicate source of the profile
            if(profiles[indexPath.row].originalAuthorSimple == UIDevice.current.name) {
                cell.detailTextLabel?.text = "From: This Device"
            } else {
                cell.detailTextLabel?.text = "From: \(profiles[indexPath.row].originalAuthorSimple)"
            }
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "profileDetailSegue" {
            let indexPath = tableView.indexPathForSelectedRow!
            
            var selectedIndex: Int = 0
            
            if isFiltering {
                log.info("ProfileTableView is Filtering ")
                let selectedProfile = filteredProfiles[indexPath.row]
                for profile in userData.profiles! {
                    if selectedProfile.name == profile.name {
                        break
                    } else {
                        selectedIndex += 1
                    }
                }
            } else {
                log.info("ProfileTableView is NOT Filtering ")

                selectedIndex = indexPath.row
            }
            
            log.info("selectedIndex = \(String(selectedIndex))")
            
            userData.selectedIndex = selectedIndex
            
            log.info("userData.selectedIndex = \(String(userData.selectedIndex))")
        }
    }
    
    @IBAction func unwindToProfileTableView(segue: UIStoryboardSegue) {
        if segue.identifier == "deleteProfileUnwind" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                //Ugly code to remove a specific item from the array
                let profileToRemove = userData.profiles![selectedIndexPath.row]
                var index = 0
                for profile in userData.profiles! {
                    //Used profile name as an identifier, assuming generally user does not have 2 of same pantry item
                    if profileToRemove.name == profile.name {
                        break //If pantryItemToRemove matches the item, break out of the loop
                    } else {
                        index += 1
                    }
                }
                
                userData.profiles!.remove(at: index) //remove item from profile list
                
                profiles = userData.profiles! //Reset tableView data source
                
                tableView.reloadData() //reload table to reflect deleted item
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfiles"), object: nil) //DOUBLE RELOAD!!! cuz why not?
                
                userData.saveProfileData() //Save profile data
                log.info("ProfileModelController saved data after exiting to ProfileTableView")
            }
        }
    }
}

// MARK: - Class Extensions

//Extensions to make search bar work
extension ProfileTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
