//
//  AddEditPantryItemTableViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 6/30/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class AddEditPantryItemTableViewController: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var addToShoppingListButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Variables and Constants
    var pantryItem: PantryItem = PantryItem(id: 0, name: "", category: "", location: "", currentQuantity: 0.0, units: "", note: "", lastUpdate: Date())
    
    //Object to collect and store logs.
    let log = Logger()
    
    var selectedIndexPath: IndexPath = IndexPath()
    var pantryIndex: Int?
    var selectedSection: String = ""
    
    var itemID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Allows user to tap out of editing
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(tableView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if !pantryItem.name.isEmpty {
            nameTextField.text = pantryItem.name
            categoryLabel.text = pantryItem.category
            locationLabel.text = pantryItem.location
            quantityTextField.text = String(pantryItem.currentQuantity)
            quantityStepper.value = pantryItem.currentQuantity
            unitsLabel.text = pantryItem.units
            commentTextField.text = pantryItem.note
            itemID = pantryItem.id
        } else {
            let profileIndex = userData.selectedIndex
            pantryItem.id = userData.profiles?[profileIndex].createPantryItemID() ?? 0
            itemID = pantryItem.id
            
            //log.info("Creating new ID: \(self.pantryItem.id)")
            
            quantityStepper.value = 0
            quantityTextField.text = String(quantityStepper.value)
        }
        
        self.title = pantryItem.name
        
        updateSaveButtonState()
        
        updateAddToShoppingListButtonState()
        
        log.info("Item name: \(self.pantryItem.name)")
        log.info("Item ID: \(self.pantryItem.id)")
    }
    
    // MARK: - Functions
    
    ///Disables save button when required data fields are left blank
    func updateSaveButtonState() {
        let whiteSpaceCharSet = CharacterSet(charactersIn: " \t\n")
        
        let nameText = nameTextField.text?.trimmingCharacters(in: whiteSpaceCharSet) ?? "Unnamed Item"
        let categoryText = categoryLabel.text ?? ""
        let locationText = locationLabel.text ?? ""
        let quantityText = quantityTextField.text ?? ""
        let unitsText = unitsLabel.text ?? ""
        //let commentText = commentTextField.text ?? ""
        
        //Only returns true after all fields are filled
        saveButton.isEnabled = !nameText.isEmpty && categoryText != "" && locationText != "" && !quantityText.isEmpty && unitsText != ""
        
        self.title = nameText
        
        updateDeleteButtonState()
    }
    
    //Updates delete button state depending on Save Button State
    func updateDeleteButtonState() {
        if !saveButton.isEnabled {
            deleteButton.isHidden = true
        } else {
            deleteButton.isHidden = false
        }
    }
    
    //Update add to shopping list button state
    func updateAddToShoppingListButtonState() {
        if (userData.profiles![userData.selectedIndex].shoppingList.contains(pantryItem)) {
            addToShoppingListButton.setTitle("This item is on your Shopping List", for: .disabled)
            addToShoppingListButton.setTitleColor(.gray, for: .disabled)
            addToShoppingListButton.isEnabled = false
        } else {
            if (saveButton.isEnabled) {
                addToShoppingListButton.setTitle("Add to Shopping List", for: .normal)
                addToShoppingListButton.setTitleColor(.systemBlue, for: .normal)
                addToShoppingListButton.isEnabled = true
            } else {
                addToShoppingListButton.setTitle("  ", for: .disabled)
                addToShoppingListButton.setTitleColor(.systemBlue, for: .disabled)
                addToShoppingListButton.isEnabled = false
            }
            
        }
    }
    
    // MARK: - IBActions
    
    //Keeps quantityTextField and pantryItem current quantity equal to stepper value
    @IBAction func quantityStepped(_ sender: UIStepper) {
        quantityTextField.text = String(quantityStepper.value)
        //pantryItem.currentQuantity = quantityStepper.value
    }
    
    //Can be used to update stepper value so that it remains consistent with text field
    @IBAction func quantityChanged(_ sender: UITextField) {
        let newQuantity = Double(sender.text!)
        
        quantityStepper.value = newQuantity ?? 0
        
        updateSaveButtonState()
    }
    
    //Updates save button whenever text editing in required fields has changed
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    //Confirms with the user they want to delete before they actually delete
    @IBAction func deleteButtonPressed(_ sender: UIButton) {        
        let deleteAlert = UIAlertController(title: "Do you wish to continue?", message: "Are you sure you wish to delete this item? After deleting you will not be able to recover the data.", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.log.info("User chose delete action")
                
            self.performSegue(withIdentifier: "deleteUnwind", sender: nil)
            })
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        deleteAlert.addAction(deleteAction)
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //guard segue.identifier == "saveUnwind" else {return}
        
        //Checks if user is trying to save data
        if segue.identifier == "saveUnwind" {
            let name = nameTextField.text ?? ""
            var category = categoryLabel.text ?? "Uncategorized"
            var location = locationLabel.text ?? "No Location"
            let quantity = quantityStepper.value
            var units = unitsLabel.text ?? "Unitless"
            let note = commentTextField.text ?? ""
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
            
            pantryItem = PantryItem(id: itemID, name: name, category: category, location: location, currentQuantity: quantity, units: units, note: note, lastUpdate: currentDate)
        } else if segue.identifier == "pickerSegue" {
            let indexPath = tableView.indexPathForSelectedRow!
            
            let key: String = "pantryEditTableView"
            
            var items: [String] = []
            var currentItem: String = ""
            var typeName: String = ""
            
            //determine which array to open a picker for
            switch indexPath.section {
            case 1: //Category Section
                items = userData.getCategories()
                currentItem = pantryItem.category
                typeName = "Category"
            case 2: //Location Section
                //Pull locations out of the Pantry model controller
                items = userData.getLocations()
                currentItem = pantryItem.location
                typeName = "Location"
            case 3: //Units section
                items = userData.getUnits()
                currentItem = pantryItem.units
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
        } else if segue.identifier == "addToShoppingListUnwind" {
            let name = nameTextField.text ?? ""
            let category = categoryLabel.text ?? "Uncategorized"
            let location = locationLabel.text ?? "No Location"
            let quantity = quantityStepper.value
            let units = unitsLabel.text ?? "Units"
            let note = commentTextField.text ?? ""
            let currentDate = Date()
            
            pantryItem = PantryItem(id: 0, name: name, category: category, location: location, currentQuantity: quantity, units: units, note: note, lastUpdate: currentDate)
        }
        
    }
    
    //Unwind segue to this point
    @IBAction func unwindToAddEditPantryTableView(segue: UIStoryboardSegue) {
        //Check to make sure it is the correct identifier first
        if segue.identifier == "unwindToAddEditPantryFromPickerList" {
            let pantryPickerListTableViewController = segue.source as! PantryPickerListTableViewController
            //let pantryPickerListTableViewController = navController.topViewController as! PantryPickerListTableViewController
            
            let key = pantryPickerListTableViewController.name
            
            switch key {
            case "Category":
                pantryItem.category = pantryPickerListTableViewController.selectedItem
                categoryLabel.text = pantryItem.category
                tableView.reloadData()
            case "Location":
                pantryItem.location = pantryPickerListTableViewController.selectedItem
                locationLabel.text = pantryItem.location
                tableView.reloadData()
            case "Units":
                pantryItem.units = pantryPickerListTableViewController.selectedItem
                unitsLabel.text = pantryItem.units
                tableView.reloadData()
            default:
                log.fault("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
                return
            }
            
            updateSaveButtonState()
        } else if segue.identifier == "unwindToAddEditPantryFromNewItem" {
            let pantryPickerAddNewViewController = segue.source as! PantryPickerAddNewViewController
            //let pantryPickerListTableViewController = navController.topViewController as! PantryPickerListTableViewController
            
            let key = pantryPickerAddNewViewController.name
            
            switch key {
            case "Category":
                pantryItem.category = pantryPickerAddNewViewController.newItem
                userData.profiles![userData.selectedIndex].categories.append(pantryPickerAddNewViewController.newItem)
                categoryLabel.text = pantryItem.category
                tableView.reloadData()
            case "Location":
                pantryItem.location = pantryPickerAddNewViewController.newItem
                userData.profiles![userData.selectedIndex].locations.append(pantryPickerAddNewViewController.newItem)
                locationLabel.text = pantryItem.location
                tableView.reloadData()
            case "Units":
                pantryItem.units = pantryPickerAddNewViewController.newItem
                userData.profiles![userData.selectedIndex].units.append(pantryPickerAddNewViewController.newItem)
                unitsLabel.text = pantryItem.units
                tableView.reloadData()
            default:
                log.fault("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
                return
            }
            
            //Reload tableViews for shoppingList and pantry tabs
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![userData.selectedIndex].pantry)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![userData.selectedIndex].pantry)
            
            updateSaveButtonState()
        } else if segue.identifier == "cancelUnwindToAddEditPantryFromPickerList" {
            log.info("cancelUnwind from Pantry Picker List")
            let pantryPickerListTableViewController = segue.source as! PantryPickerListTableViewController
            //let pantryPickerListTableViewController = navController.topViewController as! PantryPickerListTableViewController
            
            let key = pantryPickerListTableViewController.name
            
            switch key {
            case "Category":
                pantryItem.category = pantryPickerListTableViewController.selectedItem
                categoryLabel.text = pantryItem.category
                tableView.reloadData()
            case "Location":
                pantryItem.location = pantryPickerListTableViewController.selectedItem
                locationLabel.text = pantryItem.location
                tableView.reloadData()
            case "Units":
                pantryItem.units = pantryPickerListTableViewController.selectedItem
                unitsLabel.text = pantryItem.units
                tableView.reloadData()
            default:
                log.fault("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
                return
            }
            
            updateSaveButtonState()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "deleteUnwind" {
            return false
        } else {
            return true
        }
    }

}

