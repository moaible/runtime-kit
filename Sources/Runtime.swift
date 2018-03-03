// 
// Copyright (c) moaparts.
// All rights reserved.
//

import Foundation
import ObjectiveC

public struct Runtime {
    
    public static func className(_ clazz: AnyClass) -> String {
        return .init(cString: object_getClassName(clazz))
    }
    
    public static func `class`(_ clazzName: String) -> AnyClass? {
        return objc_getClass(UnsafeMutablePointer<Int8>(mutating: clazzName)) as? AnyClass
    }
    
    public static func allClass(isIncluded: (AnyClass) -> Bool = { _ in true }) -> [AnyClass] {
        let expectedClassCount = objc_getClassList(nil, 0)
        let rawClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let classesCount = Int(objc_getClassList(AutoreleasingUnsafeMutablePointer(rawClasses), expectedClassCount))
        let allClazz: [AnyClass] = (0 ..< classesCount).flatMap({ (idx: Int) in
            guard let clazz: AnyClass = rawClasses[idx], isIncluded(clazz) else {
                return nil
            }
            return clazz
        })
        free(rawClasses)
        return allClazz
    }
    
    public static func metaClass(_ clazz: AnyClass) -> AnyClass? {
        return objc_getMetaClass(UnsafeMutablePointer<Int8>(mutating: self.className(clazz))) as? AnyClass
    }
    
    public static func isMetaClass(_ clazz: AnyClass) -> Bool {
        return class_isMetaClass(clazz)
    }
    
    public static func superClass(_ clazz: AnyClass) -> AnyClass? {
        return class_getSuperclass(clazz)
    }
}
