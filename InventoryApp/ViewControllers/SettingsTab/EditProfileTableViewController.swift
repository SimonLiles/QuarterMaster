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
    var profileIndex = ProfileModelController.shared.selectedIndex
    
    var profile = Profile(name: "", pantry: [], shoppingList: [])
        
    //Object to collect and store logs.
    let log = Logger()
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Allows user to tap out of editing
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        //Draw a border for the description box for a pro
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.opaqueSeparator.cgColor
        
        profileIndex = ProfileModelController.shared.selectedIndex
        profile = ProfileModelController.shared.profiles![profileIndex]
        
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
        ProfileModelController.shared.profiles![profileIndex].versionTimeStamp = Date()
        ProfileModelController.shared.saveProfileData()
        log.info("ProfileModelController saved user data before sending data to conected peers")
        ProfileModelController.shared.sendProfile()
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadTable(notification: NSNotification) {
        profile = ProfileModelController.shared.profiles![profileIndex]
        
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
            
            ProfileModelController.shared.profiles![self.profileIndex] = self.profile
            
            //Save model controller data
            ProfileModelController.shared.saveProfileData()
            self.log.info("ProfileModelController saved user data after saving edited profile data")
            
            //Reload the data
            self.tableView.reloadData()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfiles"), object: ProfileModelController.shared.profiles!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfileNavBar"), object: ProfileModelController.shared.profiles!)

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
        ProfileModelController.shared.profiles![profileIndex].versionTimeStamp = Date()
        ProfileModelController.shared.saveProfileData()
        log.info("ProfileModelController saved user data before sending data to conected peers")
        ProfileModelController.shared.sendProfile()    }
    
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
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
