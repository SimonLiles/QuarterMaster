//
//  PantryTableViewCell.swift
//  InventoryApp
//
//  Created by Simon Liles on 6/22/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class PantryTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    // MARK: - Variables & Constants
    
    let profileIndex = userData.selectedIndex
    
    //creates empty PantryItem object to later fill
    var pantryItem1 = PantryItem(id: 0, name: "", category: "", location: "", currentQuantity: 0, units: "", note: "", lastUpdate: Date())
    
    var indexpath: IndexPath = IndexPath()
    
    var collateKey: String = ""
    
    //Object to collect and store logs.
    let log = Logger()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Update the cell with data from a PantryItem object
    /**
     Updates pantry tableview cell with data from a pantryItem object
     
        - Parameter pantryItem: holds pantryItem object for a specific cell
        - Parameter path: indexPath object
        - Parameter collateKey: string representing the collate key
     */
    func update(with pantryItem: PantryItem, at path: IndexPath, with collateKey: String) {
        
        //collect data from parameters to use locally in TableViewCell Class
        pantryItem1 = pantryItem
        indexpath = path
        self.collateKey = collateKey
        
        //Update the cell GUI
        nameLabel.text = pantryItem.name
        //locationLabel.text = pantryItem.location
        quantityTextField.text = String(pantryItem.currentQuantity)
        quantityStepper.value = pantryItem1.currentQuantity
        
        switch collateKey {
        case "Category":
            locationLabel.text = pantryItem.location
        case "Location":
            locationLabel.text = pantryItem.category
        case "Units":
            locationLabel.text = pantryItem.category
        default:
            log.error("ERROR: PantryTableView -> Unknown collateKey")
            locationLabel.text = "ERROR: Unknown collateKey"
        }
        
        //Somehow this works,
        //need it to keep index out range error from occuring when pantry is empty
        guard userData.profiles![profileIndex].pantry.endIndex != 0 else { return }
        
        //Update model object data
        //Ugly code to update a specific item from the array
        let pantryItemToChange = pantryItem1
        
        let index = userData.profiles![profileIndex].pantry.firstIndex(of: pantryItemToChange) ?? 0
        
        //PantryModelController.shared.pantry![index] = pantryItemToChange
        userData.profiles![profileIndex].pantry[index] = pantryItemToChange
        
        //userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .modify, newObject: pantryItem, oldObject: pantryItemToChange))

        //Update corresponding item in shoppingList if item exists there
        if (userData.profiles![profileIndex].shoppingList.contains(pantryItemToChange)) {
            let shoppingListIndex = userData.profiles![profileIndex].shoppingList.firstIndex(of: pantryItemToChange) ?? 0
            
            userData.profiles![profileIndex].shoppingList[shoppingListIndex] = pantryItemToChange
            userData.profiles![profileIndex].shoppingList[shoppingListIndex].lastUpdate = Date()
        }
        
        //Tell ShoppingList Tab to reload data with new shoppingList data
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)

        //log.info("ProfileModelController saved user data after updating pantryItem cells")
        //log.info("Sending profile data to connected peers because of PantryItemCell update")
        //userData.sendProfile()
    }

    // MARK: - IBActions
    
    //Updates cell and model data
    @IBAction func quantityStepped(_ sender: UIStepper) {
        let oldPantryItem = pantryItem1
        
        pantryItem1.currentQuantity = quantityStepper.value
        
        pantryItem1.lastUpdate = Date()

        //let pantryItemToChange = pantryItem1
        
        //let index = userData.profiles![profileIndex].pantry.firstIndex(of: pantryItemToChange) ?? 0
        
        //userData.profiles![profileIndex].pantry[index] = pantryItemToChange
        
        update(with: pantryItem1, at: indexpath, with: collateKey)
        
        userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .modify, newObject: pantryItem1, oldObject: oldPantryItem))
    }
    
    //Updates cell and model data when value in text field is changed
    @IBAction func quantityChanged(_ sender: UITextField) {
        let oldPantryItem = pantryItem1
        let newQuantity = Double(sender.text!)
                
        
        pantryItem1.currentQuantity = newQuantity ?? 0
        
        pantryItem1.lastUpdate = Date()
        
        update(with: pantryItem1, at: indexpath, with: collateKey)
        
        userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .modify, newObject: pantryItem1, oldObject: oldPantryItem))
    }
}
