//
//  AppInstanceController.swift
//  InventoryApp
//
//  Created by Simon Liles on 5/26/22.
//  Copyright © 2022 Simon Liles. All rights reserved.
//

import Foundation

class AppInstanceController {
    
    static let shared = AppInstanceController()
    
    var appInstance = AppInstance()
    
    //MARK: - Data Persistence
    
    //URL address on user device for app memory
    let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("appInstance").appendingPathExtension("json")
    
    /**
     Saves the app instance object representing user data to a .json file.
     */
    func saveInstanceData() {
        log.info("AppInstanceController writing appInstance to disk")
        
        let jsonEncoder = JSONEncoder()
        let encodedInstance = try? jsonEncoder.encode(appInstance) //encode app instance data
        
        try? encodedInstance?.write(to: archiveURL) //attempt to write app instance data to json file
    }
    
    /**
     Pulls user data from selected .json file. Will return nil if file is empty or does not exist.
     
     - Returns: Optional array of profile objects.
     */
    func loadInstanceData() -> AppInstance? {
        log.info("Loading existing user data")
        
        let jsonDecoder = JSONDecoder()
        
        guard let retrievedInstanceData = try? Data(contentsOf: archiveURL) else { return nil } //Pulls json encoded profile data
        
        let decodedInstance: AppInstance? = try? jsonDecoder.decode(AppInstance.self, from: retrievedInstanceData) //Decodes JSON app instance data
        
        return decodedInstance
    }
    
    /**
    Loads sample app instance data.
     
     Can be used in cases where existing user data does not exist yet. Creates full data set to make debugging easier after first install and can give user an example to play with.
     
     - Returns: sample app instance data to getthings running
     */
    func loadSampleInstance() -> AppInstance? {
        log.info("Loading sample instance data")
        
        let sampleInstance = AppInstance(firstLaunch: true)
        
        return sampleInstance
    }
}
