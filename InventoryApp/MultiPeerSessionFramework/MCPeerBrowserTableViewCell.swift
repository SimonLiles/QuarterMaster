//
//  MCPeerBrowserTableViewCell.swift
//  ShareOfflinePrototype
//
//  Created by Simon Liles on 1/11/22.
//  Copyright © 2022 Simon Liles. All rights reserved.
//

import Foundation

import UIKit
import MultipeerConnectivity

import os

class MCPeerBrowserTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var peerIDLabel: UILabel!
    @IBOutlet weak var peerStatusLabel: UILabel!

    // MARK: - Variables & Constants
        
    //creates empty object to later fill
    var peer: MCPeerID = MCPeerID(displayName: "peer")
    
    var indexpath: IndexPath = IndexPath()
    
    //Object to collect and store logs.
    let log = Logger()
    
    //let connectedPeers = MultipeerSession.instance.connectedPeers
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Update the cell with data from a PantryItem object
    /**
     Updates pantry tableview cell with data from a pantryItem object
     
        - Parameter pantryItem: holds pantryItem object for a specific cell
        - Parameter path: indexPath object
     */
    func update(with nearbyPeer: MCPeerID, at path: IndexPath) {
        log.info("Updating peer browser table view cells")
        
        //collect data from parameters to use locally in TableViewCell Class
        peer = nearbyPeer
        indexpath = path
        var peerStatus = ""
        
        if (MultipeerSession.instance.connectedPeers.contains(peer)) {
            peerStatus = "Connected"
        } else {
            peerStatus = "Not Connected"
        }
        
        //Update the cell GUI
        peerIDLabel.text = peer.displayName
        peerStatusLabel.text = peerStatus
        
        log.info("Showing nearbyPeer: \(self.peer.displayName, privacy: .private)")
        
        //Update model object data
    }

    // MARK: - IBActions
}
