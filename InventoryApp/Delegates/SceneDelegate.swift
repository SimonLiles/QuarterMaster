//
//  SceneDelegate.swift
//  InventoryApp
//
//  Created by Simon Liles on 5/26/20.
//  Copyright © 2020 Simon Liles. All rights reserved.
//

import UIKit

import os

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    //Object to collect and store logs.
    let log = Logger()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        //Initialize app instance data on start up
        if let savedInstance = AppInstanceController().loadInstanceData() {
            AppInstanceController.shared.appInstance = savedInstance
        } else {
            AppInstanceController.shared.appInstance = AppInstanceController().loadSampleInstance()!
        }
                
        var initialViewControllerID: String = "" //ID of the initial view controller
        
        //If this is first launch, do a permissions ask
        if(AppInstanceController.shared.appInstance.firstLaunch == true) {
            //Set Initial View Controller as Profiles Page
            initialViewControllerID = "LANPermNavController"
        } else {
            //Set Initial View Controller as Profiles Page
            initialViewControllerID = "ProfileNavController"
            //Start Multipeer services
            MultipeerSession.instance.startServices()
        }
        
        AppInstanceController.shared.appInstance.firstLaunch = false
        
        //Set initial View Controller
        if let windowScene = scene as? UIWindowScene {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = storyboard.instantiateViewController(withIdentifier: initialViewControllerID)// RootViewController in here
            self.window = window
            window.makeKeyAndVisible()
        }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        //Save app data to disk while disconecting
        userData.saveProfileData()
        log.info("ProfileModelController data saved while disconnecting")
        
        AppInstanceController.shared.saveInstanceData()
        log.info("App Instance data saved while disconnecting")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        //Save app data to disk while moving from active state to inactive
        userData.saveProfileData()
        log.info("ProfileModelController data saved while moving from active state to inactive")
        
        AppInstanceController.shared.saveInstanceData()
        log.info("App Instance data saved while moving from active state to inactive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        //Save app data to disk while entering Background
        userData.saveProfileData()
        log.info("ProfileModelController data saved while entering background") //debug save state
        
        AppInstanceController.shared.saveInstanceData()
        log.info("App Instance data saved while entering background")

    }


}

