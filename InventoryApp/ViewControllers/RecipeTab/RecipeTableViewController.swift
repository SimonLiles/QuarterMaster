//
//  RecipeTableViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 7/2/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

class RecipeTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    // MARK: - Constants and Variables
    var recipes: [Recipe] = []
    
    //Collates shopping list with Category keys
    var itemsCollatedByCategory: [String: [Recipe]] {
        Dictionary(grouping: recipes, by: { $0.category })
    }
    
    //Sorts shopping list by category
    var itemsSortedByCategory: [Recipe] {
        return recipes.sorted { $0.category.lowercased() < $1.category.lowercased() }
    }
    
    //List of all possible categories
    var categories: [String] {
        itemsCollatedByCategory.map({$0.key}).sorted()
    }
    
    //Search bar constants and variables
    let searchController = UISearchController(searchResultsController: nil)
    var filteredRecipes: [Recipe] = [] //Holds pantryItems that are being searched for
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //Initializes user data when view loads
        if let savedRecipes = RecipeModelController().loadRecipesData() {
            RecipeModelController.sharedRecipes.recipes = savedRecipes
        } else {
            RecipeModelController.sharedRecipes.recipes = RecipeModelController().loadSampleRecipesData()!
            recipes = RecipeModelController.sharedRecipes.recipes
        }
        
        recipes = RecipeModelController.sharedRecipes.recipes
        recipes = itemsSortedByCategory
        
        //Initialization of Search Bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Recipes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Search Bar Functionality
    
    //Function to filter for search results
    func filterContentForSearchText(_ searchText: String) {
        
        filteredRecipes = recipes.filter { (recipe: Recipe) -> Bool in
        
            return recipe.name.lowercased().contains(searchText.lowercased())
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
            return filteredRecipes.count
        }
        
        //Implemntation of dynamic categories
        return itemsCollatedByCategory[categories[section]]!.count
    }
    
    //Sets section header titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //activates when search bar is used
        if isFiltering {
            return "Searching Recipes"
        }
        
        return categories[section]
    }
    
    //Configures each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        
        //Fetch model object to display in cell
        let recipe: Recipe
        
        if isFiltering {
            recipe = filteredRecipes[indexPath.row]
        } else {
            recipe = itemsCollatedByCategory[categories[indexPath.section]]![indexPath.row]
        }
        
        // Configure the cell...
        cell.update(with: recipe)

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

}

// MARK: - Class Extensions

//Extensions to make search bar work
extension RecipeTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
