// 
// Copyright (c) moaparts.
// All rights reserved.
//

import Foundation
import ObjectiveC

public struct Runtime {
    
    public static func className(with clazz: AnyClass) -> String {
        return .init(cString: object_getClassName(clazz))
    }
    
    public static func `class`(with clazzName: String) -> AnyClass? {
        return objc_getClass(UnsafeMutablePointer<Int8>(mutating: clazzName)) as? AnyClass
    }
    
    public static func allClass() -> [AnyClass] {
        let expectedClassCount = objc_getClassList(nil, 0)
        let rawClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let classesCount = objc_getClassList(AutoreleasingUnsafeMutablePointer(rawClasses), expectedClassCount)
        var allClazz: [AnyClass] = []
        var clazz: AnyClass?
        for idx in 0..<classesCount {
            clazz = rawClasses[Int(idx)]
            if let clazz = clazz {
                allClazz.append(clazz)
            }
        }
        free(rawClasses)
        return allClazz
    }
}
