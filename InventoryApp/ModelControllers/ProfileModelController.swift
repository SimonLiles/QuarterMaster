//
//  ProfileModelController.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/13/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

import os

/**
 Model Controller to manage profile model objects.
 - Accessible Variables:
    - ```static let shared``` Allows ProfileModelController data to be used everywhere without using segues
    - ```var selectedIndex``` indicates the current profile. Required to access any specific profile
    - ```var profiles: [Profile]?``` holds an array of profile model objects
 - Get Functions: Pull values from specific data sets with in the profile array
    - ```getCategories() -> [String]``` will return all categories from profile.pantry
    - ```getLocations() -> [String]``` will return all locations from profile.pantry
    - ```getUnits() -> [String]``` will return all units from profile.pantry
 - Data Persistance: Allows for data to be saved and loaded from disk
    - ```saveProfileData()``` wiil save all profiles in that instance of ProfileModelController to a .json file
    - ```loadProfileData() -> [Profile]?``` will return an optional array of profiles after loading from a .json file
    - ```loadSampleProfile() -> [Profile]?``` will return a single profile within an array as sample data
 */
class ProfileModelController {
    
    ///Allows ProfileModelController data to be used everywhere without using segues
    static let shared = ProfileModelController() //Allows ProfileModelController data to be used everywhere without using segues
    
    ///indicates the current profile. Required to access any specific profile
    var selectedIndex: Int = 0
    
    ///holds an array of profile model objects
    var profiles: [Profile]?
    
    //Object to collect and store logs.
    let log = Logger()
        
    //MARK: - Profile Functionality
    
    /**
     Gets categories from the pantry array of the profile object
     
     - Returns: Array of strings representing categories from pantry array
     */
    func getCategories() -> [String] {
        var categories: [String] = []
        
        //Gather info from each item in pantry
        for item in profiles![selectedIndex].pantry {
            //If location is unique in locations array, append it to the end
            if !categories.contains(item.category) {
                categories.append(item.category)
            }
        }
        
        return categories
    }
    
    /**
     Gets locations from the pantry array of the profile object
     
     - Returns: Array of strings representing locations from pantry array
     */
    func getLocations() -> [String] {
        var locations: [String] = []
        
        //Gather info from each item in pantry
        for item in profiles![selectedIndex].pantry {
            //If location is unique in locations array, append it to the end
            if !locations.contains(item.location) {
                locations.append(item.location)
            }
        }
        
        return locations
    }
    
    /**
     Gets units from the pantry array of the profile object
     
     - Returns: Array of strings representing units from pantry array
     */
    func getUnits() -> [String] {
        var units: [String] = []
        
        //Gather info from each item in pantry
        for item in profiles![selectedIndex].pantry {
            //If location is unique in locations array, append it to the end
            if !units.contains(item.units) {
                units.append(item.units)
            }
        }
        
        return units
    }

    //MARK: - P2P Services
    
    //Send specific data
    func sendProfile() {
        guard let encodedProfile = profiles![selectedIndex].encode() else { return }
        
        MultipeerSession.instance.send(data: encodedProfile)
    }
    
    //MARK: - Version Control
    //Determines whether user data should be updated with new data or not
    //Profile names must match
    //Must have a later version
    func shouldUpdate(currentData: Profile, receivedData: Profile) -> Bool{
        //Profile names must match
        if (currentData == receivedData) {
            return true
            /*
            //Old code for old version control system
            //Must have a later version
            if (currentData.versionTimeStamp < receivedData.versionTimeStamp) {
                return true
            } else {
                return false
            }
             */
        } else {
            return false
        }
    }
    
    func updateMerge(currentData: Profile, receivedData: Profile) -> Profile {
        var newData = Profile(name: "", pantry: [], shoppingList: [])
        
        //If the received data and current data, do not match, send current data to connected peers
        if(currentData.pantry != receivedData.pantry &&
           currentData.shoppingList != receivedData.shoppingList) {
            sendProfile()
        }
        
        if (shouldUpdate(currentData: currentData, receivedData: receivedData)) {
            //Update descriptors
            newData.name = receivedData.name
            newData.description = receivedData.description
            
            //Make sure the shopping list is not empty
            if (!currentData.pantry.isEmpty &&
                !receivedData.pantry.isEmpty) {
                //Loop through each element of the receivedData pantry
                var index = 0
                for receivedItem in receivedData.pantry {
                    let currentItem = currentData.pantry[index]
                    //Check if item exists in both pantries
                    if (receivedItem == currentItem) {
                        //Check which item is the latest to be updated
                        if(currentItem.lastUpdate <= receivedItem.lastUpdate) {
                            newData.pantry.append(receivedItem)
                        } else {
                            newData.pantry.append(currentItem)
                        }
                    } else {
                        newData.pantry.append(receivedItem)
                    }
                    
                    index += 1
                }
            }
            
            //Make sure the shopping list is not empty
            if (!currentData.shoppingList.isEmpty &&
                !receivedData.shoppingList.isEmpty) {
                //Loop through each element of the receivedData shoppinglist
                var index = 0
                for receivedItem in receivedData.shoppingList {
                    let currentItem = currentData.shoppingList[index]
                    //Check if item exists in both pantries
                    if (receivedItem == currentItem) {
                        //Check which item is the latest to be updated
                        if(currentItem.lastUpdate <= receivedItem.lastUpdate) {
                            //Only keep items in shopping list that are newer than the last clear
                            if(receivedItem.lastUpdate <= currentData.shoppingListLastClear) {
                                newData.shoppingList.append(receivedItem)
                            }
                        } else {
                            //Only keep items in shopping list that are newer than the last clear
                            if((currentItem).lastUpdate <= receivedData.shoppingListLastClear) {
                                newData.shoppingList.append((currentItem))
                            }
                        }
                    } else {
                        newData.shoppingList.append(receivedItem)
                    }
                    
                    index += 1
                }
            }
            
            //Return the new profile object
            return newData
        }
        
        //Default empty return statement
        newData = receivedData
        return newData
    }
    
    //MARK: - Data Persistence
    
    //URL address on user device for app memory
    let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("profiles").appendingPathExtension("json")
    
    /**
     Saves the array of profile objects representing user data to a .json file.
     */
    func saveProfileData() {
        log.info("Saving all user data")
        
        let jsonEncoder = JSONEncoder()
        let encodedProfiles = try? jsonEncoder.encode(profiles) //encode the pantry
        
        try? encodedProfiles?.write(to: archiveURL) //attempt to write profile data to json file
    }
    
    /**
     Pulls user data from selected .json file. Will return nil if file is empty or does not exist.
     
     - Returns: Optional array of profile objects.
     */
    func loadProfileData() -> [Profile]? {
        log.info("Loading existing user data")
        
        let jsonDecoder = JSONDecoder()
        
        guard let retrievedProfileData = try? Data(contentsOf: archiveURL) else { return nil } //Pulls json encoded profile data
        
        let decodedProfiles: [Profile]? = try? jsonDecoder.decode(Array<Profile>.self, from: retrievedProfileData) //Decodes JSON profile data
        
        return decodedProfiles
    }
    
    /**
    Loads sample profile data.
     
     Can be used in cases where existing user data does not exist yet. Creates full data set to make debugging easier after first install and can give user an example to play with. 
     
     - Returns: Single profile with a prefilled pantry and shopping list.
     */
    func loadSampleProfile() -> [Profile]? {
        log.info("Loading sample profile data")
        
        var sampleProfile: [Profile] = [Profile(
        name: "Queen Anne's Revenge",
        pantry: [
        PantryItem(name: "Cookies", category: "Snacks", location: "Cookie Jar", currentQuantity: 12, units: "Cookies", note: "Very tasty, chocochip cookies", lastUpdate: Date()),
        PantryItem(name: "Bagels", category: "Breads", location: "Galley Counter", currentQuantity: 6, units: "Bagels", note: "Quick, wholesome, and healthy breakfast", lastUpdate: Date()),
        PantryItem(name: "Peanut Butter", category: "Staples", location: "Cupboard", currentQuantity: 3, units: "Jars", note: "Use in a sandwich", lastUpdate: Date()),
        PantryItem(name: "Strawberry Jelly", category: "Preserves", location: "Fridge", currentQuantity: 2, units: "Jars", note: "Sweet strawberry jelly", lastUpdate: Date()),
        PantryItem(name: "Bread", category: "Breads", location: "Bread Box", currentQuantity: 4, units: "Loaves", note: "Good for making sandwiches", lastUpdate: Date())],
        shoppingList:
        [PantryItem(name: "Cookies", category: "Snacks", location: "Cookie Jar", currentQuantity: 12, units: "Cookies", note: "Very tasty, chocochip cookies", lastUpdate: Date())])]
        
        sampleProfile[0].description = "Blackbeard's ship. This is a sample profile, feel free to change as you see fit."
        
        sampleProfile[0].shoppingList[0].purchaseStatus = .toBuy
        
        return sampleProfile
    }
}
