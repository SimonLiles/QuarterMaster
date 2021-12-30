//
//  Ingredient.swift
//  InventoryApp
//
//  Essentially the same as PantryItem, but smaller and less features
//
//  Created by Simon Liles on 7/2/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

struct Ingredient: Codable {
    var name: String
    var location: String
    var quantity: Double
    var units: String
}
