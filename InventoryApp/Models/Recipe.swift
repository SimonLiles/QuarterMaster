//
//  Pantry.swift
//  InventoryApp
//
//  Recipe model structure to be used for planning
//
//  Created by Simon Liles on 5/27/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

struct Recipe: Codable {
    var name: String // Name of the recipe
    var category: String // Category of the recipe
    var ingredients: [String: Double] // Ingredients needed for the recipe
    var servings: Int
    var prepTime: Int // Estimated time to prepare recipe
    var instructions: String // Instructions to make recipe
}

extension Recipe: Equatable {
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.name == rhs.name && lhs.ingredients == rhs.ingredients && lhs.prepTime == rhs.prepTime && lhs.instructions == rhs.instructions
    }
}
