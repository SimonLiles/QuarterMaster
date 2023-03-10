//
//  ShoppingListTableViewController.swift
//  InventoryApp
//
//  Manages the Shopping List Table View
//  Feautures include, Search bar, dynamic categories, dynamic cells
//
//  This view is where user manages the shopping list
//
//  Created by Simon Liles on 7/1/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class ShoppingListTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var doneShoppingButton: UIBarButtonItem!
    
    
    // MARK: - Constants and Variables
    static var sharedShoppingListView = ShoppingListTableViewController()
    
    var profileIndex = userData.selectedIndex //Array index for use when modifying a specific profile
    
    var shoppingList: [PantryItem] = []
    
    //Collates shopping list with Category keys
    var itemsCollatedByCategory: [String: [PantryItem]] {
        Dictionary(grouping: itemsSortedByCategory, by: { $0.category })
    }
    
    //Sorts shopping list by category
    var itemsSortedByCategory: [PantryItem] {
        return shoppingList.sorted { $0.category.lowercased() < $1.category.lowercased() }
    }
    
    //List of all possible categories
    var categories: [String] {
        itemsCollatedByCategory.map({$0.key}).sorted()
    }
    
    //Search bar constants and variables
    let searchController = UISearchController(searchResultsController: nil)
    var filteredShoppingList: [PantryItem] = [] //Holds pantryItems that are being searched for
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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "reloadShoppingList"), object: nil)
                
        profileIndex = userData.selectedIndex
        shoppingList = userData.profiles![profileIndex].shoppingList
        shoppingList = itemsSortedByCategory

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //Initialization of Search Bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shopping List"
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
    
    //Called when a notification is received for reloadTable
    @objc func reloadTable(notification: NSNotification) {
        log.info("Shopping List tableView is reloading")
        shoppingList = userData.profiles![profileIndex].shoppingList
        //let pantry = userData.profiles![profileIndex].shoppingList
        
        tableView.reloadData()
    }
    
    // MARK: - Search Bar Functionality
    
    //Function to filter for search results
    func filterContentForSearchText(_ searchText: String) {
        log.info("Shopping List search is filtering")
        
        filteredShoppingList = shoppingList.filter { (pantryItem: PantryItem) -> Bool in
        
            return pantryItem.name.lowercased().contains(searchText.lowercased())
        }
      
        log.info("\(self.filteredShoppingList.count) results found")
        
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    
    
    
    // MARK: - Done Shopping Button
    @IBAction func doneShoppingButtonPressed(_ sender: UIBarButtonItem) {
        log.info("User pressed \"Done Shopping\" Button")
        
        let shoppingListAlertMessage = "Finish shopping will remove marked off items and add them to your pantry.\nDelete Canceled Items will remove items marked with an X."
        
        let shoppingDoneAlert = UIAlertController(title: "Done Shopping?", message: shoppingListAlertMessage, preferredStyle: .actionSheet)
        
        //Initialize Actions for action sheet
        
        //Remove Items with a check and add their quantity to the pantry
        let finishShoppingAction = UIAlertAction(title: "Finish Shopping", style: .default, handler: { [self] action in
            
            let doneShoppingAlert = UIAlertController(title: "Done Shopping?", message: "Move marked off items to Pantry?", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Done Shopping", style: .default, handler: { [self] action in
                log.info("User chose Finish Shopping")
                log.info("Moving items with .bought status to pantry")
                
                userData.updatePantryFromShoppingList()
                
                //Reload tableViews for shoppingList and pantry tabs
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![profileIndex].pantry)
                tableView.reloadData()
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            doneShoppingAlert.addAction(confirmAction)
            doneShoppingAlert.addAction(cancelAction)
            
            self.present(doneShoppingAlert, animated: true, completion: nil)
        }) //Here is the end of this long closure for finished shopping
        
        //Remove items marked with X
        let deleteCanceledItemsAction = UIAlertAction(title: "Delete Canceled Items", style: .destructive, handler: { [self] action in
            
            let deleteCanceledItemsAlert = UIAlertController(title: "Delete?", message: "Delete canceled items? This action cannot be undone.", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { [self] action in
                
                log.info("User chose \"Delete Canceled Items\"")
                log.info("Removing items from shopping list with .notBought status")
                
                // Run through shopping list array, if Item has an X Mark, then remove from shoppingList
                var index = 0
                for item in userData.profiles![profileIndex].shoppingList {
                    if item.purchaseStatus == .notBought {
                        //Run through pantry array to find corresponding item and reset purchase status
                        var pantryIndex = 0
                        for pantryItem in userData.profiles![profileIndex].pantry {
                            if pantryItem == item {
                                userData.profiles![profileIndex].pantry[pantryIndex].neededQuantity = 1 //Reset needed quanity for pantry item
                                userData.profiles![profileIndex].pantry[pantryIndex].purchaseStatus = .toBuy
                            } else {
                                pantryIndex += 1
                            }
                        }
                        userData.profiles![profileIndex].shoppingList[index].neededQuantity = 0 //Reset needed quantity to 0
                        
                        userData.profiles![profileIndex].shoppingList.remove(at: index) //Remove item from shoppingList
                        shoppingList = userData.profiles![profileIndex].shoppingList //make tableview shopping list equal to shoppingList Model Controller
                    } else {
                        index += 1
                    }
                }
                
                userData.profiles![profileIndex].shoppingListLastClear = Date()

                //Save Data
                userData.saveProfileData()
                log.info("ProfileModelController saved user data after clearing canceled items in shopping list")

                //Reload tables
                tableView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![profileIndex].pantry)
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            deleteCanceledItemsAlert.addAction(deleteAction)
            deleteCanceledItemsAlert.addAction(cancelAction)
            
            self.present(deleteCanceledItemsAlert, animated: true, completion: nil)
            
        }) //Here is the end of this long closure for deleting cancled items

        //Add actions
        shoppingDoneAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil)) // Cancel Action
        shoppingDoneAlert.addAction(finishShoppingAction)
        shoppingDoneAlert.addAction(deleteCanceledItemsAction)
        
        if let popoverController = shoppingDoneAlert.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        present(shoppingDoneAlert, animated: true, completion: nil)
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
            return filteredShoppingList.count
        }
        
        //Implemntation of dynamic categories
        return itemsCollatedByCategory[categories[section]]!.count
    }
    
    //Sets section header titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //activates when search bar is used
        if isFiltering {
            if (filteredShoppingList.count <= 0) {
                return "No Results found"
            } else {
                return "Searching Shopping List"
            }
        }
        
        return categories[section]
    }

    //Configures each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath) as! ShoppingListTableViewCell
        //Make sure view data is aligned with model data
        shoppingList = userData.profiles![profileIndex].shoppingList

        //Fetch model object to display in cell
        let shoppingListItem: PantryItem
        
        if isFiltering {
            shoppingListItem = filteredShoppingList[indexPath.row]
        } else {
            shoppingListItem = itemsCollatedByCategory[categories[indexPath.section]]![indexPath.row]
        }
        
        // Configure the cell...
        cell.update(with: shoppingListItem, at: indexPath)

        return cell
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func unwindToShoppingListTableView(segue: UIStoryboardSegue) {
        
        //When user presses done, adds items from the add view to the shopping list
        if segue.identifier == "doneUnwind" {
            //let sourceViewController = segue.source as! AddToShoppingListTableViewController
            
            //let itemsBeingAdded = sourceViewController.itemsToAdd
            let itemsBeingAdded = AddToShoppingListTableViewController.sharedItemAdder.itemsToAdd
            
            var index = 0
            for item in itemsBeingAdded {
                if shoppingList.contains(item) {
                    userData.profiles![profileIndex].shoppingList[shoppingList.firstIndex(of: item)!].neededQuantity += 1
                    userData.profiles![profileIndex].shoppingList[shoppingList.firstIndex(of: item)!].lastUpdate = Date()
                    
                    //itemsBeingAdded.remove(at: index)
                } else {
                    userData.profiles![profileIndex].shoppingList.append(item)
                }
                
                index += 1
            }
            
            shoppingList = userData.profiles![profileIndex].shoppingList
            
            AddToShoppingListTableViewController.sharedItemAdder.itemsToAdd = [] //Reset the array after user presses done
        } else if segue.identifier == "saveUnwind" {
            // Following block adds a new item from the add new item menu in the shopping list tab to the shopiing list
            // and a new item to the pantry
            
            let sourceViewController = segue.source as! AddNewShoppingListItemTableViewController
            
            var newShoppingListItem = sourceViewController.shoppingListItem
            newShoppingListItem.lastUpdate = Date()
            
            //Append new shopping list item to end of array
            userData.profiles![profileIndex].shoppingList.append(newShoppingListItem)
            shoppingList.append(newShoppingListItem)
            userData.profiles![profileIndex].pantry.append(newShoppingListItem)

            userData.profiles![profileIndex].shoppingListChangeLog.append(PantryChangeKey(time: Date(), changeType: .insert, newObject: newShoppingListItem, oldObject: newShoppingListItem))

            AddToShoppingListTableViewController.sharedItemAdder.itemsToAdd = [] //Reset the array after user presses save
            
            userData.saveProfileData()
            log.info("ProfileModelController saved user data after adding an item to the shoppingList")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPantry"), object: userData.profiles![profileIndex].pantry)
        } else if segue.identifier == "cancelUnwindFromAddToShoppingListView" {
            AddToShoppingListTableViewController.sharedItemAdder.itemsToAdd = [] //Reset the array after user presses cancel
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - Class Extensions

//Extensions to make search bar work
extension ShoppingListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
        
        //Reload pantry as filter changes
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShoppingList"), object: userData.profiles![profileIndex].shoppingList)

    }
}
