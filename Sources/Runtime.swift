// 
// Copyright (c) moaparts.
// All rights reserved.
//

import Foundation
import ObjectiveC

typealias ObjCPropertyType = objc_property_t
typealias ObjCObjectPointerType = objc_objectptr_t
typealias ObjCIVarLayout = String

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
        defer {
            free(rawClasses)
        }
        let classesCount = Int(objc_getClassList(AutoreleasingUnsafeMutablePointer(rawClasses), expectedClassCount))
        return (0 ..< classesCount).flatMap({ (idx: Int) in
            guard let clazz: AnyClass = rawClasses[idx], isIncluded(clazz) else {
                return nil
            }
            return clazz
        })
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
    
    internal static func classVariables(_ clazz: AnyClass) -> [Ivar] {
        var count: UInt32 = 0
        let ret = class_copyIvarList(clazz, &count)
        return (0 ..< Int(count)).flatMap({ (idx: Int) in
            ret?[idx]
        })
    }
    
    internal static func instanceMethod(_ clazz: AnyClass, _ selector: Selector) -> Method? {
        return class_getInstanceMethod(clazz, selector)
    }
    
    internal static func classMethod(_ clazz: AnyClass, _ selector: Selector) -> Method? {
        return class_getClassMethod(clazz, selector)
    }
    
    internal static func methodIMP(_ clazz: AnyClass, _ selector: Selector) -> IMP? {
        return class_getMethodImplementation(clazz, selector)
    }
    
    internal static func methods(_ clazz: AnyClass) -> [Method] {
        var count: UInt32 = 0
        let ret = class_copyMethodList(clazz, &count)
        return (0 ..< Int(count)).flatMap({ (idx: Int) in
            ret?[idx]
        })
    }
    
    internal static func protocols(_ clazz: AnyClass) -> [Protocol] {
        var count: UInt32 = 0
        let ret = class_copyProtocolList(clazz, &count)
        return (0 ..< Int(count)).flatMap({ (idx: Int) in
            ret?[idx]
        })
    }
    
    public static func responds(_ clazz: AnyClass, to selector: Selector) -> Bool {
        return class_respondsToSelector(clazz, selector)
    }
    
    public static func conforms(_ clazz: AnyClass, to aProtocol: Protocol) -> Bool {
        return class_conformsToProtocol(clazz, aProtocol)
    }
    
    internal static func property(_ clazz: AnyClass, _ propertyName: String) -> ObjCPropertyType? {
        return class_getProperty(clazz, UnsafeMutablePointer<Int8>(mutating: propertyName))
    }
    
    internal static func properties(_ clazz: AnyClass) -> [ObjCPropertyType] {
        var count: UInt32 = 0
        let ret = class_copyPropertyList(clazz, &count)
        return (0 ..< Int(count)).flatMap({ (idx: Int) in
            ret?[idx]
        })
    }
    
    internal func ivarLayout(_ clazz: AnyClass?) -> ObjCIVarLayout? {
        guard let layout = class_getIvarLayout(clazz) else {
            return nil
        }
        return .init(cString: layout)
    }
    
    internal func weakIVarLayout(_ clazz: AnyClass?) -> ObjCIVarLayout? {
        guard let layout = class_getWeakIvarLayout(clazz) else {
            return nil
        }
        return .init(cString: layout)
    }
}
