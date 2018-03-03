// 
// Copyright (c) moaparts.
// All rights reserved.
//

import XCTest
@testable import AspectKit

class AspectKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Runtime tests
    
    // MARK: get class name
    
    func testRuntimeClassName() {
        let NSObjectClassName = Runtime.className(with: NSObject.self)
        XCTAssertEqual(NSObjectClassName, "NSObject")
    }
    
    // MARK: get class
    
    func testRuntimeClass_NSObject() {
        guard let NSObjectClassFromRuntime: AnyClass = Runtime.class(with: "NSObject") else {
            fatalError("failed NSObjectClassFromRuntime")
        }
        let NSObjectClass = NSObject.self
        XCTAssertEqual(NSStringFromClass(NSObjectClassFromRuntime), NSStringFromClass(NSObjectClass))
    }
    
    func testRuntimeClass_HogeStruct() {
        
        struct Hoge {}
        
        guard let _: AnyClass = Runtime.class(with: "Hoge") else {
            XCTAssertTrue(true, "not found struct definition from objc runtime")
            return
        }
        XCTFail("should not found struct definition from objc runtime")
    }
    
    // MARK: get all class
    
    func testRuntimeAllClasses() {
        XCTAssertTrue(Runtime.allClass().count > 0)
    }
    
    // MARK: -
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
