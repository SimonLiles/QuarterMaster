//
//  Profile.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/13/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation
import UIKit

/**
 Profile model structure holds the pantry and shopping list together so that a profile can be shared with other devices.
 
 - ```name```: is the name of the profile object and acts as an indentifier for the user
 
 - ToDo: Include more structure to allow for sharing functionality, consider permissions, allowed devices, etc.
 */
struct ProfileV1_0_2: Codable {
    
    //Identifying information
    var name: String //Name of the profile
    
    var originalAuthor: String = UIDevice.current.identifierForVendor?.uuidString ?? "NO_AUTHOR" //ID of the device that authored the profile
    var originalAuthorSimple: String = UIDevice.current.name //Name of the device that authored the profile. Is not unique
    
    //Data holding
    var pantry: [PantryItemV1_0_2] //Holds pantry for the profile instance
    var shoppingList: [PantryItemV1_0_2] //Holds shopping list data for profile instance
    
    var categories: [String] //Holds all possible categories for pantry
    var locations: [String] //Holds all possible locations for pantry
    var units: [String] //Holds all possible units for pantry
    
    var description: String = "" //Description of the profile
    
    var pantryCollateKey: String = "Category" //Key for orgainizing the pantry
    
    //Data used for sharing

    var versionTimeStamp: Date = Date() //Holds time and date of last saved update to Profile
    
    var shoppingListLastClear: Date = Date()
        
    init(name: String, pantry: [PantryItemV1_0_2], shoppingList: [PantryItemV1_0_2], categories: [String], locations: [String], units: [String]) {
        self.name = name
        self.pantry = pantry
        self.shoppingList = shoppingList
        
        self.categories = categories
        self.locations = locations
        self.units = units
    }
    
    /**
     Encodes single profile object representing user data to a .json file.
     */
    func encode() -> Data? {
        log.info("Attempting to encode profile data")
        
        let jsonEncoder = JSONEncoder()
        let encodedProfileObject = try? jsonEncoder.encode(self) //encode the profile object
        
        return encodedProfileObject
    }
    
    func decode(data: Data) -> Profile {
        log.info("Attempting to decode Profile Data")
        
        let jsonDecoder = JSONDecoder()
                
        let decodedProfile: Profile? = try? jsonDecoder.decode(Profile.self, from: data) //Decodes JSON profile data
        
        return decodedProfile!
    }
}

extension ProfileV1_0_2: Equatable {
    static func == (lhs: ProfileV1_0_2, rhs: ProfileV1_0_2) -> Bool{
        if (lhs.name == rhs.name && lhs.originalAuthor == rhs.originalAuthor) {
            return true
        } else {
            return false
        }
    }
    
    /**
     Determines if two Profiles are an exact match.
     
     - Parameters:
        - item1: A Profile Object to be compared
        - item2: A Profile Object to be compared
     
     Returns a boolean value for `true` if all properties in each item are the same. Otherwise it will return false.
     */
    func isExactMatch(item1: ProfileV1_0_2, item2: ProfileV1_0_2) -> Bool {
        //Check singleton properties first
        
        //If names are not equal, return false
        if(item1.name != item2.name) {
            return false
        }
        
        //If descriptions are not equal, return false
        if(item1.description != item2.description) {
            return false
        }
        
        //Check if Pantries are the same
        
        //Are the pantries the same length? If not, return false
        if(item1.pantry.count != item2.pantry.count) {
            return false
        }
        
        //Check if all elements of one, exist in the other
        //Because the lengths have already been checked to be the same, if all of one exists in the other, they must be the same
        for element1 in item1.pantry {
            var index = 1
            for element2 in item2.pantry {
                //If the 2nd pantry contains an item from the 1st, then break out of the inner for loop
                if (element1.isExactMatch(item1: element1, item2: element2)) {
                    break
                }
                
                index += 1
            }
            
            //If the index reaches the end, and the last element of the 2nd pantry is not equal to the current element, return false
            if (index >= item1.pantry.count && element1 != item2.pantry[item2.pantry.count - 1]) {
                return false
            }
        }
        
        //Check if shopping lists are the same
        //Are the shoppingLists the same length? If not, return false
        if(item1.shoppingList.count != item2.shoppingList.count) {
            return false
        }
        
        //Check if all elements of one, exist in the other
        //Because the lengths have already been checked to be the same, if all of one exists in the other, they must be the same
        for element1 in item1.shoppingList {
            var index = 1
            for element2 in item2.shoppingList {
                //If the 2nd shoppingList contains an item from the 1st, then break out of the inner for loop
                if (element1.isExactMatch(item1: element1, item2: element2)) {
                    break
                }
                
                index += 1
            }
            
            //If the index reaches the end, and the last element of the 2nd shoppingList is not equal to the current element, return false
            if (index >= item1.shoppingList.count && element1 != item2.shoppingList[item2.shoppingList.count - 1]) {
                return false
            }
        }
        
        log.info("Both Profiles are an exact match")
        return true
    }
}

/**
 **OLD PANTRY ITEM DATA**
 
 This struct provides backwards compatibility after upgrading PantryItem.swift
 
 The backbone of the pantry inventory management software, the PantryItem model. The PantryItem model is subclassed as Codable,  Equatable, and Hashable, thus allowing it to be encoded, decoded, equated, and be used as a key in dictionaries.
 
 - Variables: a pantryItem has a name, category, location, current quantity, needed quantity, units, a note, and a purchase status
    - name: String, name of the item
    - category: String, Category the item belongs to
    - location: String, Where the item is stored
    - currentQuantity: Double, How much of the item is currently being stored
    - neededQuantity: Double, How much of the item is needed, defaults to 1
    - units: String, How the amount of the item is measured
    - note: String, Allows user to add notes regarding the item
    - purchaseStatus: PurchaseStatus, Indicates wether an item has been purchased, canceled, or needs to be bought. Defualts to `.toBuy`
 
 
 - Important: Initialization of the PantryItem object can only be done with a name, category, location, currentQuantity, units, and the note, the other values must be set outside of the initializer
 */
struct PantryItemV1_0_2: Codable, Hashable {
    ///name of the item
    var name: String
    ///Category the item belongs to
    var category: String
    ///Where the item is stored
    var location: String
    ///How much of the item is currently being stored
    var currentQuantity: Double
    ///How much of the item is needed, preset to 1
    var neededQuantity: Double = 1
    ///How the amount of the item is measured
    var units: String
    
    ///Allows user to add notes regarding the item
    var note: String
    
    ///Indicates wether an item has been purchased, canceled, or needs to be bought
    var purchaseStatus: PurchaseStatus = .toBuy
    
    var lastUpdate: Date
    
    /**Initialization of the PantryItem object can only be done with a name, category, location, currentQuantity, units, and the note, the other values must be set outside of the initializer
     
        - Parameter name: the name of the item
        - Parameter category: Category the item belongs to
        - Parameter location: Where the item is stored
        - Parameter currentQuantity: How much of the item is currently being stored
        - Parameter units: How the amount of the item is measured
        - Parameter note: Allows user to add notes regarding the item
     */
    init(name: String, category: String, location: String, currentQuantity: Double, units: String, note: String, lastUpdate: Date) {
        self.name = name
        self.category = category
        self.location = location
        self.currentQuantity = currentQuantity
        self.units = units
        self.note = note
        self.lastUpdate = lastUpdate
    }
}

extension PantryItemV1_0_2: Equatable {
    static func == (lhs: PantryItemV1_0_2, rhs: PantryItemV1_0_2) -> Bool {
        return lhs.name == rhs.name && lhs.category == rhs.category && lhs.location == rhs.location && lhs.units == rhs.units
    }
    
    /**
     Determines if two PantryItems are an exact match.
     
     - Parameters:
        - item1: A PantryItem to be compared
        - item2: A PantryItem to be compared
     
     Returns a boolean value for `true` if all properties in each item are the same. Otherwise it will return false.
     */
    func isExactMatch(item1: PantryItemV1_0_2, item2: PantryItemV1_0_2) -> Bool {
        if(item1.name == item2.name && item1.category == item2.category && item1.location == item2.location && item1.currentQuantity == item2.currentQuantity && item1.units == item2.units && item1.neededQuantity == item2.neededQuantity && item1.note == item2.note && item1.purchaseStatus == item2.purchaseStatus && item1.lastUpdate == item2.lastUpdate) {
            return true
        } else {
            return false
        }
    }
}

