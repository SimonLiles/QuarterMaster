//
//  PantryController.swift
//  InventoryApp
//
//  Created by Simon Liles on 5/28/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

/*
class PantryModelController {
    
    static let shared = PantryModelController() //Allows PantryModelController data to be used everywhere without using segues
    
    var pantry: [PantryItem]?
    
    //MARK: - Pantry Functionality
    
    //Returns an array of categories as Strings
    func getCategories() -> [String] {
        var categories: [String] = []
        
        //Gather info from each item in pantry
        for item in pantry! {
            //If location is unique in locations array, append it to the end
            if !categories.contains(item.category) {
                categories.append(item.category)
            }
        }
        
        return categories
    }
    
    //Returns an array of Locations as strings
    func getLocations() -> [String] {
        var locations: [String] = []
        
        //Gather info from each item in pantry
        for item in pantry! {
            //If location is unique in locations array, append it to the end
            if !locations.contains(item.location) {
                locations.append(item.location)
            }
        }
        
        return locations
    }
    
    //Returns a string array of units
    func getUnits() -> [String] {
        var units: [String] = []
        
        //Gather info from each item in pantry
        for item in pantry! {
            //If location is unique in locations array, append it to the end
            if !units.contains(item.units) {
                units.append(item.units)
            }
        }
        
        return units
    }
    
    //MARK: - Data Persistance Handling
    
    //URL address on user device for app memory
    let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("pantry").appendingPathExtension("json")
    
    //Encodes and saves user data to disk as .json
    func savePantryData() {
        let jsonEncoder = JSONEncoder()
        let encodedPantry = try? jsonEncoder.encode(pantry) //encode the pantry
        
        //let pListEncoder = PropertyListEncoder()
        //let encodedPantry = try? pListEncoder.encode(pantry) //encode the pantry
        
        try? encodedPantry?.write(to: archiveURL) //write pantry data to json file
    }
    
    //Pulls user data from disk and decodes from .json
    func loadPantryData() -> [PantryItem]? {
        let jsonDecoder = JSONDecoder()
        
        //let pListDecoder = PropertyListDecoder()
        
        guard let retrievedPantryData = try? Data(contentsOf: archiveURL) else {return nil} //Grabs json encoded pantry data
        
        let decodedPantry: [PantryItem]? = try? jsonDecoder.decode(Array<PantryItem>.self, from: retrievedPantryData) //decodes JSON pantry data
        //let decodedPantry: [PantryItem]? = try? pListDecoder.decode(Array<PantryItem>.self, from: retrievedPantryData)
        
        return decodedPantry
    }
    
    //Returns sample data in case there is no data on disk, such as when app is first opened. 
    func loadSamplePantryData() -> [PantryItem]? {
        let samplePantry: [PantryItem] = [
            PantryItem(name: "Cookies", category: "Snacks", location: "Cookie Jar", currentQuantity: 12, units: "Cookies", note: "Very tasty, chocochip cookies"),
            PantryItem(name: "Bagels", category: "Breads", location: "Galley Counter", currentQuantity: 6, units: "Bagels", note: "Quick, wholesome, and healthy breakfast"),
            PantryItem(name: "Peanut Butter", category: "Staples", location: "Cupboard", currentQuantity: 3, units: "Jars", note: "Use in a sandwich"),
            PantryItem(name: "Strawberry Jelly", category: "Preserves", location: "Fridge", currentQuantity: 2, units: "Jars", note: "Sweet strawberry jelly"),
            PantryItem(name: "Bread", category: "Breads", location: "Bread Box", currentQuantity: 4, units: "Loaves", note: "Good for making sandwiches")]
        
        return samplePantry
    }
}
 */
