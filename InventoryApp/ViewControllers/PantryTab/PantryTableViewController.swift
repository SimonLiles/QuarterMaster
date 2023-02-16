//
//  PantryTableViewController.swift
//  InventoryApp
//
//  Manages the Pantry Table View
//  Feautures include, Search bar, dynamic categories, dynamic cells
//
//  This view is where user manages the pantry
//
//  Created by Simon Liles on 6/22/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import Foundation

import UIKit

import os

import StoreKit

class PantryTableViewController: UITableViewController {
    
    /// MARK: - IBOutlets
    //@IBOutlet weak var pantrySearchBar: UISearchBar!
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    // MARK: - Constants and Variables
    static var sharedPantryController = PantryTableViewController()
    
    var profileIndex = userData.selectedIndex //Array index for use when modifying a specific profile
    
    var pantry: [PantryItem] = []
    
    var collateKey: String = userData.profiles![userData.selectedIndex].pantryCollateKey
    
    //Collates pantry with Category keys
    var itemsCollatedByCategory: [String: [PantryItem]] {
        Dictionary(grouping: itemsSortedByCategory, by: { $0.category })
    }
    
    //Sorts pantry by category
    var itemsSortedByCategory: [PantryItem] {
        return pantry.sorted { $0.category.lowercased() < $1.category.lowercased() }
    }
    
    //List of all possible categories
    var categories: [String] {
        //itemsCollatedByCategory.map({$0.key}).sorted()
        return userData.profiles![profileIndex].categories.sorted()
    }
    
    //Collates pantry with Location Keys
    var itemsCollatedByLocation: [String: [PantryItem]] {
        Dictionary(grouping: itemsSortedByLocation, by: { $0.location })
    }
    
    //Sorts pantry by location
    var itemsSortedByLocation: [PantryItem] {
        return pantry.sorted { $0.location.lowercased() < $1.location.lowercased() }
    }
    
    //List of all possible Locations
    var locations: [String] {
        itemsCollatedByLocation.map({$0.key}).sorted()
    }
    
    //Collates pantry with Units keys
    var itemsCollatedByUnit: [String: [PantryItem]] {
        Dictionary(grouping: itemsSortedByUnit, by: { $0.units })
    }
    
    //Sorts pantry by unit
    var itemsSortedByUnit: [PantryItem] {
        return pantry.sorted { $0.units.lowercased() < $1.units.lowercased() }
    }
    
    //List of all possible units
    var units: [String] {
        //itemsCollatedByCategory.map({$0.key}).sorted()
        return userData.profiles![profileIndex].units.sorted()
    }

    
    //Search bar constants and variables
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPantry: [PantryItem] = [] //Holds pantryItems that are being searched for
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
        
    //Object to collect and store logs.
    let log = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initializes Notification observer to listen for updates from other view controllers
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "reloadPantry"), object: nil)
        
        //Initializes profile data on start up
        profileIndex = userData.selectedIndex
        pantry = userData.profiles![profileIndex].pantry
        pantry = itemsSortedByCategory
        
        //Initialization of Search Bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pantry"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //Allows user to tap out of editing
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(tableView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //Send data to any connected peers
        userData.profiles![profileIndex].versionTimeStamp = Date()
        userData.saveProfileData()
        log.info("ProfileModelController saved user data before sending data to conected peers")
        userData.sendProfile()
    }
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        self.tableView.reloadData()
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadTable(notification: NSNotification) {
        log.info("Pantry tableView is reloading")
        pantry = userData.profiles![profileIndex].pantry
        
        tableView.reloadData()
    }
 
    // MARK: - Search Bar Functionality
    
    //Function to filter for search results
    func filterContentForSearchText(_ searchText: String) {
        
        filteredPantry = pantry.filter { (pantryItem: PantryItem) -> Bool in
        
            return pantryItem.name.lowercased().contains(searchText.lowercased())
        }
      
      tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //activates when search bar is used
        if isFiltering {
            return 1
        }
        
        switch collateKey {
        case "Category":
            return categories.count
        case "Location":
            return locations.count
        case "Units":
            log.error("Unsupported collate given in Pantry TableView in numberOfSections()")
            log.error("collateKey = \(self.collateKey)")
            return units.count
        default:
            return 1
        }
        
        //return categories.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        //limits number of cells when user is searching
        if isFiltering {
            return filteredPantry.count
        }
        
        switch collateKey {
        case "Category":
            return itemsCollatedByCategory[categories[section]]?.count ?? 0
        case "Location":
            return itemsCollatedByLocation[locations[section]]?.count ?? 0
        case "Units":
            return itemsCollatedByUnit[units[section]]?.count ?? 0
        default:
            return 1
        }
        
        //Implementation of dynamic categories
        //return itemsCollatedByCategory[categories[section]]?.count ?? 0
    }
    
    //Sets section header titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //activates when search bar is used
        if isFiltering {
            if (filteredPantry.count <= 0) {
                return "No Results found"
            } else {
                return "Searching Pantry"
            }
        }
        
        switch collateKey {
        case "Category":
            return categories[section]
        case "Location":
            return locations[section]
        case "Units":
            return units[section]
        default:
            return "ERROR: collateKey \"\(collateKey)\" is unsupported"
        }
        
        //return categories[section]
    }
    
    //Configures each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pantryItemCell", for: indexPath) as! PantryTableViewCell
                
        pantry = userData.profiles![profileIndex].pantry
        
        //Fetch model object to display in cell
        let pantryItem: PantryItem
        
        if isFiltering {
            pantryItem = filteredPantry[indexPath.row]
        } else {
            //pantryItem = pantry[indexPath.row]
            
            switch collateKey {
            case "Category":
                pantryItem = itemsCollatedByCategory[categories[indexPath.section]]![indexPath.row]
            case "Location":
                pantryItem = itemsCollatedByLocation[locations[indexPath.section]]![indexPath.row]
            case "Units":
                pantryItem = itemsCollatedByUnit[units[indexPath.section]]![indexPath.row]
            default:
                log.error("ERROR: PantryTableView -> Unknown collateKey")
                log.error("collateKey = \(self.collateKey)")
                pantryItem = PantryItem(id: 0, name: "", category: "", location: "", currentQuantity: 0.0, units: "", note: "", lastUpdate: Date())
            }

        }
        
        // Configure the cell...
        
        cell.update(with: pantryItem, at: indexPath, with: collateKey)

        return cell
    }
    
    // MARK: - IBActions
    //Activates menu for when sort button is pressed
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        log.info("Sort Button Pressed")
        
        let sortTitle = "Sort the Invenotry"
        let sortMessage = "Choose how you would like inventory items to be sorted."
        
        let sortAlert = UIAlertController(title: sortTitle, message: sortMessage, preferredStyle: .actionSheet)
        
        let categoryAction = UIAlertAction(title: "Group By Category", style: .default, handler: {_ in
            self.collateKey = "Category"
            userData.profiles![self.profileIndex].pantryCollateKey = "Category"
            self.tableView.reloadData()
        })
        let locationAction = UIAlertAction(title: "Group By Location", style: .default, handler: {_ in
            self.collateKey = "Location"
            userData.profiles![self.profileIndex].pantryCollateKey = "Location"
            self.tableView.reloadData()
        })
        let unitsAction = UIAlertAction(title: "Group By Unit", style: .default, handler: {_ in
            self.collateKey = "Units"
            userData.profiles![self.profileIndex].pantryCollateKey = "Units"
            self.tableView.reloadData()
        })
        
        sortAlert.addAction(categoryAction)
        sortAlert.addAction(locationAction)
        sortAlert.addAction(unitsAction)
        sortAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = sortAlert.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        present(sortAlert, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the AddEditPantryItemTableViewController segue
        if segue.identifier == "EditPantryItem" {
            let indexPath = tableView.indexPathForSelectedRow!
            
            //Get pantry item
            var pantryItem: PantryItem
            if isFiltering {
                pantryItem = filteredPantry[indexPath.row]
            } else {
                //pantryItem = pantry[indexPath.row]
                
                switch collateKey {
                case "Category":
                    pantryItem = itemsCollatedByCategory[categories[indexPath.section]]![indexPath.row]
                case "Location":
                    pantryItem = itemsCollatedByLocation[locations[indexPath.section]]![indexPath.row]
                case "Units":
                    pantryItem = itemsCollatedByUnit[units[indexPath.section]]![indexPath.row]
                default:
                    log.error("ERROR: Unsupported collateKey in PantryTableView")
                    log.error("collateKey = \(self.collateKey)")
                    pantryItem = PantryItem(id: 0, name: "", category: "", location: "", currentQuantity: 0.0, units: "", note: "", lastUpdate: Date())
                }
            }
            
            //Pull pantryItem from model controller
            let pantryItemIndex = userData.profiles![profileIndex].pantry.firstIndex(of: pantryItem)
            pantryItem = userData.profiles![profileIndex].pantry[pantryItemIndex!]
            
            let navController = segue.destination as! UINavigationController
            let addEditPantryItemTableViewController = navController.topViewController as! AddEditPantryItemTableViewController
            
            // Pass pantryItem object to AddEditPantryItemTableViewController
            addEditPantryItemTableViewController.pantryItem = pantryItem
            addEditPantryItemTableViewController.selectedIndexPath = indexPath
            addEditPantryItemTableViewController.pantryIndex = pantryItemIndex
            
            switch collateKey {
            case "Category":
                addEditPantryItemTableViewController.selectedSection = categories[indexPath.section]
            case "Location":
                addEditPantryItemTableViewController.selectedSection = locations[indexPath.section]
            case "Units":
                addEditPantryItemTableViewController.selectedSection = units[indexPath.section]
            default:
                log.error("ERROR: Unsupported collateKey.")
                log.error("collateKey = \(self.collateKey)")
                addEditPantryItemTableViewController.selectedSection = "unsupported collateKey"
            }
        }
    }
    
    //For unwinding from add edit mode, saves data and updates the table
    @IBAction func unwindToPantryTableView(segue: UIStoryboardSegue) {
        //guard segue.identifier == "saveUnwind" else {return}
        
        //MARK: - "saveUnwind" Segue
        if segue.identifier == "saveUnwind" {
            let sourceViewController = segue.source as! AddEditPantryItemTableViewController
            
            let selectedIndexPath = sourceViewController.selectedIndexPath
            let pantryIndex = sourceViewController.pantryIndex
            let selectedSection = sourceViewController.selectedSection
            
            let pantryItem = sourceViewController.pantryItem
            
            //If an existing item has changes saved
            if(!selectedIndexPath.isEmpty) {
                
                //Ugly code to change a specific item in Pantry
                var pantryItemToChange = PantryItem(id: 0, name: "", category: "", location: "", currentQuantity: 0.0, units: "", note: "", lastUpdate: Date())
                switch collateKey{
                case "Category":
                    pantryItemToChange = itemsCollatedByCategory[selectedSection]?[selectedIndexPath.row] ?? pantryItemToChange
                case "Location":
                    pantryItemToChange = itemsCollatedByLocation[selectedSection]?[selectedIndexPath.row] ?? pantryItemToChange
                case "Units":
                    pantryItemToChange = itemsCollatedByUnit[selectedSection]?[selectedIndexPath.row] ?? pantryItemToChange
                default:
                    log.error("ERROR: Unsupported collateKey")
                    log.error("collateKey = \(self.collateKey)")
                }
                
                pantry[pantryIndex!] = pantryItem //update item with new data
                pantry[pantryIndex!].lastUpdate = Date()
                
                //Ugly code to change a specific item in Shopping List
                var shoppingListIndex = 0
                for anotherItem in userData.profiles![profileIndex].shoppingList {
                    if pantryItemToChange == anotherItem {
                        userData.profiles![profileIndex].shoppingList[shoppingListIndex] = pantryItem
                        userData.profiles![profileIndex].shoppingList[shoppingListIndex].lastUpdate = Date()
                        break
                    } else {
                        shoppingListIndex += 1
                    }
                    
                    //Track change in pantry of item being modified to shopping list
                    userData.profiles![profileIndex].shoppingListChangeLog.append(PantryChangeKey(time: Date(), changeType: .modify, newObject: pantryItem, oldObject: pantryItemToChange))

                }
                
                //Pass pantry data back to ProfileModelController and save all data
                userData.profiles![profileIndex].pantry = pantry
                userData.saveProfileData()
                
                userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .modify, newObject: pantryItem, oldObject: pantryItemToChange))
                
                
                log.info("ProfileModelController saved user data after unwinding to PantryTableView")
                
                //Tell ShoppingList Tab to reload data with new shoppingList data
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)
                
                userData.saveProfileData() //Save data again just in case
                log.info("ProfileModelController saved user data again just in case")
                
                tableView.reloadData() //reload data in pantry so that table view updates with new data
            } else {
                //If a new item is created
                
                //let newIndexPath = IndexPath(row: pantry.count, section: 0)
                pantry.append(pantryItem) //add new item at end
                pantry[pantry.endIndex - 1].lastUpdate = Date()
                tableView.reloadData() //reload data so that table view updates with new data
                
                userData.profiles![profileIndex].pantry = pantry //Pass pantry data back to model controller
                userData.saveProfileData() //Save model data
                userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .insert, newObject: pantryItem, oldObject: pantryItem))
                log.info("ProfileModelController saved user data after adding new item to pantry")
            }
            
            //Ask for app review here
            requestAppReview()
            
        } else if segue.identifier == "deleteUnwind" {
            //MARK: - "deleteUnwind" Segue

            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                //Ugly code to remove a specific item from the array
                let pantryItemToRemove = itemsCollatedByCategory[categories[selectedIndexPath.section]]![selectedIndexPath.row]
                var index = 0
                for item in pantry {
                    //Used pantryItem name as an identifier, assuming generally user does not have 2 of same pantry item
                    if pantryItemToRemove == item {
                        break //If pantryItemToRemove matches the item, break out of the loop
                    } else {
                        index += 1
                    }
                }
                
                //Ugly code to remove a specific item from the array
                var shoppingIndex = 0
                for shoppingItem in userData.profiles![profileIndex].shoppingList {
                    if pantryItemToRemove == shoppingItem {
                        break
                    } else {
                        shoppingIndex += 1
                    }
                }
                
                pantry.remove(at: index) //remove item from pantry
                if (userData.profiles![profileIndex].shoppingList.contains(pantryItemToRemove)) {
                    userData.profiles![profileIndex].shoppingList.remove(at: shoppingIndex) //Remove item from shopping list
                    userData.profiles![profileIndex].shoppingListChangeLog.append(PantryChangeKey(time: Date(), changeType: .delete, newObject: pantryItemToRemove, oldObject: pantryItemToRemove))

                }
                
                //Pass data back to model controller
                userData.profiles![profileIndex].pantry = pantry //Pass pantry data back to model controller
                userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .delete, newObject: pantryItemToRemove, oldObject: pantryItemToRemove))
                
                //Reload tableViews
                tableView.reloadData() //reload table to reflect deleted item
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)
                
                userData.saveProfileData() //Save pantry data in profile
                log.info("ProfileModelController saved user data after removing an item from the pantry")
            }
        } else if segue.identifier == "addToShoppingListUnwind" {
            //MARK: - "addToShoppingListUnwind" Segue

            let sourceViewController = segue.source as! AddEditPantryItemTableViewController
        
            let pantryItem = sourceViewController.pantryItem
            
            //If it doesnt exist yet, add to pantry and shopping list
            if(!userData.profiles![profileIndex].pantry.contains(pantryItem)) {
                userData.profiles![profileIndex].pantry.append(pantryItem)
                userData.profiles![profileIndex].shoppingList.append(pantryItem)
                
                userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .insert, newObject: pantryItem, oldObject: pantryItem))

                userData.profiles![profileIndex].shoppingListChangeLog.append(PantryChangeKey(time: Date(), changeType: .insert, newObject: pantryItem, oldObject: pantryItem))
            } else {
                //Save to pantry
                let pantryIndex = userData.profiles![profileIndex].pantry.firstIndex(of: pantryItem)
                userData.profiles![profileIndex].pantryChangeLog.append(PantryChangeKey(time: Date(), changeType: .modify, newObject: pantryItem, oldObject: userData.profiles![profileIndex].pantry[pantryIndex!]))
                userData.profiles![profileIndex].pantry[pantryIndex!] = pantryItem

                //Add to ShoppingList
                
                //Increment if it already is there
                if(userData.profiles![profileIndex].shoppingList.contains(pantryItem)) {
                    let shoppingListIndex = userData.profiles![profileIndex].shoppingList.firstIndex(of: pantryItem)
                    userData.profiles![profileIndex].shoppingList[shoppingListIndex!].neededQuantity += 1
                    
                    userData.profiles![profileIndex].shoppingListChangeLog.append(PantryChangeKey(time: Date(), changeType: .modify, newObject: userData.profiles![profileIndex].shoppingList[shoppingListIndex!], oldObject: pantryItem))

                    userData.profiles![profileIndex].shoppingList[shoppingListIndex!].lastUpdate = Date()
                } else {
                    userData.profiles![profileIndex].shoppingList.append(pantryItem)
                    userData.profiles![profileIndex].shoppingListChangeLog.append(PantryChangeKey(time: Date(), changeType: .insert, newObject: pantryItem, oldObject: pantryItem))
                }
            }
            
            userData.profiles![profileIndex].shoppingListChangeLog.append(PantryChangeKey(time: Date(), changeType: .insert, newObject: pantryItem, oldObject: pantryItem))

            userData.saveProfileData() //Save all data
            log.info("ProfileModelController saved user data after adding an item to the shoppingList")
            
            //Reload tableViews for shoppingList and pantry tabs
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![profileIndex].pantry)
            /*
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //Uglyish code to add a specific item to the ShoppingList
                let pantryItemToAdd = itemsCollatedByCategory[categories[selectedIndexPath.section]]![selectedIndexPath.row]
                var index = 0
                //Look through the shopping list array
                for item in userData.profiles![profileIndex].shoppingList {
                    if pantryItemToAdd == item { //If item is in the array, increase neededQuantity by one for that item
                        userData.profiles![profileIndex].shoppingList[index].neededQuantity += 1
                        userData.profiles![profileIndex].shoppingList[index].lastUpdate = Date()
                        ShoppingListTableViewController().tableView.reloadData() //Reloads shoppingList table view
                        return
                    } else { //Else try again
                        index += 1
                    }
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)
            
                //If item is not in array, loop ends and adds item to end of the shoppingList array
                userData.profiles![profileIndex].shoppingList.append(pantryItemToAdd)
                userData.profiles![profileIndex].shoppingList[userData.profiles![profileIndex].shoppingList.endIndex - 1].lastUpdate = Date()
                
                userData.saveProfileData() //Save all data
                log.info("ProfileModelController saved user data after adding an item to the shoppingList")
                
                //Tell ShoppingList Tab to reload data with new shoppingList data
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)
            }
            */
            
        }
        
    }

}

// MARK: - Class Extensions

//Extensions to make search bar work
extension PantryTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
        
        //Reload pantry as filter changes
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![profileIndex].pantry)
    }
}

//MARK: - Request App Review
extension PantryTableViewController {
    //Logic to request app review
    func requestAppReview() {
        // If the app doesn't store the count, this returns 0.
        var count = UserDefaults.standard.integer(forKey: "savePantryItemKey")
        count += 1
        UserDefaults.standard.set(count, forKey: "savePantryItemKey")
        log.info("Process completed \(count) time(s).")

        // Keep track of the most recent app version that prompts the user for a review.
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReviewKey")

        // Get the current bundle version for the app.
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary.") }
         // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
         if count >= 15 && currentVersion != lastVersionPromptedForReview {
             Task { @MainActor [weak self] in
                 // Delay for two seconds to avoid interrupting the person using the app.
                 // Use the equation n * 10^9 to convert seconds to nanoseconds.
                 try? await Task.sleep(nanoseconds: UInt64(2e9))
                 log.info("Presenting Request for App Review")
                 if let windowScene = self?.view.window?.windowScene,
                    self?.navigationController?.topViewController is PantryTableViewController {
                     SKStoreReviewController.requestReview(in: windowScene)
                     UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReviewKey")
                }
             }
         }
    }
}

