//
//  RecipeTableViewCell.swift
//  InventoryApp
//
//  Created by Simon Liles on 7/2/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var recipeNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Update the cell with data from a Recipe Object
    func update(with recipe: Recipe) {
        recipeNameLabel.text = recipe.name
    }
}
