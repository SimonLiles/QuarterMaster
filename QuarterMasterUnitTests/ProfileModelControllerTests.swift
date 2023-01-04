//
//  ProfileModelControllerTests.swift
//  QuarterMasterUnitTests
//
//  Created by Simon Liles on 12/12/22.
//  Copyright © 2022 Simon Liles. All rights reserved.
//

import XCTest
@testable import QuarterMaster


final class ProfileModelControllerTests: XCTestCase {

    //Create the profile object
    var testProfile = Profile(name: "Test Profile",
                              pantry: [],
                              shoppingList: [],
                              categories: ["Cat 1", "Cat 2"],
                              locations: ["Loc 1", "Loc 2"],
                              units: ["Units"])
    
    //Fill the pantry
    var testItem1 = PantryItem(id: 1,
                               name: "Test Item 1",
                               category: "Cat 1",
                               location: "Loc 1",
                               currentQuantity: 1,
                               units: "Units", note: "",
                               lastUpdate: Date())
    var testItem2 = PantryItem(id: 2,
                               name: "Test Item 2",
                               category: "Cat 2",
                               location: "Loc 2",
                               currentQuantity: 1,
                               units: "Units", note: "",
                               lastUpdate: Date())
    var testItem3 = PantryItem(id: 3,
                               name: "Test Item 3",
                               category: "Cat 1",
                               location: "Loc 2",
                               currentQuantity: 1,
                               units: "Units", note: "",
                               lastUpdate: Date())
    var testItem4 = PantryItem(id: 4,
                               name: "Test Item 4",
                               category: "Cat 2",
                               location: "Loc 1",
                               currentQuantity: 1,
                               units: "Units", note: "",
                               lastUpdate: Date())
        
    //Modified Items
    var testItem1_mod = PantryItem(id: 1,
                                   name: "Test Item 1 - Modified",
                                   category: "Cat 1",
                                   location: "Loc 1",
                                   currentQuantity: 10,
                                   units: "Units", note: "",
                                   lastUpdate: Date())
    var testItem2_mod = PantryItem(id: 2,
                                   name: "Test Item 2 - Modified",
                                   category: "Cat 2",
                                   location: "Loc 2",
                                   currentQuantity: 10,
                                   units: "Units", note: "",
                                   lastUpdate: Date())
    var testItem3_mod = PantryItem(id: 3,
                                   name: "Test Item 3 - Modified",
                                   category: "Cat 1",
                                   location: "Loc 2",
                                   currentQuantity: 10,
                                   units: "Units", note: "",
                                   lastUpdate: Date())
    var testItem4_mod = PantryItem(id: 4,
                                   name: "Test Item 4 - Modified",
                                   category: "Cat 2",
                                   location: "Loc 1",
                                   currentQuantity: 10,
                                   units: "Units", note: "",
                                   lastUpdate: Date())
    
    //Initialize Change logs
    var testChangeLog1: [PantryChangeKey] = []
    var testChangeLog2: [PantryChangeKey] = []
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        //testProfile.pantry = [testItem1, testItem2, testItem3, testItem4]
        
        //Fill the change logs
        
        //Contains only 4 insertions
        testChangeLog1 = [PantryChangeKey(time: Date(), changeType: .insert,
                                              newObject: testItem1, oldObject: testItem1),
                              PantryChangeKey(time: Date(), changeType: .insert,
                                              newObject: testItem2, oldObject: testItem2),
                              PantryChangeKey(time: Date(), changeType: .insert,
                                              newObject: testItem3, oldObject: testItem3),
                              PantryChangeKey(time: Date(), changeType: .insert,
                                              newObject: testItem4, oldObject: testItem4)]
        
        //Contains the 4 insertions and a modify and deletion
        testChangeLog2 = [PantryChangeKey(time: Date(), changeType: .insert,
                                              newObject: testItem1, oldObject: testItem1),
                              PantryChangeKey(time: Date(), changeType: .insert,
                                              newObject: testItem2, oldObject: testItem2),
                              PantryChangeKey(time: Date(), changeType: .insert,
                                              newObject: testItem3, oldObject: testItem3),
                              PantryChangeKey(time: Date(), changeType: .insert,
                                              newObject: testItem4, oldObject: testItem4),
                              PantryChangeKey(time: Date(), changeType: .modify,
                                              newObject: testItem1_mod, oldObject: testItem1),
                              PantryChangeKey(time: Date(), changeType: .delete,
                                              newObject: testItem3, oldObject: testItem3)]
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testRebuildData_insertsOnly() throws {
        testProfile.pantryChangeLog = testChangeLog1
        //testProfile.pantry = [testItem1, testItem2, testItem3, testItem4]
        
        //Create input
        let input = ProfileModelController().rebuildData(profile: testProfile)
        
        //Create expected output
        var expectedOutput = Profile(name: "Test Profile",
                                     pantry: [testItem1, testItem2, testItem3, testItem4],
                                     shoppingList: [],
                                     categories: ["Cat 1", "Cat 2"],
                                     locations: ["Loc 1", "Loc 2"],
                                     units: ["Units"])
        expectedOutput.pantryChangeLog = testChangeLog1
        
        //Compare if equal
        XCTAssertTrue(input.isExactMatch(item1: input, item2: expectedOutput))
    }

    func testRebuildData_modAndDelete() throws {
        testProfile.pantryChangeLog = testChangeLog2
        //testProfile.pantry = [testItem1, testItem2, testItem3, testItem4]
        
        let input = ProfileModelController().rebuildData(profile: testProfile)
        
        var expectedOutput = Profile(name: "Test Profile",
                                     pantry: [testItem1_mod, testItem2, testItem4],
                                     shoppingList: [],
                                     categories: ["Cat 1", "Cat 2"],
                                     locations: ["Loc 1", "Loc 2"],
                                     units: ["Units"])
        expectedOutput.pantryChangeLog = testChangeLog2
        
        XCTAssertTrue(input.isExactMatch(item1: input, item2: expectedOutput))
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
