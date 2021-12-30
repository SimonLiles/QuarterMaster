//
//  RecipeModelController.swift
//  InventoryApp
//
//  Created by Simon Liles on 7/1/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

class RecipeModelController {
    
    static var sharedRecipes = RecipeModelController()
    
    var recipes: [Recipe] = []
    
    //MARK: Data Persistance Handling
    
    //URL address on user device for app memory
    let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("shoppingList").appendingPathExtension("json")
    
    //Encodes and saves user data to disk as .json
    func saveRecipesData() {
        let jsonEncoder = JSONEncoder()
        let encodedRecipes = try? jsonEncoder.encode(recipes) //encode the recipes
                
        try? encodedRecipes?.write(to: archiveURL) //write recipe data to json file
    }
    
    //Pulls user data from disk and decodes from .json
    func loadRecipesData() -> [Recipe]? {
        let jsonDecoder = JSONDecoder()
                
        guard let retrievedRecipeData = try? Data(contentsOf: archiveURL) else {return nil} //Grabs json encoded recipe data
        
        let decodedRecipes: [Recipe]? = try? jsonDecoder.decode(Array<Recipe>.self, from: retrievedRecipeData) //decodes JSON recipe data
        
        return decodedRecipes
    }
    
    //Returns sample data in case there is no saved data on disk, such as when app is first opened.
    // MARK: - TODO-> Fill in Sample Data
    func loadSampleRecipesData() -> [Recipe]? {
        let sampleRecipes: [Recipe] = [Recipe(name: "PB & J", category: "Sandwiches", ingredients: ["Peanut Butter": 1, "Jelly": 1, "Bread": 2], servings: 1, prepTime: 5, instructions: "Spread peanut butter on one slice, and Jelly on the other slice. Put the two slices together and enjoy.")]
        
        return sampleRecipes
    }

}
