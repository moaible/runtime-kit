// 
// Copyright (c) moaparts.
// All rights reserved.
//

import Foundation
import ObjectiveC

public struct Runtime {
    
    // MARK : -
    
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
        return objc_getMetaClass(UnsafeMutablePointer<Int8>(mutating: className(clazz))) as? AnyClass
    }
    
    public static func isMetaClass(_ clazz: AnyClass) -> Bool {
        return class_isMetaClass(clazz)
    }
    
    public static func superClass(_ clazz: AnyClass) -> AnyClass? {
        return class_getSuperclass(clazz)
    }
    
    public static func classVersion(_ clazz: AnyClass) -> Int32 {
        return class_getVersion(clazz)
    }
    
    public static func setClassVersion(_ clazz: AnyClass, version: Int32) {
        class_setVersion(clazz, version)
    }
    
    public static func classInstanceSize(_ clazz: AnyClass) -> Int {
        return class_getInstanceSize(clazz)
    }
    
    internal static func instanceVariable(_ clazz: AnyClass, with instanceName: String) -> Ivar? {
        return class_getInstanceVariable(clazz, UnsafeMutablePointer<Int8>(mutating: instanceName))
    }
    
    internal static func classVariable(_ clazz: AnyClass, with instanceName: String) -> Ivar? {
        return class_getClassVariable(clazz, UnsafeMutablePointer<Int8>(mutating: instanceName))
    }
}
