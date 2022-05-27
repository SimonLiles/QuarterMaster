//
//  LANPermViewController.swift
//  InventoryApp
//
//  Created by Simon Liles on 5/27/22.
//  Copyright © 2022 Simon Liles. All rights reserved.
//

import Foundation

import UIKit

class LANPermViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "LANPermSegue" {
            //Start Multipeer services
            MultipeerSession.instance.startServices()
        }
    }
}
