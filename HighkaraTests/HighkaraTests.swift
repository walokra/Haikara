//
//  HighkaraTests.swift
//  HighkaraTests
//
//  Created by Marko Wallin on 29/04/2017.
//  Copyright © 2017 Rule of tech. All rights reserved.
//

import XCTest
@testable import highkara

class HighkaraTests: XCTestCase {
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCategoriesDepthBiggerThanOne() {
  		// 1. given
//  		var categories = [Category]()
		HighFiApi.getCategories(
			{ (result) in
//				print("result=\(result)")
                // 2. when
				var depth = 0
				result.forEach({ (category: Category) -> () in
//					print("category.depth=\(category.depth)")
					if category.depth > 1 {
						depth = category.depth
					}
				})
				
				// 3. then
				//  XCTAssertEqual(gameUnderTest.scoreRound, 95, "Score computed from guess is wrong")
  				XCTAssertTrue(depth > 1, "Pass")
            }
            , failureHandler: {(error) in
				print("Error \(error)")
            	}
			)
	}
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
