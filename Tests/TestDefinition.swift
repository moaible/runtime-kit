//
//  TestDefinition.swift
//  RuntimeKitTests
//
//  Created by moaible on 2018/03/07.
//  Copyright © 2018年 moaparts. All rights reserved.
//

import Foundation

class SwiftPureClass {
    class SwiftPureClass {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
    
    struct SwiftPureStruct {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
    
    class NSObjectSubclass: NSObject {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
}

struct SwiftPureStruct {
    class SwiftPureClass {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
    
    struct SwiftPureStruct {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
    
    class NSObjectSubclass: NSObject {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
}

class NSObjectSubclass: NSObject {
    class SwiftPureClass {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
    
    struct SwiftPureStruct {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
    
    class NSObjectSubclass: NSObject {
        class SwiftPureClass {}
        struct SwiftPureStruct {}
        class NSObjectSubclass: NSObject {}
    }
}

protocol SwiftPureProtocol {}
