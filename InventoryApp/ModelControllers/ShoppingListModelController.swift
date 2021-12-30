//
//  ShoppingListModelController.swift
//  InventoryApp
//
//  Created by Simon Liles on 7/1/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

/*
class ShoppingListModelController {
    
    static var sharedShoppingList = ShoppingListModelController()
    
    var shoppingList: [PantryItem] = []
    
    //MARK: Data Persistance Handling
    
    //URL address on user device for app memory
    let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("shoppingList").appendingPathExtension("json")
    
    //Encodes and saves user data to disk as .json
    func saveShoppingListData() {
        let jsonEncoder = JSONEncoder()
        let encodedShoppingList = try? jsonEncoder.encode(shoppingList) //encode the shopping list
                
        try? encodedShoppingList?.write(to: archiveURL) //write shopping list data to json file
    }
    
    //Pulls user data from disk and decodes from .json
    func loadShoppingListData() -> [PantryItem]? {
        let jsonDecoder = JSONDecoder()
                
        guard let retrievedShoppingListData = try? Data(contentsOf: archiveURL) else {return nil} //Grabs json encoded shopping list data
        
        let decodedShoppingList: [PantryItem]? = try? jsonDecoder.decode(Array<PantryItem>.self, from: retrievedShoppingListData) //decodes JSON shopping list data
        
        return decodedShoppingList
    }
    
    //Returns sample data in case there is no saved data on disk, such as when app is first opened.
    //In this case it returns just cookies for testing purposes
    func loadSampleShoppingListData() -> [PantryItem]? {
        var sampleShoppingList: [PantryItem] = [PantryItem(name: "Cookies", category: "Snacks", location: "Cookie Jar", currentQuantity: 12, units: "Cookies", note: "Very tasty, chocochip cookies")]
        
        sampleShoppingList[0].purchaseStatus = .toBuy
        
        return sampleShoppingList
    }
}
*/
