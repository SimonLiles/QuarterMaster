//
//  NewProfileTableViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 8/19/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class NewProfileTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    //Bar Buttons
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //Name text field
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Variables and Constants
    var profile = Profile(name: "", pantry: [], shoppingList: [])
    
    //Object to collect and store logs.
    let log = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Allows user to tap out of editing
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        //Draw a border for the description box for a pro
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.opaqueSeparator.cgColor
        
        updateSaveButtonState()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Functions
    
    ///Disables save button when required data fields are left blank
    func updateSaveButtonState() {
        var nameText = profileNameTextField.text ?? ""
        nameText = nameText.trimmingCharacters(in: CharacterSet(charactersIn: "\0 "))
        
        let testProfile = Profile(name: nameText, pantry: [], shoppingList: [])
        
        //Check if new profile is unique
        if(ProfileModelController.shared.profiles!.contains(testProfile)) {
            saveButton.isEnabled = false
            
            return
        } else {
            //Check that profile is not empty
            saveButton.isEnabled = nameText != ""
            
            return
        }
    }
    
    // MARK: - IBActions
    @IBAction func textFieldsEdited(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        log.info("User created a new profile")
        
        //Push changes to model controller
        profile.name = profileNameTextField.text ?? "Unnamed Vessel"
        profile.description = descriptionTextView.text ?? ""
        
        ProfileModelController.shared.profiles!.append(profile)
                            
        //Save model controller data
        ProfileModelController.shared.saveProfileData()
        log.info("Profile Model Controller saved data after saving new profile")
                            
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfiles"), object: nil)
        
        performSegue(withIdentifier: "saveNewProfileUnwind", sender: nil)
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
