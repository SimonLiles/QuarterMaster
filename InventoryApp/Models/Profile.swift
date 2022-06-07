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
struct Profile: Codable {
    
    //Identifying information
    var name: String //Name of the profile
    
    var originalAuthor: String = UIDevice.current.identifierForVendor?.uuidString ?? "NO_AUTHOR" //ID of the device that authored the profile
    var originalAuthorSimple: String = UIDevice.current.name //Name of the device that authored the profile. Is not unique
    
    //Data holding
    var pantry: [PantryItem] //Holds pantry for the profile instance
    var shoppingList: [PantryItem] //Holds shopping list data for profile instance
    
    var categories: [String] //Holds all possible categories for pantry
    var locations: [String] //Holds all possible locations for pantry
    var units: [String] //Holds all possible units for pantry
    
    var description: String = "" //Description of the profile
    
    var pantryCollateKey: String = "Category" //Key for orgainizing the pantry
    
    //Data used for sharing

    var versionTimeStamp: Date = Date() //Holds time and date of last saved update to Profile
    
    var shoppingListLastClear: Date = Date()
        
    init(name: String, pantry: [PantryItem], shoppingList: [PantryItem], categories: [String], locations: [String], units: [String]) {
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

extension Profile: Equatable {
    static func == (lhs: Profile, rhs: Profile) -> Bool{
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
    func isExactMatch(item1: Profile, item2: Profile) -> Bool {
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
