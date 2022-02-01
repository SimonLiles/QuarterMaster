//
//  AddToShoppingListTableViewController.swift
//  InventoryApp
//
//  Creates and manages list of items to be added to the shopping
//  list from existing pantry items
//
//  User can add items to shopping list in the shopping list tab
//  from this view
//
//  Created by Simon Liles on 7/8/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class AddToShoppingListTableViewController: UITableViewController {

    // MARK: - IBOutlets
    
    // MARK: - Constants and Variables
    static let sharedItemAdder = AddToShoppingListTableViewController()
    
    var profileIndex = ProfileModelController.shared.selectedIndex
    
    var availableItems: [PantryItem] = []
    
    var itemsToAdd: [PantryItem] = []
    
    //Collates shopping list with Category keys
    var itemsCollatedByCategory: [String: [PantryItem]] {
        Dictionary(grouping: availableItems, by: { $0.category })
    }
    
    //Sorts shopping list by category
    var itemsSortedByCategory: [PantryItem] {
        return availableItems.sorted { $0.category.lowercased() < $1.category.lowercased() }
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
                
        profileIndex = ProfileModelController.shared.selectedIndex
        availableItems = ProfileModelController.shared.profiles![profileIndex].pantry //Makes available items equal to the current pantry

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //Initialization of Search Bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pantry"
        navigationItem.searchController = searchController
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        searchController.isActive = true
        definesPresentationContext = true
    }
    
    // MARK: - Search Bar Functionality
    
    //Function to filter for search results
    func filterContentForSearchText(_ searchText: String) {
        
        filteredShoppingList = availableItems.filter { (pantryItem: PantryItem) -> Bool in
        
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
            return filteredShoppingList.count
        }
        
        //Implemntation of dynamic categories
        return itemsCollatedByCategory[categories[section]]!.count
    }
    
    //Sets section header titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //activates when search bar is used
        if isFiltering {
            return "Search"
        }
        
        return categories[section]
    }
    
    //Configures each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pantryItemCell", for: indexPath) as! AddToShoppingListTableViewCell
        
        //Fetch model object to display in cell
        let item: PantryItem
        
        if isFiltering {
            item = filteredShoppingList[indexPath.row]
        } else {
            item = itemsCollatedByCategory[categories[indexPath.section]]![indexPath.row]
        }
        
        // Configure the cell...
        cell.update(with: item)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToAddToShoppingList(segue: UIStoryboardSegue) {
        //do nothing on arrival here, for now...
    }
    
}

// MARK: - Class Extensions

//Extensions to make search bar work
extension AddToShoppingListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
