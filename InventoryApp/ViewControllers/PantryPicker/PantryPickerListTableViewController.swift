//
//  PantryPickerListTableViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 7/28/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

/**
 Pick List specifically designed for use with the Pantry Inventory Management Software
 */
class PantryPickerListTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // MARK: - Variables and Constants
    
    let profileIndex: Int = userData.selectedIndex
    
    var returnKey: String = ""
    
    //List of strings, can be locations, categories, units, or whatever
    var itemNames: [String] = []
    
    //Creates an empty string for edit menu to pass data into and allow data to be modified before being passed back to edit menu
    var selectedItem: String = ""
    
    //Name of array being fed in. Used to create title for nav bar
    var name: String = ""
    
    //Object to collect and store logs.
    let log = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = name //Sets title of view based on text passed from parent
        
        //Make sure data is sorted before loading
        itemNames = itemNames.sorted()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        updateSaveButtonState()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Picker Functionality
    
    //Tracks which row is selected and then does a thing
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // When user selects an item, put a checkmark next to it and return to edit menu
            selectedItem = itemNames[indexPath.row]
            tableView.reloadData()
            updateSaveButtonState()
            
            //Return to previous view when an item is selected
            switch returnKey {
            case "pantryEditTableView":
                //print("perform segue back to pantry edit menu")
                performSegue(withIdentifier: "unwindToAddEditPantryFromPickerList", sender: nil)
            case "addNewShoppingListItemTableView":
                performSegue(withIdentifier: "uniwndToAddNewShoppingListItemFromPickerList", sender: nil)
            default:
                log.fault("Hmm, whatever you were tryna' do obviously is not fully implemented yet")
                log.fault("Check func saveButtonPressed in PantryPickerListTableViewController")
            }
        case 1:
            performSegue(withIdentifier: "addNewItemSegue", sender: nil)
        default:
            break
        }
    }
    
    //Turns editing mode on and off
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
    }
    
    //Tracks which rows are deleted
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {
            
            //Identify the element to be deleted
            let itemToDelete: String = itemNames[indexPath.row]
            
            //Remove deleted rows from the table
            self.itemNames.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            //Delete the selected items from the user data
            switch name {
            case "Category":
                //Remove category from userData
                let indexToDelete = userData.profiles![profileIndex].categories.firstIndex(of: itemToDelete)!
                userData.profiles![profileIndex].categories.remove(at: indexToDelete)
                
                if(!userData.profiles![profileIndex].categories.contains("Uncategorized")) {
                    userData.profiles![profileIndex].categories.append("Uncategorized")
                }
                
                //Remove category from inventory
                var index: Int = 0
                for item in userData.profiles![profileIndex].pantry {
                    if(item.category == itemToDelete) {
                        userData.profiles![profileIndex].pantry[index].category = "Uncategorized"
                    }
                    
                    index += 1
                }
                
                //Remove category from shopping list
                index = 0
                for item in userData.profiles![profileIndex].shoppingList {
                    if(item.category == itemToDelete) {
                        userData.profiles![profileIndex].shoppingList[index].category = "Uncategorized"
                    }
                    
                    index += 1
                }
            case "Location":
                //Remove category from userData
                let indexToDelete = userData.profiles![profileIndex].locations.firstIndex(of: itemToDelete)!
                userData.profiles![profileIndex].locations.remove(at: indexToDelete)
                
                if(!userData.profiles![profileIndex].locations.contains("No Location")) {
                    userData.profiles![profileIndex].locations.append("No Location")
                }
                
                //Remove category from inventory
                var index: Int = 0
                for item in userData.profiles![profileIndex].pantry {
                    if(item.location == itemToDelete) {
                        userData.profiles![profileIndex].pantry[index].location = "No Location"
                    }
                    
                    index += 1
                }
                
                //Remove category from shopping list
                index = 0
                for item in userData.profiles![profileIndex].shoppingList {
                    if(item.location == itemToDelete) {
                        userData.profiles![profileIndex].shoppingList[index].location = "No Location"
                    }
                    
                    index += 1
                }
            case "Units":
                //Remove category from userData
                let indexToDelete = userData.profiles![profileIndex].units.firstIndex(of: itemToDelete)!
                userData.profiles![profileIndex].categories.remove(at: indexToDelete)
                
                if(!userData.profiles![profileIndex].units.contains("Unitless")) {
                    userData.profiles![profileIndex].units.append("Unitless")
                }
                
                //Remove category from inventory
                var index: Int = 0
                for item in userData.profiles![profileIndex].pantry {
                    if(item.units == itemToDelete) {
                        userData.profiles![profileIndex].pantry[index].units = "Unitless"
                    }
                    
                    index += 1
                }
                
                //Remove category from shopping list
                index = 0
                for item in userData.profiles![profileIndex].shoppingList {
                    if(item.units == itemToDelete) {
                        userData.profiles![profileIndex].shoppingList[index].units = "Unitless"
                    }
                    
                    index += 1
                }
            default:
                log.error("List of items: \"\(self.name)\" is not supported for row deletion")
            }
            
            //Reload tableViews for shoppingList and pantry tabs
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![userData.selectedIndex].pantry)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![userData.selectedIndex].pantry)
        }
    }
    
    // MARK: - IBActions
    
    
    
    // MARK: - Save Button functionality
    //Updates save button state based on current value
    func updateSaveButtonState() {
        //saveButton.isEnabled = selectedItem != ""
    }
    
    
    //Responds when save button is pressed
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        log.info("Edit button was pressed")

        
    }
    
    
    //Responds when back button is pressed
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        switch returnKey {
        case "pantryEditTableView":
            performSegue(withIdentifier: "cancelUnwindToAddEditPantryFromPickerList", sender: nil)
        case "addNewShoppingListItemTableView":
            performSegue(withIdentifier: "cancelUniwndToAddNewShoppingListItemFromPickerList", sender: nil)
        case "profileSettingsView":
            performSegue(withIdentifier: "cancelUnwindToEditProfileSettingsFromPickerList", sender: nil)
        default:
            log.fault("Hmm, whatever you were tryna' do obviously is not fully implemented yet")
            log.fault("Check func cancelButtonPressed in PantryPickerListTableViewController")
        }
    }
    
    // MARK: - Table view data source
    //Sets number of sections, should always be onlly 2 sections, 1 for user data, 1 for "add new" button
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //Sets number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: //Dynamic rows based on user data
            return itemNames.count
        case 1: // Section that holds a single cell for an "add new" button
            return 1
        default:
            log.fault("You gone and done screwed up")
            log.fault("You should try and fix your code buddy")
            return 0
        }
    }
    
    //Causes section breaks to appear
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return " "
        default:
            return "Got more sections than you bargained for, eh?"
        }
    }
    
    //Creates and draws cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionIndex = indexPath.section
        
        switch sectionIndex {
        case 0: //Dynamic cells based on user data
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath)
            
            cell.textLabel?.text = itemNames[indexPath.row]
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .label
            
            if itemNames[indexPath.row] == selectedItem {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        case 1: // Section that holds a single cell for an "add new" button
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath)
            
            let createNewItemButton = UIButton()
            createNewItemButton.titleLabel?.text = "Create New"
            
            //Creates what looks like a button and makes it centered
            cell.textLabel?.text = "Add New"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryType = .none
            
            return cell
        default: //error handling code
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath)

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return true
        case 1:
            return false
        default:
            return false
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("*Captain's voice*: Prepare for segue!!!")
        
        //In case I decide to pass data to the next view controller
        if segue.identifier == "addNewItemSegue" {
            let pantryPickerAddNewViewController = segue.destination as! PantryPickerAddNewViewController
            
            pantryPickerAddNewViewController.returnKey = returnKey
            pantryPickerAddNewViewController.name = name
        }
    }
    
    
    //turns off segue to add new item until it is needed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //switch statement makes this easier to expand and read
        switch identifier {
        case "addNewItemSegue":
            return false
        default:
            return true
        }
    }
    
    //Unwind segue to this point
    @IBAction func unwindToPickListTableView(segue: UIStoryboardSegue) {
        //Check to make sure it is the correct identifier first
        if segue.identifier == "unwindToEditPickListFromNewItem" {
            let pantryPickerAddNewViewController = segue.source as! PantryPickerAddNewViewController
            //let pantryPickerListTableViewController = navController.topViewController as! PantryPickerListTableViewController
            
            let key = pantryPickerAddNewViewController.name
            
            //Append new item to appropriate array
            switch key {
            case "Category":
                userData.profiles![userData.selectedIndex].categories.append(pantryPickerAddNewViewController.newItem)
                
                itemNames = userData.profiles![userData.selectedIndex].categories.sorted()

                tableView.reloadData()
            case "Location":
                userData.profiles![userData.selectedIndex].locations.append(pantryPickerAddNewViewController.newItem)
                
                itemNames = userData.profiles![userData.selectedIndex].locations.sorted()
                
                tableView.reloadData()
            case "Units":
                userData.profiles![userData.selectedIndex].units.append(pantryPickerAddNewViewController.newItem)
                
                itemNames = userData.profiles![userData.selectedIndex].units.sorted()
                
                tableView.reloadData()
            default:
                log.fault("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
                return
            }
            
            //Reload tableViews for shoppingList and pantry tabs
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![userData.selectedIndex].pantry)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![userData.selectedIndex].pantry)
            
            updateSaveButtonState()
        }
    }
}
