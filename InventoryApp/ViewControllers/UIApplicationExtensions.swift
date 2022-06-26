//
//  UIApplicationExtensions.swift
//  InventoryApp
//
//  Created by Simon Liles on 6/26/22.
//  Copyright © 2022 Simon Liles. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
            // Get connected scenes
            return UIApplication.shared.connectedScenes
                // Keep only active scenes, onscreen and visible to the user
                .filter { $0.activationState == .foregroundActive }
                // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
                // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.windows
                // Finally, keep only the key window
                .first(where: \.isKeyWindow)
        }
    
    var keyWindowPresentedController: UIViewController? {
            var viewController = self.keyWindow?.rootViewController
            
            // If root `UIViewController` is a `UITabBarController`
            if let presentedController = viewController as? UITabBarController {
                // Move to selected `UIViewController`
                viewController = presentedController.selectedViewController
            }
            
            // Go deeper to find the last presented `UIViewController`
            while let presentedController = viewController?.presentedViewController {
                // If root `UIViewController` is a `UITabBarController`
                if let presentedController = presentedController as? UITabBarController {
                    // Move to selected `UIViewController`
                    viewController = presentedController.selectedViewController
                } else {
                    // Otherwise, go deeper
                    viewController = presentedController
                }
            }
            
            return viewController
        }
}

