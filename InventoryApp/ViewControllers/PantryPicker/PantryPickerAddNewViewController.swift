//
//  PantryPickerAddNewViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/10/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class PantryPickerAddNewViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addNewTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Constants & Variables
    var newItem: String = "" //Name of the new item
    
    var returnKey: String = "" //identifying key to allow return to edit menu
    
    var name: String = "" //Name of the array the item will be fed back into
    
    //Object to collect and store logs.
    let log = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Allows user to tap out of editing
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        updateSaveButtonState()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Functions
    
    //Turns save button off when text field is empty
    func updateSaveButtonState() {
        let whiteSpaceCharSet = CharacterSet(charactersIn: " \t\n")
        
        let trimmedNameText = addNewTextField.text!.trimmingCharacters(in: whiteSpaceCharSet)
        
        saveButton.isEnabled = !trimmedNameText.isEmpty
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        //print("save button pressed successfully in add new item")
                
        switch returnKey {
        case "pantryEditTableView":
            //print("perform segue back to pantry edit menu")
            performSegue(withIdentifier: "unwindToAddEditPantryFromNewItem", sender: nil)
        case "addNewShoppingListItemTableView":
            performSegue(withIdentifier: "uniwndToAddNewShoppingListItemFromNewItem", sender: nil)
        case "profileSettingsView":
            log.info("save button pressed from new item view, attempting to uniwnd back")
            performSegue(withIdentifier: "unwindToEditPickListFromNewItem", sender: nil)
        default:
            log.fault("Hmm, whatever you were tryna' do obviously is not fully implemented yet")
            log.fault("Check func saveButtonPressed in PantryPickerAddNewViewController")
        }
    }
    
    //Updates Save button state when text field is edited
    @IBAction func newItemTextFieldEdited(_ sender: UITextField) {
        newItem = sender.text!
        
        updateSaveButtonState()
    }
    
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
