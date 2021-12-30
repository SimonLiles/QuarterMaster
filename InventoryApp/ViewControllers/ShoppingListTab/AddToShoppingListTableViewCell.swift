//
//  AddToShoppingListTableViewCell.swift
//  InventoryApp
//
//  Created by Simon Liles on 7/8/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

class AddToShoppingListTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var checkMarkButton: UIButton!
    
    // MARK: - Constants and Variables
    let profileIndex = ProfileModelController.shared.selectedIndex
    
    var shoppingListItem: PantryItem = PantryItem(name: "", category: "", location: "", currentQuantity: 0, units: "", note: "")
    
    var itemIsChecked: Bool = false
    
    //Images to use for the check mark
    let circleImage = UIImage(systemName: "circle")
    let checkMarkCircle = UIImage(systemName: "checkmark.circle")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Updates entities in the cell (See Mom, I can speak CS Student too!)
    func update(with item: PantryItem) {
        
        shoppingListItem = item
        
        //Some more of my fugly code to run through an array to find an item and do a thing
        //In this case it makes items in the list have checkmarks if they are already on the shopping list
        var index = 0
        for item in ProfileModelController.shared.profiles![profileIndex].shoppingList {
            if shoppingListItem == item {
                itemIsChecked = true
                break
            } else {
                index += 1
            }
        }
        
        itemNameLabel.text = item.name
        
        updateCheckMark()
    }
    
    //Makes button appear with checkmark if it is added to the shoppingList
    func updateCheckMark() {
        if itemIsChecked {
            checkMarkButton.setImage(checkMarkCircle, for: .normal)
        } else {
            checkMarkButton.setImage(circleImage, for: .normal)
        }
    }
    
    // Adds item when user taps the checkmark
    @IBAction func itemChecked(_ sender: UIButton) {
        //AddToShoppingListTableViewController().itemsToAdd.append(shoppingListItem)
        
        if !itemIsChecked {
            //Some more of my fugly code to run through an array to find an item and do a thing
            //In this case it finds if the item is in the list already, if it is not there it will append
            var index = 0
            for item in ProfileModelController.shared.profiles![profileIndex].shoppingList {
                if shoppingListItem == item {
                    itemIsChecked = true
                                        
                    updateCheckMark()
                    return
                } else {
                    index += 1
                }
            }

            //Code to run through button states
            itemIsChecked = true
            updateCheckMark()
            update(with: shoppingListItem)
            
            AddToShoppingListTableViewController.sharedItemAdder.itemsToAdd.append(shoppingListItem)
            
        } else {
            //Some more of my fugly code to run through an array to find an item and do a thing
            //In this case it finds where the item is in the array
            var index = 0
            for item in AddToShoppingListTableViewController.sharedItemAdder.itemsToAdd {
                if shoppingListItem == item {
                    break
                } else {
                    index += 1
                }
            }
            
            AddToShoppingListTableViewController.sharedItemAdder.itemsToAdd.remove(at: index)
            itemIsChecked = false
            updateCheckMark()
            update(with: shoppingListItem)
        }
    }
}
