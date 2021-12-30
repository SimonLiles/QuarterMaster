//
//  Profile.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/13/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

/**
 Profile model structure holds the pantry and shopping list together so that a profile can be shared with other devices.
 
 - ```name: String``` is the name of the profile object and acts as an indentifier for the user
 
 - ToDo: Include more structure to allow for sharing functionality, consider permissions, allowed devices, etc.
 */
struct Profile: Codable {
    
    //Identifying information
    var name: String //Name of the profile
    
    //Data holding
    var pantry: [PantryItem] //Holds pantry for the profile instance
    var shoppingList: [PantryItem] //Holds shopping list data for profile instance
    
    var description: String = "" //Description of the profile
    
    //Data used for sharing
    
    init(name: String, pantry: [PantryItem], shoppingList: [PantryItem]) {
        self.name = name
        self.pantry = pantry
        self.shoppingList = shoppingList
    }
}
