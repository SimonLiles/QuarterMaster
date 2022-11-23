//
//  ChangeLog.swift
//  InventoryApp
//
//  Created by Simon Liles on 11/23/22.
//  Copyright © 2022 Simon Liles. All rights reserved.
//

import Foundation

struct ChangeLog {
    
}

/**
 Most basic unit of the ChangeLog. Provides basic structure for tracking changes of any objects in the program. 
 */
struct PantryChangeKey: Codable {
    var time: Date
    var changeType: ChangeType
    var newObject: PantryItem
    var oldObject: PantryItem
    
    init(time: Date, changeType: ChangeType, newObject: PantryItem, oldObject: PantryItem) {
        self.time = time
        self.changeType = changeType
        self.newObject = newObject
        self.oldObject = oldObject
    }
}

/**
 ChangeType enumeration. Provides different types of changes that can exist in the ChangeLog
 */
enum ChangeType {
    ///Tracks when a new object is created
    case insert
    ///Tracks when an existing object is deleted
    case delete
    ///Tracks when parts of an existing object are changed
    case modify
}

extension ChangeType: Codable {
    enum CodingKeys: CodingKey {
        case insert
        case delete
        case modify
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .insert:
            self = .insert
        case .delete:
            self = .delete
        case .modify:
            self = .modify
        default:
            log.fault("Critical Fault: Unable to decode ChangeType enum")
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unable to decode ChangeType enum"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .insert:
            try container.encode(true, forKey: .insert)
        case.delete:
            try container.encode(true, forKey: .delete)
        case.modify:
            try container.encode(true, forKey: .modify)
        }
    }
    
}
