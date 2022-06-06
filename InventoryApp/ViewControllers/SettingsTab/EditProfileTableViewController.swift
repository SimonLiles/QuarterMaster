//
//  EditProfileTableViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/19/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class EditProfileTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    //Bar Buttons
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //Name text field
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //delete button
    @IBOutlet weak var deleteButton: UIButton!
    
    //sendDataButton
    @IBOutlet weak var sendDataButton: UIButton!
    
    // MARK: - Variables and Constants
    var profileIndex = userData.selectedIndex
    
    var profile = Profile(name: "", pantry: [], shoppingList: [], categories: [], locations: [], units: [])
        
    //Object to collect and store logs.
    let log = Logger()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Allows user to tap out of editing
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(tableView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //Draw a border for the description box for a pro
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.opaqueSeparator.cgColor
        
        profileIndex = userData.selectedIndex
        profile = userData.profiles![profileIndex]
        
        if !profile.name.isEmpty {
            profileNameTextField.text = profile.name
            descriptionTextView.text = profile.description
        }
        
        updateSaveButtonState()
        
        //Initializes Notification observer to listen for updates from other view controllers
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "reloadShoppingList"), object: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        //Send data to any connected peers
        userData.profiles![profileIndex].versionTimeStamp = Date()
        userData.saveProfileData()
        log.info("ProfileModelController saved user data before sending data to conected peers")
        userData.sendProfile()
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadTable(notification: NSNotification) {
        profile = userData.profiles![profileIndex]
        
        tableView.reloadData()
    }
    
    // MARK: - Functions
    
    ///Disables save button when required data fields are left blank
    func updateSaveButtonState() {
        let nameText = profileNameTextField.text ?? ""
        
        saveButton.isEnabled = !nameText.isEmpty
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
    @IBAction func textFieldsEdited(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let saveAlert = UIAlertController(title: "Do you wish to save changes?", message: "Are you sure you wish to make these changes? Once the changes are saved, it is impossible to go back.", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { action in
            self.log.info("User chose to save profile data")
            
            //Push changes to model controller
            self.profile.name = self.profileNameTextField.text ?? "Unnamed"
            self.profile.description = self.descriptionTextView.text ?? ""
            
            userData.profiles![self.profileIndex] = self.profile
            
            //Save model controller data
            userData.saveProfileData()
            self.log.info("ProfileModelController saved user data after saving edited profile data")
            
            //Reload the data
            self.tableView.reloadData()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfiles"), object: userData.profiles!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfileNavBar"), object: userData.profiles!)

        })
        
        saveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        saveAlert.addAction(saveAction)
        
        present(saveAlert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        let cancelAlert = UIAlertController(title: "Do you wish to discard changes?", message: "Are you sure you wish to discard changes? Changes will be discarded and the original data will be displayed.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Discard", style: .default, handler: { action in
            self.log.info("User chose to discard changes to profile data")
            self.profileNameTextField.text? = self.profile.name
            self.descriptionTextView.text? = self.profile.description
            
            self.tableView.reloadData()
        })
        
        cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        cancelAlert.addAction(cancelAction)
        
        present(cancelAlert, animated: true, completion: nil)

    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        log.info("sendButton Pressed")
        //Send data to any connected peers
        userData.profiles![profileIndex].versionTimeStamp = Date()
        userData.saveProfileData()
        log.info("ProfileModelController saved user data before sending data to conected peers")
        userData.sendProfile()
        
        let sendAlertTitle = "Sending Data to Connected Peers"
        let sendAlertMessage = "Sending Profile: \(profile.name) data to all connected peers"
        let sendAlert = UIAlertController(title: sendAlertTitle, message: sendAlertMessage, preferredStyle: .alert)
        sendAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(sendAlert, animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Do you wish to continue?", message: "Are you sure you wish to delete this profile? After deleting you will not be able to recover the data.", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.log.info("User chose delete action")
                
            self.performSegue(withIdentifier: "deleteProfileUnwind", sender: nil)
        })
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        deleteAlert.addAction(deleteAction)
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)

        if(segue.identifier == "pickerSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            
            let key: String = "profileSettingsView"
            
            var items: [String] = []
            let currentItem: String = ""
            var typeName: String = ""
            
            //determine which array to open a picker for
            switch indexPath?.row ?? 0 {
            case 0: //Category Row
                items = userData.getCategories()
                //currentItem = pantryItem.category
                typeName = "Category"
            case 1: //Location Row
                //Pull locations out of the Pantry model controller
                items = userData.getLocations()
                //currentItem = pantryItem.location
                typeName = "Location"
            case 2: //Units Row
                items = userData.getUnits()
                //currentItem = pantryItem.units
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
    @IBAction func unwindToEditProfileTableView(segue: UIStoryboardSegue) {
        //Check to make sure it is the correct identifier first
        if segue.identifier == "unwindToEditProfileTableViewFromPickerList" {
            let pantryPickerListTableViewController = segue.source as! PantryPickerListTableViewController
            //let pantryPickerListTableViewController = navController.topViewController as! PantryPickerListTableViewController
            
            let key = pantryPickerListTableViewController.name
            
            switch key {
            case "Category":
                //pantryItem.category = pantryPickerListTableViewController.selectedItem
                //categoryLabel.text = pantryItem.category
                tableView.reloadData()
            case "Location":
                //pantryItem.location = pantryPickerListTableViewController.selectedItem
                //locationLabel.text = pantryItem.location
                tableView.reloadData()
            case "Units":
                //pantryItem.units = pantryPickerListTableViewController.selectedItem
                //unitsLabel.text = pantryItem.units
                tableView.reloadData()
            default:
                log.fault("Hmm, switch statements in unwindToAddEditPantryTableView are not working properly")
                return
            }
            
            updateSaveButtonState()
        }
    }
}
