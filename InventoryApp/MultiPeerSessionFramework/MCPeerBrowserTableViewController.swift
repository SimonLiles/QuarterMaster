//
//  MCPeerBrowserTableViewController.swift
//  ShareOfflinePrototype
//
//  Created by Simon Liles on 1/11/22.
//  Copyright © 2022 Simon Liles. All rights reserved.
//

import Foundation

import UIKit
import MultipeerConnectivity

import os

class MCPeerBrowserTableViewController: UITableViewController {
    
    var nearbyPeers = MultipeerSession.instance.nearbyPeers
    var connectedPeers = MultipeerSession.instance.connectedPeers
    
    //Object to collect and store logs.
    let log = Logger()

    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Listen for notification to update view when session data changes
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "session_did_change"), object: nil)
        
        //Get data from session controller
    }
    
    //Called when a notification is received for reloadTable
    @objc func reloadTable(notification: NSNotification) {
        nearbyPeers = MultipeerSession.instance.nearbyPeers
        connectedPeers = MultipeerSession.instance.connectedPeers
        
        DispatchQueue.main.async {
            self.log.info("reloading peer browser tableview")
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    //Set number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //Set number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPeers.count
    }
    
    //Sets section header titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let peerCount = nearbyPeers.count
        
        switch(peerCount) {
        case 0:
            return "No peers found nearby"
        case 1:
            return "1 peer found"
        default:
            return "\(peerCount) peers found"
        }
    }
    
    //Configures each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MCPeerBrowserCell", for: indexPath) as! MCPeerBrowserTableViewCell
        
        //Fetch data to populate the cell
        let peer = nearbyPeers[indexPath.row]
        
        // Configure the cell...
        
        cell.update(with: peer, at: indexPath)

        return cell
    }
    
    //Tracks which row is selected and then does a thing
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // When user selects an item, put a checkmark next to it and return to edit menu
            let selectedPeer = nearbyPeers[indexPath.row]
            
            if (!connectedPeers.contains(selectedPeer)) {
                MultipeerSession.instance.invitePeer(with: selectedPeer)
                MultipeerSession.instance.foundPeers[selectedPeer] = "Invite Sent"
            }
            
            tableView.reloadData()
        default:
            break
        }
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
