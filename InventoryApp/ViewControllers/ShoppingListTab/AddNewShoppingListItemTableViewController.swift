//
//  AddNewShoppingListItemTableViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 7/10/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class AddNewShoppingListItemTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    //@IBOutlet weak var categoryTextField: UITextField!
    //@IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var neededQuantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    //@IBOutlet weak var unitsTextField: UITextField!
    @IBOutlet weak var commentTextFIeld: UITextField!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Variables and Constants
    var profileIndex = userData.selectedIndex
    
    var shoppingListItem: PantryItem = PantryItem(name: "", category: "", location: "", currentQuantity: 0, units: "", note: "", lastUpdate: Date())
    
    //Object to collect and store logs.
    let log = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Allows user to tap out of editing
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(tableView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        profileIndex = userData.selectedIndex
        
        shoppingListItem.neededQuantity = 1
        
        quantityStepper.value = shoppingListItem.neededQuantity
        neededQuantityTextField.text = String(quantityStepper.value)
        
        updateSaveButtonState()
    }
    
    // MARK: - Functions
    
    //Disables save button when required data fields are left blank
    func updateSaveButtonState() {
        let nameText = nameTextField.text ?? ""
        let categoryText = categoryLabel.text ?? ""
        let locationText = locationLabel.text ?? ""
        let unitsText = unitsLabel.text ?? ""
        //let commentText = commentTextField.text ?? ""
        
        //Only returns true after all fields are filled
        saveButton.isEnabled = !nameText.isEmpty && !categoryText.isEmpty && !locationText.isEmpty && !unitsText.isEmpty
    }
    
    // MARK: - IBActions
    
    @IBAction func quantityStepped(_ sender: UIStepper) {
        neededQuantityTextField.text = String(quantityStepper.value)
    }
    
    @IBAction func quantityChanged(_ sender: UITextField) {
        let newQuantity = Double(sender.text!)
        
        quantityStepper.value = newQuantity ?? 0

        updateSaveButtonState()
    }
    
    //Updates save button whenever text editing in required fields has changed
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "saveUnwind" {
            
            let name = nameTextField.text ?? ""
            var category = categoryLabel.text ?? "Uncategorized"
            var location = locationLabel.text ?? "No Location"
            let quantity = quantityStepper.value
            var units = unitsLabel.text ?? "Unitless"
            let note = commentTextFIeld.text ?? ""
            let currentDate = Date()
            
            if(categoryLabel.text == "Category") {
                category = "Uncategorized"
                
                if (!(userData.profiles![userData.selectedIndex].categories.contains("Uncategorized"))) {
                    userData.profiles![userData.selectedIndex].categories.append("Uncategorized")
                }
            }
            
            if(locationLabel.text == "Location") {
                location = "No Location"
                
                if (!(userData.profiles![userData.selectedIndex].locations.contains("No Location"))) {
                    userData.profiles![userData.selectedIndex].locations.append("No Location")
                }
            }
            
            if(unitsLabel.text == "Units") {
                units = "Unitless"
                
                if (!(userData.profiles![userData.selectedIndex].units.contains("Unitless"))) {
                    userData.profiles![userData.selectedIndex].units.append("Unitless")
                }
            }
            
            shoppingListItem = PantryItem(name: name, category: category, location: location, currentQuantity: 0, units: units, note: note, lastUpdate: currentDate)
            shoppingListItem.neededQuantity = quantity
        } else if segue.identifier == "pickerSegue" {
            let indexPath = tableView.indexPathForSelectedRow!
            
            let key: String = "addNewShoppingListItemTableView"
            
            var items: [String] = []
            var currentItem: String = ""
            var typeName: String = ""
            
            //determine which array to open a picker for
            switch indexPath.section {
            case 1: //Category Section
                items = userData.getCategories()
                currentItem = shoppingListItem.category
                typeName = "Category"
            case 2: //Location Section
                //Pull locations out of the Pantry model controller
                items = userData.getLocations()
                currentItem = shoppingListItem.location
                typeName = "Location"
            case 3: //Units section
                items = userData.getUnits()
                currentItem = shoppingListItem.units
                typeName = "Units"
            default:
                log.fault("Your thing is not fully implemented yet")
                log.fault("Check func prepare(segue:) in AddEditPantryItemTableViewController")
                return
            }
            
            //let navController = segue.destination as! UINavigationController
            let pantryPickerListTableViewController = segue.destination as! PantryPickerListTableViewController
            
            //Pass the data to the picker
            pantryPickerListTableViewController.returnKey = key
            pantryPickerListTableViewController.itemNames = items
            pantryPickerListTableViewController.selectedItem = currentItem
            pantryPickerListTableViewController.name = typeName
        }
    }
    
    //Unwind segue to this point
    @IBAction func unwindToAddNewShoppingListItemTableView(segue: UIStoryboardSegue) {
        //Check to make sure identifier is correct first
        if segue.identifier == "uniwndToAddNewShoppingListItemFromPickerList" {
            let pantryPickerListTableViewController = segue.source as! PantryPickerListTableViewController
            //let pantryPickerListTableViewController = navController.topViewController as! PantryPickerListTableViewController
            
            let key = pantryPickerListTableViewController.name
            
            switch key {
            case "Category":
                shoppingListItem.category = pantryPickerListTableViewController.selectedItem
                categoryLabel.text = shoppingListItem.category
                tableView.reloadData()
            case "Location":
                shoppingListItem.location = pantryPickerListTableViewController.selectedItem
                locationLabel.text = shoppingListItem.location
                tableView.reloadData()
            case "Units":
                shoppingListItem.units = pantryPickerListTableViewController.selectedItem
                unitsLabel.text = shoppingListItem.units
                tableView.reloadData()
            default:
                log.fault("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
                return
            }
            
            updateSaveButtonState()
        } else if segue.identifier == "uniwndToAddNewShoppingListItemFromNewItem" {
            let pantryPickerAddNewViewController = segue.source as! PantryPickerAddNewViewController
            //let pantryPickerListTableViewController = navController.topViewController as! PantryPickerListTableViewController
                
            let key = pantryPickerAddNewViewController.name
            
            switch key {
            case "Category":
                shoppingListItem.category = pantryPickerAddNewViewController.newItem
                categoryLabel.text = shoppingListItem.category
                tableView.reloadData()
            case "Location":
                shoppingListItem.location = pantryPickerAddNewViewController.newItem
                locationLabel.text = shoppingListItem.location
                tableView.reloadData()
            case "Units":
                shoppingListItem.units = pantryPickerAddNewViewController.newItem
                unitsLabel.text = shoppingListItem.units
                tableView.reloadData()
            default:
                log.fault("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
                return
            }
            
            updateSaveButtonState()
        }
    }
}
