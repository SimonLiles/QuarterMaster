//
//  PantryItem.swift
//  InventoryApp
//
//  PantryItem model is a base for all pantry items
//
//  Created by Simon Liles on 5/26/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

/**
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
struct PantryItem: Codable, Hashable {
    ///Unique integer representing item ID
    var id: Int
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
    init(id: Int, name: String, category: String, location: String, currentQuantity: Double, units: String, note: String, lastUpdate: Date) {
        self.id = id
        self.name = name
        self.category = category
        self.location = location
        self.currentQuantity = currentQuantity
        self.units = units
        self.note = note
        self.lastUpdate = lastUpdate
    }
}

extension PantryItem: Equatable {
    static func == (lhs: PantryItem, rhs: PantryItem) -> Bool {
        return lhs.name == rhs.name && lhs.category == rhs.category && lhs.location == rhs.location && lhs.units == rhs.units
    }
    
    /**
     Determines if two PantryItems are an exact match.
     
     - Parameters:
        - item1: A PantryItem to be compared
        - item2: A PantryItem to be compared
     
     Returns a boolean value for `true` if all properties in each item are the same. Otherwise it will return false. 
     */
    func isExactMatch(item1: PantryItem, item2: PantryItem) -> Bool {
        if(item1.name == item2.name && item1.category == item2.category && item1.location == item2.location && item1.currentQuantity == item2.currentQuantity && item1.units == item2.units && item1.neededQuantity == item2.neededQuantity && item1.note == item2.note && item1.purchaseStatus == item2.purchaseStatus && item1.lastUpdate == item2.lastUpdate) {
            return true
        } else {
            return false
        }
    }
}

/**
 Purchase status enumeration, defines the three states purchase status can be at any point in time, toBuy, bought, and notBought
 
 Purchase Status is subclassed as Codable to allow for encoding. The decoder will throw the error below when the decoder receives an inappropriate key from the file.
 ```
 Unable to decode PurchaseStatus enum
 ```
 */
enum PurchaseStatus {
    ///Used to indicate the user intends to buy the item
    case toBuy
    ///Used to indicate the user has bought the item
    case bought
    ///Used to indicate the user intends to buy the item
    case notBought
}


extension PurchaseStatus: Codable {
    enum CodingKeys: CodingKey {
        case toBuy
        case bought
        case notBought
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .toBuy:
            self = .toBuy
        case .bought:
            self = .bought
        case .notBought:
            self = .notBought
        default:
            log.fault("Critical Fault: Unable to decode PurchaseStatus enum")
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unable to decode PurchaseStatus enum"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .toBuy:
            try container.encode(true, forKey: .toBuy)
        case.bought:
            try container.encode(true, forKey: .bought)
        case.notBought:
            try container.encode(true, forKey: .notBought)
        }
    }
    
}

