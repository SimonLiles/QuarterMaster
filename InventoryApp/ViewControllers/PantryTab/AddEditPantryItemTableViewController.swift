//
//  AddEditPantryItemTableViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 6/30/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

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
    var pantryItem: PantryItem = PantryItem(name: "", category: "", location: "", currentQuantity: 0.0, units: "", note: "")
    
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
        } else {
            quantityStepper.value = 0
            quantityTextField.text = String(quantityStepper.value)
        }
        
        updateSaveButtonState()
        
    }
    
    // MARK: - Functions
    
    ///Disables save button when required data fields are left blank
    func updateSaveButtonState() {
        let nameText = nameTextField.text ?? ""
        let categoryText = categoryLabel.text ?? "Uncategorized"
        let locationText = locationLabel.text ?? "No Location"
        let quantityText = quantityTextField.text ?? ""
        let unitsText = unitsLabel.text ?? "Units"
        //let commentText = commentTextField.text ?? ""
        
        //Only returns true after all fields are filled
        saveButton.isEnabled = !nameText.isEmpty && categoryText != "Uncategorized" && locationText != "No Location" && !quantityText.isEmpty && unitsText != "Units"
        
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
                print("User chose delete action")
                
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
            let category = categoryLabel.text ?? "Uncategorized"
            let location = locationLabel.text ?? "No Location"
            let quantity = quantityStepper.value
            let units = unitsLabel.text ?? "Units"
            let note = commentTextField.text ?? ""
            
            pantryItem = PantryItem(name: name, category: category, location: location, currentQuantity: quantity, units: units, note: note)
        } else if segue.identifier == "pickerSegue" {
            let indexPath = tableView.indexPathForSelectedRow!
            
            let key: String = "pantryEditTableView"
            
            var items: [String] = []
            var currentItem: String = ""
            var typeName: String = ""
            
            //determine which array to open a picker for
            switch indexPath.section {
            case 1: //Category Section
                items = ProfileModelController.shared.getCategories()
                currentItem = pantryItem.category
                typeName = "Category"
            case 2: //Location Section
                //Pull locations out of the Pantry model controller
                items = ProfileModelController.shared.getLocations()
                currentItem = pantryItem.location
                typeName = "Location"
            case 3: //Units section
                items = ProfileModelController.shared.getUnits()
                currentItem = pantryItem.units
                typeName = "Units"
            default:
                print("Your thing is not fully implemented yet")
                print("Check func prepare(segue:) in AddEditPantryItemTableViewController")
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
                print("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
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
                categoryLabel.text = pantryItem.category
                tableView.reloadData()
            case "Location":
                pantryItem.location = pantryPickerAddNewViewController.newItem
                locationLabel.text = pantryItem.location
                tableView.reloadData()
            case "Units":
                pantryItem.units = pantryPickerAddNewViewController.newItem
                unitsLabel.text = pantryItem.units
                tableView.reloadData()
            default:
                print("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
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

