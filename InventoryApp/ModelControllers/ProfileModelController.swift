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
        let categories: [String] = profiles![selectedIndex].categories
        
        /*
        //Gather info from each item in pantry
        for item in profiles![selectedIndex].pantry {
            //If location is unique in locations array, append it to the end
            if !categories.contains(item.category) {
                categories.append(item.category)
            }
        }
        */
        
        return categories.sorted()
    }
    
    /**
     Gets locations from the pantry array of the profile object
     
     - Returns: Array of strings representing locations from pantry array
     */
    func getLocations() -> [String] {
        let locations: [String] = profiles![selectedIndex].locations
        
        /*
        //Gather info from each item in pantry
        for item in profiles![selectedIndex].pantry {
            //If location is unique in locations array, append it to the end
            if !locations.contains(item.location) {
                locations.append(item.location)
            }
        }
        */
        
        return locations.sorted()
    }
    
    /**
     Gets units from the pantry array of the profile object
     
     - Returns: Array of strings representing units from pantry array
     */
    func getUnits() -> [String] {
        let units: [String] = profiles![selectedIndex].units
        
        /*
        //Gather info from each item in pantry
        for item in profiles![selectedIndex].pantry {
            //If location is unique in locations array, append it to the end
            if !units.contains(item.units) {
                units.append(item.units)
            }
        }
        */
        
        return units.sorted()
    }
    
    //MARK: - Data Movement
    func updatePantryFromShoppingList() {
        let profileIndex = userData.selectedIndex
        lazy var pantry = userData.profiles![profileIndex].pantry
        lazy var shoppingList = userData.profiles![profileIndex].shoppingList
        
        // Run through shopping list array, if Item has a check mark, then add quantity to respective pantryItem
        var index = 0
        for item in shoppingList {
            if item.purchaseStatus == .bought {
                //Run through pantry array to find corresponding item and add neededQuantity to currentQuantity
                let pantryIndex = pantry.firstIndex(of: item) ?? 0
                
                //let pantry = userData.profiles![profileIndex].pantry
                /*
                log.info("profileIndex = \(profileIndex)")
                log.info("index = \(index)")
                log.info("pantryIndex = \(pantryIndex)")
                log.info("shoppingListItem: \(item.name) | \(item.neededQuantity)")
                */
                
                
                pantry[pantryIndex].currentQuantity += item.neededQuantity //Add quantity to pantry item
                pantry[pantryIndex].neededQuantity = 1 //Reset needed quanity for pantry item
                pantry[pantryIndex].purchaseStatus = .toBuy
                pantry[pantryIndex].lastUpdate = Date()
                userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .modify, newObject: pantry[pantryIndex], oldObject: item))
                
                userData.profiles![profileIndex].shoppingListChangeLog.append(PantryChangeKey(time: Date(), changeType: .delete, newObject: item, oldObject: item))
                
                shoppingList.remove(at: index) //Remove item from shoppingList
            } else {
                index += 1
            }
        }
        
        //Set shoppingListLastClear
        userData.profiles![profileIndex].shoppingListLastClear = Date()
        log.info("Shopping List Last Clear was:  \(userData.profiles![profileIndex].shoppingListLastClear.description)")
        
        userData.profiles![profileIndex].pantry = pantry
        userData.profiles![profileIndex].shoppingList = shoppingList

        //Save data
        userData.saveProfileData()
        log.info("ProfileModelController saved user data after clearing completed items from shopping list")
        
        
        //Reload tableViews for shoppingList and pantry tabs
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![profileIndex].pantry)
        
        //Reload tableViews for shoppingList and pantry tabs
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)

    }

    //MARK: - P2P Services
    
    //Send specific data
    func sendProfile() {
        guard let encodedProfile = userData.profiles![selectedIndex].encode() else { return }
        
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
        log.info("updateMerge() called")
        
        //log.info("\n\ncurrentData.pantry: \(currentData.pantry.description)")
        //log.info("\n\ncurrentData.shoppingList: \(currentData.shoppingList.description)")
        //log.info("\n\nreceivedData.pantry: \(receivedData.pantry.description)")
        //log.info("\n\nreceivedData.shoppingList: \(receivedData.shoppingList.description)")

        var newData = Profile(name: "", pantry: [], shoppingList: [], categories: [], locations: [], units: [])
        
        
        /*
        //If the received data and current data, do not match, send current data to connected peers
        let currentDataEncoded = currentData.encode()
        let receivedDataEncoded = receivedData.encode()
        log.info("\n\ncurrentDataEncoded.hashValue = \(currentDataEncoded.hashValue)\n\n")
        log.info("\n\nreceivedDataEncoded.hashValue = \(receivedDataEncoded.hashValue)\n\n")
        if(currentDataEncoded.hashValue == receivedDataEncoded.hashValue) {
            log.info("updateMerge found no possible changes")
            //return currentData
        } else {
            log.info("updateMerge found possible changes")
            log.info("updateMerge sending current data to peers for merging")

            sendProfile()
        }
        */
        
        log.info("***** updateMerge merging changes now ***************")

        if (shouldUpdate(currentData: currentData, receivedData: receivedData)) {
            //Update descriptors
            newData.name = receivedData.name
            newData.description = receivedData.description
            
            //Changes to author should not permeate
            newData.originalAuthor = currentData.originalAuthor
            newData.originalAuthorSimple = currentData.originalAuthorSimple
            
            //Update shoppingListLastClear
            if (currentData.shoppingListLastClear <= receivedData.shoppingListLastClear) {
                newData.shoppingListLastClear = receivedData.shoppingListLastClear
            } else {
                newData.shoppingListLastClear = currentData.shoppingListLastClear
            }
            
            //Update the categories array
            newData.categories = currentData.categories
            for item in receivedData.categories {
                if (!currentData.categories.contains(item)) {
                    newData.categories.append(item)
                }
            }
            
            //Update the locations array
            newData.locations = currentData.locations
            for item in receivedData.locations {
                if (!currentData.locations.contains(item)) {
                    newData.locations.append(item)
                }
            }
            
            //Update the units array
            newData.units = currentData.units
            for item in receivedData.units {
                if (!currentData.units.contains(item)) {
                    newData.units.append(item)
                }
            }

            //Merge the pantry change log
            newData.pantryChangeLog = currentData.pantryChangeLog
            newData.pantryChangeLog.append(contentsOf: receivedData.pantryChangeLog)
            //Remove duplicate changes
            let pantryChangeLogSet = Set(newData.pantryChangeLog)
            newData.pantryChangeLog = Array(pantryChangeLogSet)

            newData.pantryChangeLog = newData.pantryChangeLog.sorted()
                        
            //Merge the shopping list changelog
            newData.shoppingListChangeLog = currentData.shoppingListChangeLog
            newData.shoppingListChangeLog.append(contentsOf: receivedData.shoppingListChangeLog)
            //Remove duplicate changes
            let shoppingListChangeLogSet = Set(newData.shoppingListChangeLog)
            newData.shoppingListChangeLog = Array(shoppingListChangeLogSet)

            newData.shoppingListChangeLog = newData.shoppingListChangeLog.sorted()
            
            //Finish pantry and shopping list merge by rebuilding the data
            newData = rebuildData(profile: newData)
            
            //Now that data has been merged on this end, push local changes to connected peers
            
            //If the received data and current data, do not match, send current data to connected peers
            let receivedDataEncoded = receivedData.encode()
            let currentDataEncoded = currentData.encode()
            log.info("receivedDataEncoded.hashValue = \(receivedDataEncoded.hashValue)")
            log.info("currentDataEncoded.hashValue = \(currentDataEncoded.hashValue)")
            if(receivedDataEncoded.hashValue == currentDataEncoded.hashValue) {
                log.info("updateMerge found no possible changes")
                //return currentData
            } else {
                log.info("updateMerge found possible changes")
                log.info("updateMerge sending current data to peers for merging")

                userData.sendProfile()
            }
            
            log.info("***** updateMerge finished. Now returning updated Profile *****")
            //Return the new profile object
            return newData
        }
        
        //Default empty return statement
        newData = currentData
        return newData
    }
    
    func rebuildData(profile: Profile) -> Profile {
        log.info("rebuildData() called")
        
        var rebuiltProfile: Profile = profile
        
        //Rebuild Pantry
        log.info("Rebuilding Pantry")
        for change in profile.pantryChangeLog {
            switch change.changeType {
            case .insert:
                log.info("INSERT: \(change.oldObject.name) @ \(change.time)")
                rebuiltProfile.pantry.append(change.newObject)
            case .delete:
                if let index = rebuiltProfile.pantry.firstIndex(of: change.oldObject) {
                    log.info("DELETE: \(change.oldObject.name) @ \(change.time)")
                    rebuiltProfile.pantry.remove(at: index)
                } else {
                    log.error("FAILED to reconstruct pantryChange @ \(change.time) : DELETE : \(change.oldObject.name)")
                    log.error("\(change.oldObject.name) not found in Pantry")
                }
            case .modify:
                if let index = rebuiltProfile.pantry.firstIndex(of: change.oldObject) {
                    log.info("MODIFY: \(change.oldObject.name) @ \(change.time)")
                    rebuiltProfile.pantry[index] = change.newObject
                } else {
                    log.error("FAILED to reconstruct pantryChange @ \(change.time) : MODIFY : \(change.oldObject.name)")
                    log.error("\(change.oldObject.name) not found in Pantry")
                }
            }
        }
        
        //Rebuild Shopping List
        log.info("Rebuilding Shopping List")
        for change in profile.shoppingListChangeLog {
            switch change.changeType {
            case .insert:
                rebuiltProfile.shoppingList.append(change.newObject)
            case .delete:
                if let index = profile.shoppingList.firstIndex(of: change.oldObject) {
                    rebuiltProfile.shoppingList.remove(at: index)
                } else {
                    log.error("FAILED to reconstruct shoppingListChange @ \(change.time) : DELETE : \(change.oldObject.name)")
                    log.error("\(change.oldObject.name) not found in Shopping List")
                }
            case .modify:
                if let index = profile.shoppingList.firstIndex(of: change.oldObject) {
                    rebuiltProfile.shoppingList[index] = change.newObject
                } else {
                    log.error("FAILED to reconstruct shoppingListChange @ \(change.time) : MODIFY : \(change.oldObject.name)")
                    log.error("\(change.oldObject.name) not found in Shopping List")
                }
            }
        }
        
        return rebuiltProfile
    }
    
    //MARK: - Data Persistence
    
    //URL address on user device for app memory
    let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("profiles_v_1_1").appendingPathExtension("json")
    
    /**
     Saves the array of profile objects representing user data to a .json file.
     */
    func saveProfileData() {
        log.info("ProfileModelController writing profiles[] to disk")
        
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
        
        guard let retrievedProfileData = try? Data(contentsOf: archiveURL) else {
            log.info("Profile data not found")
            let decodedProfiles = loadOldProfileData()
            
            return decodedProfiles
        } //Pulls json encoded profile data
        
        let decodedProfiles: [Profile]? = try? jsonDecoder.decode(Array<Profile>.self, from: retrievedProfileData) //Decodes JSON profile data
        
        return decodedProfiles
    }
    
    /**
    Pulls old user data from selected .json file. Will automatically convert old data to proper format for current data model
     
     - Returns: Optional array of old profile objects, updated to current version of data model
     */
    private func loadOldProfileData() -> [Profile]? {
        log.info("Searching for old profile data")
        //decoder for handling json files
        let jsonDecoder = JSONDecoder()
        
        log.info("Trying 1.0.2 data")
        //URL address on user device for app memory
        let archiveURL_1_0_2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("profiles").appendingPathExtension("json")
        //Try 1.0.2 archive data
        if let retrievedOldProfileData = try? Data(contentsOf: archiveURL_1_0_2) {
            log.info("Found 1.0.2 data")
            log.info("Decoding 1.0.2 data")
            let decodedOldProfiles: [ProfileV1_0_2]? = try? jsonDecoder.decode(Array<ProfileV1_0_2>.self, from: retrievedOldProfileData) //Decodes JSON profile data
            
            //Convert 1.0.2 Profile data to 1.1 Profile data
            log.info("Migrating 1.0.2 data to 1.1 standard")
            
            //New profile data object to meet current data model standard
            var updatedProfiles: [Profile] = []
            
            var index = 0
            for profile in decodedOldProfiles ?? [] {
                updatedProfiles.append(Profile(name: "", pantry: [], shoppingList: [], categories: [], locations: [], units: []))
                //transfer data to V1.1 profile data model
                updatedProfiles[index].name = profile.name
                updatedProfiles[index].originalAuthor = profile.originalAuthor
                updatedProfiles[index].originalAuthorSimple = profile.originalAuthorSimple
                updatedProfiles[index].description = profile.description
                updatedProfiles[index].pantryCollateKey = profile.pantryCollateKey
                
                updatedProfiles[index].categories = profile.categories
                updatedProfiles[index].locations = profile.locations
                updatedProfiles[index].units = profile.units
                
                //Move pantry item data model to V1.1
                var pantryIndex = 0
                for item in profile.pantry {
                    updatedProfiles[index].pantry.append(PantryItem(id: pantryIndex,
                                                                    name: item.name,
                                                                    category: item.category,
                                                                    location: item.location,
                                                                    currentQuantity: item.currentQuantity,
                                                                    units: item.units,
                                                                    note: item.note,
                                                                    lastUpdate: item.lastUpdate))
                    
                    
                    updatedProfiles[index].pantry[pantryIndex].neededQuantity = item.neededQuantity
                    updatedProfiles[index].pantry[pantryIndex].purchaseStatus = item.purchaseStatus

                    pantryIndex += 1
                }
                
                //Recreate shopping list
                for item in profile.shoppingList {
                    //Find index of matching item
                    var matchingItem: PantryItem = PantryItem(id: 0, name: "", category: "", location: "", currentQuantity: 0, units: "", note: "", lastUpdate: Date())
                    for pantryItem in updatedProfiles[index].pantry {
                        if(pantryItem.name == item.name &&
                           pantryItem.category == item.category &&
                           pantryItem.location == item.location &&
                           pantryItem.currentQuantity == item.currentQuantity &&
                           pantryItem.units == item.units &&
                           pantryItem.neededQuantity == item.neededQuantity &&
                           pantryItem.note == item.note &&
                           pantryItem.purchaseStatus == item.purchaseStatus) {
                            //copy matching pantry item into shopping list
                            matchingItem = pantryItem
                        }
                    }
                    
                    updatedProfiles[index].shoppingList.append(matchingItem)
                }
                
                //Move to next row for updated profiles
                index += 1
            }
            
            return updatedProfiles
        } //Pulls json encoded profile data
        
        return nil
    }
    
    /**
    Loads sample profile data.
     
     Can be used in cases where existing user data does not exist yet. Creates full data set to make debugging easier after first install and can give user an example to play with. 
     
     - Returns: Single profile with a prefilled pantry and shopping list.
     */
    func loadSampleProfile() -> [Profile]? {
        log.info("Loading sample profile data")
        
        let sampleProfile: [Profile] = []
        
        /*
        var sampleProfile: [Profile] = [Profile(
        name: "Queen Anne's Revenge",
        pantry: [
        PantryItem(name: "Cookies", category: "Snacks", location: "Cookie Jar", currentQuantity: 12, units: "Cookies", note: "Very tasty, chocochip cookies", lastUpdate: Date()),
        PantryItem(name: "Bagels", category: "Breads", location: "Galley Counter", currentQuantity: 6, units: "Bagels", note: "Quick, wholesome, and healthy breakfast", lastUpdate: Date()),
        PantryItem(name: "Peanut Butter", category: "Staples", location: "Cupboard", currentQuantity: 3, units: "Jars", note: "Use in a sandwich", lastUpdate: Date()),
        PantryItem(name: "Strawberry Jelly", category: "Preserves", location: "Fridge", currentQuantity: 2, units: "Jars", note: "Sweet strawberry jelly", lastUpdate: Date()),
        PantryItem(name: "Bread", category: "Breads", location: "Bread Box", currentQuantity: 4, units: "Loaves", note: "Good for making sandwiches", lastUpdate: Date())],
        shoppingList:
            [PantryItem(name: "Cookies", category: "Snacks", location: "Cookie Jar", currentQuantity: 12, units: "Cookies", note: "Very tasty, chocochip cookies", lastUpdate: Date())],
        categories: ["Snacks", "Breads", "Staples", "Preserves"],
        locations: ["Cookie Jar", "Galley Counter", "Cupboard", "Fridge", "Bread Box"],
        units: ["Cookies", "Bagels", "Jars", "Loaves"])]
        
        sampleProfile[0].description = "Blackbeard's ship. This is a sample profile, feel free to change as you see fit."
        
        sampleProfile[0].shoppingList[0].purchaseStatus = .toBuy
        */
        
        return sampleProfile
    }
}
