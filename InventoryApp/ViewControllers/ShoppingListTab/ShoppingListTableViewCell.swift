//
//  ShoppingListTableViewCell.swift
//  InventoryApp
//
//  Created by Simon Liles on 7/6/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class ShoppingListTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var statusButton: UIButton!
    
    // MARK: - Variables and Constants
    let profileIndex = ProfileModelController.shared.selectedIndex
    
    var item: PantryItem = PantryItem(name: "", category: "", location: "", currentQuantity: 0, units: "", note: "", lastUpdate: Date())
    
    var indexPath: IndexPath = IndexPath()
    
    var buttonIndex = 0
    
    var purchaseStatus: PurchaseStatus {
        //Set Button state from memory
        return item.purchaseStatus
    }
    
    //Initializes images for button
    let toBuyImage: UIImage? = UIImage(systemName: "circle")
    let boughtImage: UIImage? = UIImage(systemName: "checkmark.circle")
    let notBoughtImage: UIImage? = UIImage(systemName: "x.circle")
    
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
    
    //Update the cell with data for the shopping list from  a pantry item object
    func update(with shoppingListItem: PantryItem, at path: IndexPath) {
        
        //Collect data from parameters to use locally in TableViewCell Class
        item = shoppingListItem
                
        //Update the cell GUI
        itemLabel.text = item.name
        quantityTextField.text = String(item.neededQuantity)
        quantityStepper.value = item.neededQuantity
                
        //Sets image for button based on purchase status
        switch item.purchaseStatus {
        case .bought: //Sets status to bought when user taps
            statusButton.setImage(boughtImage, for: .normal)
            statusButton.tintColor = .systemGreen
            //print("Status: Bought")
        case .notBought: //Sets status to not bought when user taps
            statusButton.setImage(notBoughtImage, for: .normal)
            statusButton.tintColor = .systemRed
            //print("Status: Not Bought")
        default: //Sets status to to buy when user taps and resets the index of the button
            statusButton.setImage(toBuyImage, for: .normal)
            statusButton.tintColor = .systemBlue
            //print("Status: To Buy")
        }
        
        //Update model object data
        //Ugly code to update a specific item from the array
        //I keep using this code block everywhere, maybe abstract it into a function of a controller or model?
        let itemToChange = item
        
        var index = 0
        for item in ProfileModelController.shared.profiles![profileIndex].shoppingList {
            if itemToChange == item {
                break
            } else {
                index += 1
            }
        }
        ProfileModelController.shared.profiles![profileIndex].shoppingList[index] = itemToChange
        
        //Update pantry purchase statuses
        //let pantryItemToChange = item
        var pantryIndex = 0
        for item in ProfileModelController.shared.profiles![profileIndex].pantry {
            if itemToChange == item {
                break
            } else {
                pantryIndex += 1
            }
        }
        ProfileModelController.shared.profiles![profileIndex].pantry[pantryIndex] = itemToChange
        
    }
    
    // MARK: - IBActions
    
    //Updates cell and model data when quantity is stepped
    @IBAction func quantityStepped(_ sender: UIStepper) {
        item.neededQuantity = quantityStepper.value
        
        item.lastUpdate = Date()
        
        update(with: item, at: indexPath)
    }
    
    //Updates cell and model data when value in text field is changed
    @IBAction func quantityChanged(_ sender: UITextField) {
        let newQuantity = Double(sender.text!)
        
        item.neededQuantity = newQuantity!
        
        item.lastUpdate = Date()
        
        update(with: item, at: indexPath)
    }
    
    //Updates cell and model data when button is pressed
    @IBAction func statusButtonPressed(_ sender: Any) {
        //print("Purchase Status Button Pressed")
        
        //Code to run button states
        
        //Runs through all potential cases of the button state
        switch item.purchaseStatus {
        case .toBuy: //Sets status to bought when user taps
            item.purchaseStatus = .bought
            
            //print("Status: Bought")
        case .bought: //Sets status to not bought when user taps
            item.purchaseStatus = .notBought
            
            //print("Status: Not Bought")
        default: //Sets status to to buy when user taps and resets the index of the button
            item.purchaseStatus = .toBuy
            
            //print("Status: To Buy")
        }
        
        item.lastUpdate = Date()
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: ShoppingListModelController.sharedShoppingList)
        
        //Update model object data
        //Ugly code to update a specific item from the array
        //I keep using this code block everywhere, maybe abstract it into a function of a controller or model?
        let itemToChange = item
        
        var index = 0
        for item in ProfileModelController.shared.profiles![profileIndex].shoppingList {
            if itemToChange == item {
                break
            } else {
                index += 1
            }
        }
        ProfileModelController.shared.profiles![profileIndex].shoppingList[index] = itemToChange
        
        //Update pantry purchase statuses
        //let pantryItemToChange = item
        var pantryIndex = 0
        for item in ProfileModelController.shared.profiles![profileIndex].pantry {
            if itemToChange == item {
                break
            } else {
                pantryIndex += 1
            }
        }
        ProfileModelController.shared.profiles![profileIndex].pantry[pantryIndex] = itemToChange
        
        update(with: item, at: indexPath)
    }
}
