//
//  MCSessionController.swift
//  ShareOfflinePrototype
//
//  Created by Simon Liles on 12/30/21.
//  Copyright © 2021 Simon Liles. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import os
/**
 MultipeerSession is a class that can be used to add P2P services to an app.
 
 # TODO:
- Must add further discussion and documentation on implementation
- Add implementation for trusted devices
 
 - Author: Simon Liles
 - Version: 0.0.0.9000
 */
class MultipeerSession: NSObject, ObservableObject {
    ///Shared instance of the session controller. Refer to this instance for it to be shared across the code base
    static var instance = MultipeerSession()
    
    //Service Parameters
    ///Name of the service.
    private var serviceType: String = "qnt-pantryshare"
    ///ID to be used to identify to other peers.
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    //Service Objects
    ///Object for handling service advertiser.
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    ///Object for handling service browser.
    private let serviceBrowser: MCNearbyServiceBrowser
    ///Object for handling Multipeer Session.
    private let session: MCSession
    
    ///Object to collect and store logs.
    let log = Logger()
    
    //Arrays to log the status of peers
    ///Array of connected peers.
    @Published var connectedPeers: [MCPeerID] = []
    ///Array of connecting peers. Currently holds no value
    @Published var connectingPeers: [MCPeerID] = []
    ///Array of not connected peers. Currently holds no value
    @Published var notConnectedPeers: [MCPeerID] = []
    
    ///Dictionary to store list of Peers
    var foundPeers: [MCPeerID : String] = [:]
    
    ///Array of nearby peers that are either connected or not connected. These are peers that are avialble on the specified service
    @Published var nearbyPeers: [MCPeerID] = []
    
    ///Array of trusted peerIDs
    @Published var trustedPeers: [MCPeerID] = []
    
    ///Catcher for receiving data.
    @Published var receivedData: Data?
        
    /**
     Initialize Multipeer Session
     
     - Parameter serviceName: String representing the name of the MC service. It is recomended to use an abbreviation of the company followed by a hyphen and then the specific service. For example: `sjl-mcservice`.
     */
    override init(/*serviceName: String, trustedPeers: [MCPeerID]*/) {
        log.info("Attempting to initialize Multipeer Session")
        //self.serviceType = serviceName
        //self.trustedPeers = trustedPeers

        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        super.init()
        
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
        startServices()
    }

    /**
     Deinitialize Multipeer Session
     */
    deinit {
        stopServices()
    }
    
    //MARK: - User service functions
    
    /**
     Sends data to all connected peers.
        
     Needs more than 0 peers to send data.
     
     Function is hardcoded to send data in the most reliable fashion possible.
        
    - Parameters:
        - data: encoded Data to be sent to other peers
    */
    func send(data: Data) {
        log.info("func send() called")
        
        if session.connectedPeers.count > 0 {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch let error as NSError {
                log.error("send error:\n \(error.localizedDescription)")
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                //present(ac, animated: true)
            }
        } else {
            log.info("Tried to send, but no peers were connected")
        }
    }
    
    /**
     Sets the name of the service.
     
     First 3 characters are used to identify the developer, followed by a hyphen "–" and then a short string for the name of the service.
     
     The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type (without the transport protocol) and meeting the restrictions of RFC 6335 (section 5.1) governing Service Name Syntax. In particular, the string:
     - Must be 1–15 characters long
     - Can contain only ASCII lowercase letters, numbers, and hyphens
     - Must contain at least one ASCII letter
     - Must not begin or end with a hyphen
     - Must not contain hyphens adjacent to other hyphens.
     - This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat.
     
     - Parameters:
        - name: A string representing the name of the P2P service. Must follow encoding rules.
     */
    func setServiceName(as name: String) {
        serviceType = "abc-default"
        
        //Check for length, between 1 and 15 characters
        if(name.count < 1 || name.count > 15) {
            log.fault("Name provided for P2P service is not between 1 and 15 characters in length")
            
            return
        }
        //Check for lowercase
        if(name != name.lowercased()) {
            log.fault("Name provided for P2P service must be all lower case")

            return
        }
        //Check for letters, numbers, and hyphens only
        let allCharSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz1234567890-")
        if(name.lowercased().rangeOfCharacter(from: allCharSet) == nil) {
            log.fault("Name provided for P2P service contains characters other than ASCII lowercase characters, numbers, or hyphens")

            return
        }
        //Check that it contains at least 1 ASCII letter
        let lowerCaseASCII = "abcdefghijklmnopqrstuvwxyz"
        if(name.contains(lowerCaseASCII)) {
            log.fault("Name provided for P2P service does not contain at least 1 lowercase letter")

            return
        }
        //Check does not begin or end with a hyphen
        if(name.first! == "-" || name.last! == "-") {
            log.fault("Name provided for P2P service cannot start nor end with a hyphen")

            return
        }
        //Check that there are no hyphens adjacent to eachother
        let length = name.count
        for index in 1...length {
            //First character of a pair
            var char1: Character = " "
            if(index < name.count) {
                char1 = name[name.index(name.startIndex, offsetBy: index, limitedBy: name.endIndex)!]
            }
            
            //Get the character after the given index
            var char2: Character = " "
            if(index < name.count - 1) {
                char2 = name[name.index(name.startIndex, offsetBy: index + 1, limitedBy: name.endIndex) ?? name.startIndex]
            }
            
            if((char1 == "-") && (char2 == "-") && (char1 == char2)) {
                log.fault("Name provided for P2P service contains adjacent hyphens, this is not allowed")
                
                return
            }
        }
        
        //Check for other domain name conventeions
        
        serviceType = name
    }
    
    /**
     Begins advertising  and browsing for other peers on the service.
     */
    func startServices() {
        //TODO: Add logic for only starting if services have not yet begun
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    /**
     Stops all advertising and browsing for other peers on the service.
     */
    func stopServices() {
        //TODO: Add logic for only stopping if services have not yet stopped
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
}

// MARK: - Advertiser Delegates
extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    ///Advertiser didNotStartAdvertising
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log.error("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    ///Advertiser didReceiveInvitation
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log.info("didReceiveInvitationFromPeer \(peerID, privacy: .private)")
        
        //Create the alert
        let alertTitle = "Do you wish to connect?"
        let alertMessage = "Device: " + peerID.displayName + " wishes to connect and share data."
        
        let connectAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        let connectAction = UIAlertAction(title: "Connect", style: .default, handler: { action in
            self.log.info("User chose join action")
            
            invitationHandler(true, self.session)
        })
        
        connectAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        connectAlert.addAction(connectAction)
        
        //Get current viewcontroller
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        
        //Display connection alert
        DispatchQueue.main.async {
            rootViewController?.present(connectAlert, animated: true, completion: nil)
        }
    }
}

// MARK: - Browser Delegates
extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    ///Browser didNotStartBrowsing
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    ///Browser foundPeer
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        log.info("ServiceBrowser found peer: \(peerID, privacy: .private)")
        
        //Add peer to list of nearby peers
        nearbyPeers.append(peerID)
        
        //Add peer to dictionary of found peers
        foundPeers[peerID] = "Found"
        
        //Post notification to update views displaying session info/data
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "session_did_change"), object: nil)
        
        //Uncomment this line for automatic peer invitations
        //browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    ///Browser lostPeer
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("ServiceBrowser lost peer: \(peerID, privacy: .private)")
    }
    
    ///Invite a peer
    func invitePeer(with peerID: MCPeerID) {
        serviceBrowser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
}

// MARK: - Session Management
/**
 MultipeerSession, MCSessionDelegate provides delegate conformance for MCSessionDelegate.
 Functions under this extension provide support for session services.
 */
extension MultipeerSession: MCSessionDelegate {
    
    ///Session didChange
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("peer \(peerID, privacy: .private) didChangeState: \(state.rawValue)")
        connectedPeers = session.connectedPeers
        log.info("Connected peers: \(self.connectedPeers.description, privacy: .private)")

        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            
            //Post notification to update views displaying session info/data
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "session_did_change"), object: nil)
        }
        
        switch state {
        case MCSessionState.connected:
            log.info("Connected: \(peerID.displayName, privacy: .private)")
            serviceAdvertiser.stopAdvertisingPeer()
            serviceBrowser.stopBrowsingForPeers()
            foundPeers[peerID] = "Connected"
            
            //Send selected profile data to peers when connected
            //ProfileModelController.shared.sendProfile()
            
        case MCSessionState.connecting:
            log.info("Connecting: \(peerID.displayName, privacy: .private)")
            foundPeers[peerID] = "Connecting"


        case MCSessionState.notConnected:
            log.info("Not Connected: \(peerID.displayName, privacy: .private)")
            foundPeers[peerID] = "Not Connected"
            
        default:
            log.fault("Something Broke in session peer didChange")
        }
    }
    
    ///Session didReceive data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        log.info("didReceive bytes \(data.count) bytes")
        
        receivedData = data
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "received_data"), object: receivedData)
        
        log.info("Notification for 'received_data' sent")
    }
    
    ///

    ///Session didReceive stream
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.fault("Receiving streams is not supported")
    }

    ///Session didStartReceivingResource
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.fault("Receiving resources is not supported")
    }

    ///Session didFinishReceivingResource
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.fault("Receiving resources is not supported")
    }
}
