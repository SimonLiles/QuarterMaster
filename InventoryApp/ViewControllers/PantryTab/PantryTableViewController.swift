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

import UIKit

import os

class PantryTableViewController: UITableViewController {
    
    /// MARK: - IBOutlets
    //@IBOutlet weak var pantrySearchBar: UISearchBar!
    
    // MARK: - Constants and Variables
    static var sharedPantryController = PantryTableViewController()
    
    var profileIndex = ProfileModelController.shared.selectedIndex //Array index for use when modifying a specific profile
    
    var pantry: [PantryItem] = []
    
    //Collates pantry with Category keys
    var itemsCollatedByCategory: [String: [PantryItem]] {
        Dictionary(grouping: pantry, by: { $0.category })
    }
    
    //Sorts pantry by category
    var itemsSortedByCategory: [PantryItem] {
        return pantry.sorted { $0.category.lowercased() < $1.category.lowercased() }
    }
    
    //List of all possible categories
    var categories: [String] {
        itemsCollatedByCategory.map({$0.key}).sorted()
    }
    
    //Collates pantry with Location Keys
    var itemsCollatedByLocation: [String: [PantryItem]] {
        Dictionary(grouping: pantry, by: { $0.location })
    }
    
    //Sorts pantry by location
    var itemsSortedByLocation: [PantryItem] {
        return pantry.sorted { $0.location.lowercased() < $1.location.lowercased() }
    }
    
    //List of all possible Locations
    var locations: [String] {
        itemsCollatedByLocation.map({$0.key}).sorted()
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
        profileIndex = ProfileModelController.shared.selectedIndex
        pantry = ProfileModelController.shared.profiles![profileIndex].pantry
        pantry = itemsSortedByCategory
        
        //Initialization of Search Bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pantry"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //Send data to any connected peers
        ProfileModelController.shared.profiles![profileIndex].versionTimeStamp = Date()
        ProfileModelController.shared.saveProfileData()
        log.info("ProfileModelController saved user data before sending data to conected peers")
        ProfileModelController.shared.sendProfile()
    }
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        self.tableView.reloadData()
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadTable(notification: NSNotification) {
        log.info("Pantry tableView is reloading")
        pantry = ProfileModelController.shared.profiles![profileIndex].pantry
        
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
        
        return categories.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        //limits number of cells when user is searching
        if isFiltering {
            return filteredPantry.count
        }
        
        //Implementation of dynamic categories
        return itemsCollatedByCategory[categories[section]]!.count
    }
    
    //Sets section header titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //activates when search bar is used
        if isFiltering {
            return "Searching Pantry"
        }
        
        return categories[section]
    }
    
    //Configures each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pantryItemCell", for: indexPath) as! PantryTableViewCell
                
        //Fetch model object to display in cell
        let pantryItem: PantryItem
        
        if isFiltering {
            pantryItem = filteredPantry[indexPath.row]
        } else {
            //pantryItem = pantry[indexPath.row]
            
            pantryItem = itemsCollatedByCategory[categories[indexPath.section]]![indexPath.row]
        }
        
        // Configure the cell...
        
        cell.update(with: pantryItem, at: indexPath)

        return cell
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
                pantryItem = itemsCollatedByCategory[categories[indexPath.section]]![indexPath.row]
            }
            
            //Pull pantryItem from model controller
            let pantryItemIndex = ProfileModelController.shared.profiles![profileIndex].pantry.firstIndex(of: pantryItem)
            pantryItem = ProfileModelController.shared.profiles![profileIndex].pantry[pantryItemIndex!]
            
            let navController = segue.destination as! UINavigationController
            let addEditPantryItemTableViewController = navController.topViewController as! AddEditPantryItemTableViewController
            
            // Pass pantryItem object to AddEditPantryItemTableViewController
            addEditPantryItemTableViewController.pantryItem = pantryItem
        }
    }
    
    //For unwinding from add edit mode, saves data and updates the table
    @IBAction func unwindToPantryTableView(segue: UIStoryboardSegue) {
        //guard segue.identifier == "saveUnwind" else {return}
        
        if segue.identifier == "saveUnwind" {
            let sourceViewController = segue.source as! AddEditPantryItemTableViewController
        
            let pantryItem = sourceViewController.pantryItem
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                //Ugly code to change a specific item in Pantry
                let pantryItemToChange = itemsCollatedByCategory[categories[selectedIndexPath.section]]![selectedIndexPath.row]
                var index = 0
                for item in pantry {
                    //Used pantryItem name as an identifier, assuming generally user does not have 2 of same pantry item
                    if pantryItemToChange == item {
                        break //If pantryItemToRemove matches the item, break out of the loop
                    } else {
                        index += 1
                    }
                }
                pantry[index] = pantryItem //update item with new data
                pantry[index].lastUpdate = Date()
                
                //Ugly code to change a specific item in Shopping List
                var shoppingListIndex = 0
                for anotherItem in ProfileModelController.shared.profiles![profileIndex].shoppingList {
                    if pantryItemToChange == anotherItem {
                        ProfileModelController.shared.profiles![profileIndex].shoppingList[shoppingListIndex] = pantryItem
                        ProfileModelController.shared.profiles![profileIndex].shoppingList[shoppingListIndex].lastUpdate = Date()
                        break
                    } else {
                        shoppingListIndex += 1
                    }
                }
                
                //Pass pantry data back to ProfileModelController and save all data
                ProfileModelController.shared.profiles![profileIndex].pantry = pantry
                ProfileModelController.shared.saveProfileData()
                log.info("ProfileModelController saved user data after unwinding to PantryTableView")
                
                //Tell ShoppingList Tab to reload data with new shoppingList data
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: ProfileModelController.shared.profiles![profileIndex].shoppingList)
                
                ProfileModelController.shared.saveProfileData() //Save data again just in case
                log.info("ProfileModelController saved user data again just in case")
                
                tableView.reloadData() //reload data in pantry so that table view updates with new data
            } else {
                //let newIndexPath = IndexPath(row: pantry.count, section: 0)
                pantry.append(pantryItem) //add new item at end
                pantry[pantry.endIndex - 1].lastUpdate = Date()
                tableView.reloadData() //reload data so that table view updates with new data
                
                ProfileModelController.shared.profiles![profileIndex].pantry = pantry //Pass pantry data back to model controller
                ProfileModelController.shared.saveProfileData() //Save model data
                log.info("ProfileModelController saved user data after adding new item to pantry")
            }
            
        } else if segue.identifier == "deleteUnwind" {
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
                for shoppingItem in ProfileModelController.shared.profiles![profileIndex].shoppingList {
                    if pantryItemToRemove == shoppingItem {
                        break
                    } else {
                        shoppingIndex += 1
                    }
                }
                
                pantry.remove(at: index) //remove item from pantry
                if (ProfileModelController.shared.profiles![profileIndex].shoppingList.contains(pantryItemToRemove)) {
                    ProfileModelController.shared.profiles![profileIndex].shoppingList.remove(at: shoppingIndex) //Remove item from shopping list
                }
                
                //Pass data back to model controller
                ProfileModelController.shared.profiles![profileIndex].pantry = pantry //Pass pantry data back to model controller

                //Reload tableViews
                tableView.reloadData() //reload table to reflect deleted item
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: ProfileModelController.shared.profiles![profileIndex].shoppingList)
                
                ProfileModelController.shared.saveProfileData() //Save pantry data in profile
                log.info("ProfileModelController saved user data after removing an item from the pantry")
            }
        } else if segue.identifier == "addToShoppingListUnwind" {
            let sourceViewController = segue.source as! AddEditPantryItemTableViewController
        
            let pantryItem = sourceViewController.pantryItem
            
            //If it doesnt exist yet, add to pantry and shopping list
            if(!ProfileModelController.shared.profiles![profileIndex].pantry.contains(pantryItem)) {
                ProfileModelController.shared.profiles![profileIndex].pantry.append(pantryItem)
                ProfileModelController.shared.profiles![profileIndex].shoppingList.append(pantryItem)
            } else {
                //Save to pantry
                let pantryIndex = ProfileModelController.shared.profiles![profileIndex].pantry.firstIndex(of: pantryItem)
                ProfileModelController.shared.profiles![profileIndex].pantry[pantryIndex!] = pantryItem
                
                //Add to ShoppingList
                
                //Increment if it already is there
                if(ProfileModelController.shared.profiles![profileIndex].shoppingList.contains(pantryItem)) {
                    let shoppingListIndex = ProfileModelController.shared.profiles![profileIndex].shoppingList.firstIndex(of: pantryItem)
                    ProfileModelController.shared.profiles![profileIndex].shoppingList[shoppingListIndex!].neededQuantity += 1
                    ProfileModelController.shared.profiles![profileIndex].shoppingList[shoppingListIndex!].lastUpdate = Date()
                } else {
                    ProfileModelController.shared.profiles![profileIndex].shoppingList.append(pantryItem)
                }
            }
            
            ProfileModelController.shared.saveProfileData() //Save all data
            log.info("ProfileModelController saved user data after adding an item to the shoppingList")
            
            //Reload tableViews for shoppingList and pantry tabs
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: ProfileModelController.shared.profiles![profileIndex].shoppingList)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: ProfileModelController.shared.profiles![profileIndex].pantry)
            /*
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //Uglyish code to add a specific item to the ShoppingList
                let pantryItemToAdd = itemsCollatedByCategory[categories[selectedIndexPath.section]]![selectedIndexPath.row]
                var index = 0
                //Look through the shopping list array
                for item in ProfileModelController.shared.profiles![profileIndex].shoppingList {
                    if pantryItemToAdd == item { //If item is in the array, increase neededQuantity by one for that item
                        ProfileModelController.shared.profiles![profileIndex].shoppingList[index].neededQuantity += 1
                        ProfileModelController.shared.profiles![profileIndex].shoppingList[index].lastUpdate = Date()
                        ShoppingListTableViewController().tableView.reloadData() //Reloads shoppingList table view
                        return
                    } else { //Else try again
                        index += 1
                    }
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: ProfileModelController.shared.profiles![profileIndex].shoppingList)
            
                //If item is not in array, loop ends and adds item to end of the shoppingList array
                ProfileModelController.shared.profiles![profileIndex].shoppingList.append(pantryItemToAdd)
                ProfileModelController.shared.profiles![profileIndex].shoppingList[ProfileModelController.shared.profiles![profileIndex].shoppingList.endIndex - 1].lastUpdate = Date()
                
                ProfileModelController.shared.saveProfileData() //Save all data
                log.info("ProfileModelController saved user data after adding an item to the shoppingList")
                
                //Tell ShoppingList Tab to reload data with new shoppingList data
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: ProfileModelController.shared.profiles![profileIndex].shoppingList)
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
    }
}

