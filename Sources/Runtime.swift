// 
// Copyright (c) moaparts.
// All rights reserved.
//

import Foundation
import ObjectiveC

typealias PropertyType = objc_property_t
typealias ObjectPointerType = objc_objectptr_t
public typealias IvarLayout = String

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
    
    internal static func property(_ clazz: AnyClass, _ propertyName: String) -> PropertyType? {
        return class_getProperty(clazz, UnsafeMutablePointer<Int8>(mutating: propertyName))
    }
    
    internal static func properties(_ clazz: AnyClass) -> [PropertyType] {
        var count: UInt32 = 0
        let ret = class_copyPropertyList(clazz, &count)
        return (0 ..< Int(count)).flatMap({ (idx: Int) in
            ret?[idx]
        })
    }
    
    public static func iVarLayout(_ clazz: AnyClass?) -> IvarLayout? {
        guard let layout = class_getIvarLayout(clazz) else {
            return nil
        }
        return .init(cString: layout)
    }
    
    public static func weakIVarLayout(_ clazz: AnyClass?) -> IvarLayout? {
        guard let layout = class_getWeakIvarLayout(clazz) else {
            return nil
        }
        return .init(cString: layout)
    }
    
    internal static func addInstanceMethod(_ clazz: AnyClass, _ selector: Selector, _ imp: IMP) -> Bool {
        guard let method = instanceMethod(clazz, selector) else {
            return false
        }
        return class_addMethod(clazz, selector, imp, method_getTypeEncoding(method))
    }
    
    internal static func addClassMethod(_ clazz: AnyClass, _ selector: Selector, _ imp: IMP) -> Bool {
        guard let method = classMethod(clazz, selector) else {
            return false
        }
        return class_addMethod(clazz, selector, imp, method_getTypeEncoding(method))
    }
    
    /**
     * Replaces the implementation of a method for a given class.
     *
     * @param cls The class you want to modify.
     * @param name A selector that identifies the method whose implementation you want to replace.
     * @param imp The new implementation for the method identified by name for the class identified by cls.
     * @param types An array of characters that describe the types of the arguments to the method.
     *  Since the function must take at least two arguments—self and _cmd, the second and third characters
     *  must be “@:” (the first character is the return type).
     *
     * @return The previous implementation of the method identified by \e name for the class identified by \e cls.
     *
     * @note This function behaves in two different ways:
     *  - If the method identified by \e name does not yet exist, it is added as if \c class_addMethod were called.
     *    The type encoding specified by \e types is used as given.
     *  - If the method identified by \e name does exist, its \c IMP is replaced as if \c method_setImplementation were called.
     *    The type encoding specified by \e types is ignored.
     */
//    @available(iOS 2.0, *)
//    public func class_replaceMethod(_ cls: Swift.AnyClass?, _ name: Selector, _ imp: IMP, _ types: UnsafePointer<Int8>?) -> IMP?
    
    /**
     * Adds a new instance variable to a class.
     *
     * @return YES if the instance variable was added successfully, otherwise NO
     *         (for example, the class already contains an instance variable with that name).
     *
     * @note This function may only be called after objc_allocateClassPair and before objc_registerClassPair.
     *       Adding an instance variable to an existing class is not supported.
     * @note The class must not be a metaclass. Adding an instance variable to a metaclass is not supported.
     * @note The instance variable's minimum alignment in bytes is 1<<align. The minimum alignment of an instance
     *       variable depends on the ivar's type and the machine architecture.
     *       For variables of any pointer type, pass log2(sizeof(pointer_type)).
     */
//    @available(iOS 2.0, *)
//    public func class_addIvar(_ cls: Swift.AnyClass?, _ name: UnsafePointer<Int8>, _ size: Int, _ alignment: UInt8, _ types: UnsafePointer<Int8>?) -> Bool
    
    public static func addProtocol(_ clazz: AnyClass, to aProtocol: Protocol) -> Bool {
        return class_addProtocol(clazz, aProtocol)
    }
    
    /**
     * Adds a property to a class.
     *
     * @param cls The class to modify.
     * @param name The name of the property.
     * @param attributes An array of property attributes.
     * @param attributeCount The number of attributes in \e attributes.
     *
     * @return \c YES if the property was added successfully, otherwise \c NO
     *  (for example, the class already has that property).
     */
//    @available(iOS 4.3, *)
//    public func class_addProperty(_ cls: Swift.AnyClass?, _ name: UnsafePointer<Int8>, _ attributes: UnsafePointer<objc_property_attribute_t>?, _ attributeCount: UInt32) -> Bool
    
    /**
     * Replace a property of a class.
     *
     * @param cls The class to modify.
     * @param name The name of the property.
     * @param attributes An array of property attributes.
     * @param attributeCount The number of attributes in \e attributes.
     */
//    @available(iOS 4.3, *)
//    public func class_replaceProperty(_ cls: Swift.AnyClass?, _ name: UnsafePointer<Int8>, _ attributes: UnsafePointer<objc_property_attribute_t>?, _ attributeCount: UInt32)
    
    /**
     * Sets the Ivar layout for a given class.
     *
     * @param cls The class to modify.
     * @param layout The layout of the \c Ivars for \e cls.
     */
//    @available(iOS 2.0, *)
//    public func class_setIvarLayout(_ cls: Swift.AnyClass?, _ layout: UnsafePointer<UInt8>?)
    
    /**
     * Sets the layout for weak Ivars for a given class.
     *
     * @param cls The class to modify.
     * @param layout The layout of the weak Ivars for \e cls.
     */
//    @available(iOS 2.0, *)
//    public func class_setWeakIvarLayout(_ cls: Swift.AnyClass?, _ layout: UnsafePointer<UInt8>?)
    
    /**
     * Used by CoreFoundation's toll-free bridging.
     * Return the id of the named class.
     *
     * @return The id of the named class, or an uninitialized class
     *  structure that will be used for the class when and if it does
     *  get loaded.
     *
     * @warning Do not call this function yourself.
     */
    
    /* Instantiating Classes */
    
    /**
     * Creates an instance of a class, allocating memory for the class in the
     * default malloc memory zone.
     *
     * @param cls The class that you wish to allocate an instance of.
     * @param extraBytes An integer indicating the number of extra bytes to allocate.
     *  The additional bytes can be used to store additional instance variables beyond
     *  those defined in the class definition.
     *
     * @return An instance of the class \e cls.
     */
//    @available(iOS 2.0, *)
//    public func class_createInstance(_ cls: Swift.AnyClass?, _ extraBytes: Int) -> Any?
    
    /**
     * Creates an instance of a class at the specific location provided.
     *
     * @param cls The class that you wish to allocate an instance of.
     * @param bytes The location at which to allocate an instance of \e cls.
     *  Must point to at least \c class_getInstanceSize(cls) bytes of well-aligned,
     *  zero-filled memory.
     *
     * @return \e bytes on success, \c nil otherwise. (For example, \e cls or \e bytes
     *  might be \c nil)
     *
     * @see class_createInstance
     */
    
    /**
     * Destroys an instance of a class without freeing memory and removes any
     * associated references this instance might have had.
     *
     * @param obj The class instance to destroy.
     *
     * @return \e obj. Does nothing if \e obj is nil.
     *
     * @note CF and other clients do call this under GC.
     */
    
    /* Adding Classes */
    
    /**
     * Creates a new class and metaclass.
     *
     * @param superclass The class to use as the new class's superclass, or \c Nil to create a new root class.
     * @param name The string to use as the new class's name. The string will be copied.
     * @param extraBytes The number of bytes to allocate for indexed ivars at the end of
     *  the class and metaclass objects. This should usually be \c 0.
     *
     * @return The new class, or Nil if the class could not be created (for example, the desired name is already in use).
     *
     * @note You can get a pointer to the new metaclass by calling \c object_getClass(newClass).
     * @note To create a new class, start by calling \c objc_allocateClassPair.
     *  Then set the class's attributes with functions like \c class_addMethod and \c class_addIvar.
     *  When you are done building the class, call \c objc_registerClassPair. The new class is now ready for use.
     * @note Instance methods and instance variables should be added to the class itself.
     *  Class methods should be added to the metaclass.
     */
//    @available(iOS 2.0, *)
//    public func objc_allocateClassPair(_ superclass: Swift.AnyClass?, _ name: UnsafePointer<Int8>, _ extraBytes: Int) -> Swift.AnyClass?
    
    /**
     * Registers a class that was allocated using \c objc_allocateClassPair.
     *
     * @param cls The class you want to register.
     */
//    @available(iOS 2.0, *)
//    public func objc_registerClassPair(_ cls: Swift.AnyClass)
    
    /**
     * Used by Foundation's Key-Value Observing.
     *
     * @warning Do not call this function yourself.
     */
//    @available(iOS 2.0, *)
//    public func objc_duplicateClass(_ original: Swift.AnyClass, _ name: UnsafePointer<Int8>, _ extraBytes: Int) -> Swift.AnyClass
    
    /**
     * Destroy a class and its associated metaclass.
     *
     * @param cls The class to be destroyed. It must have been allocated with
     *  \c objc_allocateClassPair
     *
     * @warning Do not call if instances of this class or a subclass exist.
     */
//    @available(iOS 2.0, *)
//    public func objc_disposeClassPair(_ cls: Swift.AnyClass)
    
    /* Working with Methods */
    
    /**
     * Returns the name of a method.
     *
     * @param m The method to inspect.
     *
     * @return A pointer of type SEL.
     *
     * @note To get the method name as a C string, call \c sel_getName(method_getName(method)).
     */
//    @available(iOS 2.0, *)
//    public func method_getName(_ m: Method) -> Selector
    
    /**
     * Returns the implementation of a method.
     *
     * @param m The method to inspect.
     *
     * @return A function pointer of type IMP.
     */
//    @available(iOS 2.0, *)
//    public func method_getImplementation(_ m: Method) -> IMP
    
    /**
     * Returns a string describing a method's parameter and return types.
     *
     * @param m The method to inspect.
     *
     * @return A C string. The string may be \c NULL.
     */
//    @available(iOS 2.0, *)
//    public func method_getTypeEncoding(_ m: Method) -> UnsafePointer<Int8>?
    
    /**
     * Returns the number of arguments accepted by a method.
     *
     * @param m A pointer to a \c Method data structure. Pass the method in question.
     *
     * @return An integer containing the number of arguments accepted by the given method.
     */
//    @available(iOS 2.0, *)
//    public func method_getNumberOfArguments(_ m: Method) -> UInt32
    
    /**
     * Returns a string describing a method's return type.
     *
     * @param m The method to inspect.
     *
     * @return A C string describing the return type. You must free the string with \c free().
     */
//    @available(iOS 2.0, *)
//    public func method_copyReturnType(_ m: Method) -> UnsafeMutablePointer<Int8>
    
    /**
     * Returns a string describing a single parameter type of a method.
     *
     * @param m The method to inspect.
     * @param index The index of the parameter to inspect.
     *
     * @return A C string describing the type of the parameter at index \e index, or \c NULL
     *  if method has no parameter index \e index. You must free the string with \c free().
     */
//    @available(iOS 2.0, *)
//    public func method_copyArgumentType(_ m: Method, _ index: UInt32) -> UnsafeMutablePointer<Int8>?
    
    /**
     * Returns by reference a string describing a method's return type.
     *
     * @param m The method you want to inquire about.
     * @param dst The reference string to store the description.
     * @param dst_len The maximum number of characters that can be stored in \e dst.
     *
     * @note The method's return type string is copied to \e dst.
     *  \e dst is filled as if \c strncpy(dst, parameter_type, dst_len) were called.
     */
//    @available(iOS 2.0, *)
//    public func method_getReturnType(_ m: Method, _ dst: UnsafeMutablePointer<Int8>, _ dst_len: Int)
    
    /**
     * Returns by reference a string describing a single parameter type of a method.
     *
     * @param m The method you want to inquire about.
     * @param index The index of the parameter you want to inquire about.
     * @param dst The reference string to store the description.
     * @param dst_len The maximum number of characters that can be stored in \e dst.
     *
     * @note The parameter type string is copied to \e dst. \e dst is filled as if \c strncpy(dst, parameter_type, dst_len)
     *  were called. If the method contains no parameter with that index, \e dst is filled as
     *  if \c strncpy(dst, "", dst_len) were called.
     */
//    @available(iOS 2.0, *)
//    public func method_getArgumentType(_ m: Method, _ index: UInt32, _ dst: UnsafeMutablePointer<Int8>?, _ dst_len: Int)
    
//    @available(iOS 2.0, *)
//    public func method_getDescription(_ m: Method) -> UnsafeMutablePointer<objc_method_description>
    
    /**
     * Sets the implementation of a method.
     *
     * @param m The method for which to set an implementation.
     * @param imp The implemention to set to this method.
     *
     * @return The previous implementation of the method.
     */
//    @available(iOS 2.0, *)
//    public func method_setImplementation(_ m: Method, _ imp: IMP) -> IMP
    
    /**
     * Exchanges the implementations of two methods.
     *
     * @param m1 Method to exchange with second method.
     * @param m2 Method to exchange with first method.
     *
     * @note This is an atomic version of the following:
     *  \code
     *  IMP imp1 = method_getImplementation(m1);
     *  IMP imp2 = method_getImplementation(m2);
     *  method_setImplementation(m1, imp2);
     *  method_setImplementation(m2, imp1);
     *  \endcode
     */
//    @available(iOS 2.0, *)
//    public func method_exchangeImplementations(_ m1: Method, _ m2: Method)
    
    /* Working with Instance Variables */
    
    /**
     * Returns the name of an instance variable.
     *
     * @param v The instance variable you want to enquire about.
     *
     * @return A C string containing the instance variable's name.
     */
//    @available(iOS 2.0, *)
//    public func ivar_getName(_ v: Ivar) -> UnsafePointer<Int8>?
    
    /**
     * Returns the type string of an instance variable.
     *
     * @param v The instance variable you want to enquire about.
     *
     * @return A C string containing the instance variable's type encoding.
     *
     * @note For possible values, see Objective-C Runtime Programming Guide > Type Encodings.
     */
//    @available(iOS 2.0, *)
//    public func ivar_getTypeEncoding(_ v: Ivar) -> UnsafePointer<Int8>?
    
    /**
     * Returns the offset of an instance variable.
     *
     * @param v The instance variable you want to enquire about.
     *
     * @return The offset of \e v.
     *
     * @note For instance variables of type \c id or other object types, call \c object_getIvar
     *  and \c object_setIvar instead of using this offset to access the instance variable data directly.
     */
//    @available(iOS 2.0, *)
//    public func ivar_getOffset(_ v: Ivar) -> Int
    
    /* Working with Properties */
    
    /**
     * Returns the name of a property.
     *
     * @param property The property you want to inquire about.
     *
     * @return A C string containing the property's name.
     */
//    @available(iOS 2.0, *)
//    public func property_getName(_ property: objc_property_t) -> UnsafePointer<Int8>
    
    /**
     * Returns the attribute string of a property.
     *
     * @param property A property.
     *
     * @return A C string containing the property's attributes.
     *
     * @note The format of the attribute string is described in Declared Properties in Objective-C Runtime Programming Guide.
     */
//    @available(iOS 2.0, *)
//    public func property_getAttributes(_ property: objc_property_t) -> UnsafePointer<Int8>?
    
    /**
     * Returns an array of property attributes for a property.
     *
     * @param property The property whose attributes you want copied.
     * @param outCount The number of attributes returned in the array.
     *
     * @return An array of property attributes; must be free'd() by the caller.
     */
//    @available(iOS 4.3, *)
//    public func property_copyAttributeList(_ property: objc_property_t, _ outCount: UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<objc_property_attribute_t>?
    
    /**
     * Returns the value of a property attribute given the attribute name.
     *
     * @param property The property whose attribute value you are interested in.
     * @param attributeName C string representing the attribute name.
     *
     * @return The value string of the attribute \e attributeName if it exists in
     *  \e property, \c nil otherwise.
     */
//    @available(iOS 4.3, *)
//    public func property_copyAttributeValue(_ property: objc_property_t, _ attributeName: UnsafePointer<Int8>) -> UnsafeMutablePointer<Int8>?
    
    /* Working with Protocols */
    
    /**
     * Returns a specified protocol.
     *
     * @param name The name of a protocol.
     *
     * @return The protocol named \e name, or \c NULL if no protocol named \e name could be found.
     *
     * @note This function acquires the runtime lock.
     */
//    @available(iOS 2.0, *)
//    public func objc_getProtocol(_ name: UnsafePointer<Int8>) -> Protocol?
    
    /**
     * Returns an array of all the protocols known to the runtime.
     *
     * @param outCount Upon return, contains the number of protocols in the returned array.
     *
     * @return A C array of all the protocols known to the runtime. The array contains \c *outCount
     *  pointers followed by a \c NULL terminator. You must free the list with \c free().
     *
     * @note This function acquires the runtime lock.
     */
//    @available(iOS 2.0, *)
//    public func objc_copyProtocolList(_ outCount: UnsafeMutablePointer<UInt32>?) -> AutoreleasingUnsafeMutablePointer<Protocol>?
    
    /**
     * Returns a Boolean value that indicates whether two protocols are equal.
     *
     * @param proto A protocol.
     * @param other A protocol.
     *
     * @return \c YES if \e proto is the same as \e other, otherwise \c NO.
     */
//    @available(iOS 2.0, *)
//    public func protocol_isEqual(_ proto: Protocol?, _ other: Protocol?) -> Bool
    
    /**
     * Returns the name of a protocol.
     *
     * @param p A protocol.
     *
     * @return The name of the protocol \e p as a C string.
     */
//    @available(iOS 2.0, *)
//    public func protocol_getName(_ proto: Protocol) -> UnsafePointer<Int8>
    
    /**
     * Returns a method description structure for a specified method of a given protocol.
     *
     * @param p A protocol.
     * @param aSel A selector.
     * @param isRequiredMethod A Boolean value that indicates whether aSel is a required method.
     * @param isInstanceMethod A Boolean value that indicates whether aSel is an instance method.
     *
     * @return An \c objc_method_description structure that describes the method specified by \e aSel,
     *  \e isRequiredMethod, and \e isInstanceMethod for the protocol \e p.
     *  If the protocol does not contain the specified method, returns an \c objc_method_description structure
     *  with the value \c {NULL, \c NULL}.
     *
     * @note This function recursively searches any protocols that this protocol conforms to.
     */
//    @available(iOS 2.0, *)
//    public func protocol_getMethodDescription(_ proto: Protocol, _ aSel: Selector, _ isRequiredMethod: Bool, _ isInstanceMethod: Bool) -> objc_method_description
    
    /**
     * Returns an array of method descriptions of methods meeting a given specification for a given protocol.
     *
     * @param p A protocol.
     * @param isRequiredMethod A Boolean value that indicates whether returned methods should
     *  be required methods (pass YES to specify required methods).
     * @param isInstanceMethod A Boolean value that indicates whether returned methods should
     *  be instance methods (pass YES to specify instance methods).
     * @param outCount Upon return, contains the number of method description structures in the returned array.
     *
     * @return A C array of \c objc_method_description structures containing the names and types of \e p's methods
     *  specified by \e isRequiredMethod and \e isInstanceMethod. The array contains \c *outCount pointers followed
     *  by a \c NULL terminator. You must free the list with \c free().
     *  If the protocol declares no methods that meet the specification, \c NULL is returned and \c *outCount is 0.
     *
     * @note Methods in other protocols adopted by this protocol are not included.
     */
//    @available(iOS 2.0, *)
//    public func protocol_copyMethodDescriptionList(_ proto: Protocol, _ isRequiredMethod: Bool, _ isInstanceMethod: Bool, _ outCount: UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<objc_method_description>?
    
    /**
     * Returns the specified property of a given protocol.
     *
     * @param proto A protocol.
     * @param name The name of a property.
     * @param isRequiredProperty \c YES searches for a required property, \c NO searches for an optional property.
     * @param isInstanceProperty \c YES searches for an instance property, \c NO searches for a class property.
     *
     * @return The property specified by \e name, \e isRequiredProperty, and \e isInstanceProperty for \e proto,
     *  or \c NULL if none of \e proto's properties meets the specification.
     */
//    @available(iOS 2.0, *)
//    public func protocol_getProperty(_ proto: Protocol, _ name: UnsafePointer<Int8>, _ isRequiredProperty: Bool, _ isInstanceProperty: Bool) -> objc_property_t?
    
    /**
     * Returns an array of the required instance properties declared by a protocol.
     *
     * @note Identical to
     * \code
     * protocol_copyPropertyList2(proto, outCount, YES, YES);
     * \endcode
     */
//    @available(iOS 2.0, *)
//    public func protocol_copyPropertyList(_ proto: Protocol, _ outCount: UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<objc_property_t>?
    
    /**
     * Returns an array of properties declared by a protocol.
     *
     * @param proto A protocol.
     * @param outCount Upon return, contains the number of elements in the returned array.
     * @param isRequiredProperty \c YES returns required properties, \c NO returns optional properties.
     * @param isInstanceProperty \c YES returns instance properties, \c NO returns class properties.
     *
     * @return A C array of pointers of type \c objc_property_t describing the properties declared by \e proto.
     *  Any properties declared by other protocols adopted by this protocol are not included. The array contains
     *  \c *outCount pointers followed by a \c NULL terminator. You must free the array with \c free().
     *  If the protocol declares no matching properties, \c NULL is returned and \c *outCount is \c 0.
     */
//    @available(iOS 10.0, *)
//    public func protocol_copyPropertyList2(_ proto: Protocol, _ outCount: UnsafeMutablePointer<UInt32>?, _ isRequiredProperty: Bool, _ isInstanceProperty: Bool) -> UnsafeMutablePointer<objc_property_t>?
    
    /**
     * Returns an array of the protocols adopted by a protocol.
     *
     * @param proto A protocol.
     * @param outCount Upon return, contains the number of elements in the returned array.
     *
     * @return A C array of protocols adopted by \e proto. The array contains \e *outCount pointers
     *  followed by a \c NULL terminator. You must free the array with \c free().
     *  If the protocol declares no properties, \c NULL is returned and \c *outCount is \c 0.
     */
//    @available(iOS 2.0, *)
//    public func protocol_copyProtocolList(_ proto: Protocol, _ outCount: UnsafeMutablePointer<UInt32>?) -> AutoreleasingUnsafeMutablePointer<Protocol>?
    
    /**
     * Creates a new protocol instance that cannot be used until registered with
     * \c objc_registerProtocol()
     *
     * @param name The name of the protocol to create.
     *
     * @return The Protocol instance on success, \c nil if a protocol
     *  with the same name already exists.
     * @note There is no dispose method for this.
     */
//    @available(iOS 4.3, *)
//    public func objc_allocateProtocol(_ name: UnsafePointer<Int8>) -> Protocol?
    
    /**
     * Registers a newly constructed protocol with the runtime. The protocol
     * will be ready for use and is immutable after this.
     *
     * @param proto The protocol you want to register.
     */
//    @available(iOS 4.3, *)
//    public func objc_registerProtocol(_ proto: Protocol)
    
    /**
     * Adds a method to a protocol. The protocol must be under construction.
     *
     * @param proto The protocol to add a method to.
     * @param name The name of the method to add.
     * @param types A C string that represents the method signature.
     * @param isRequiredMethod YES if the method is not an optional method.
     * @param isInstanceMethod YES if the method is an instance method.
     */
//    @available(iOS 4.3, *)
//    public func protocol_addMethodDescription(_ proto: Protocol, _ name: Selector, _ types: UnsafePointer<Int8>?, _ isRequiredMethod: Bool, _ isInstanceMethod: Bool)
    
    /**
     * Adds an incorporated protocol to another protocol. The protocol being
     * added to must still be under construction, while the additional protocol
     * must be already constructed.
     *
     * @param proto The protocol you want to add to, it must be under construction.
     * @param addition The protocol you want to incorporate into \e proto, it must be registered.
     */
//    @available(iOS 4.3, *)
//    public func protocol_addProtocol(_ proto: Protocol, _ addition: Protocol)
    
    /**
     * Adds a property to a protocol. The protocol must be under construction.
     *
     * @param proto The protocol to add a property to.
     * @param name The name of the property.
     * @param attributes An array of property attributes.
     * @param attributeCount The number of attributes in \e attributes.
     * @param isRequiredProperty YES if the property (accessor methods) is not optional.
     * @param isInstanceProperty YES if the property (accessor methods) are instance methods.
     *  This is the only case allowed fo a property, as a result, setting this to NO will
     *  not add the property to the protocol at all.
     */
//    @available(iOS 4.3, *)
//    public func protocol_addProperty(_ proto: Protocol, _ name: UnsafePointer<Int8>, _ attributes: UnsafePointer<objc_property_attribute_t>?, _ attributeCount: UInt32, _ isRequiredProperty: Bool, _ isInstanceProperty: Bool)
    
    /* Working with Libraries */
    
    /**
     * Returns the names of all the loaded Objective-C frameworks and dynamic
     * libraries.
     *
     * @param outCount The number of names returned.
     *
     * @return An array of C strings of names. Must be free()'d by caller.
     */
//    @available(iOS 2.0, *)
//    public func objc_copyImageNames(_ outCount: UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<UnsafePointer<Int8>>
    
    /**
     * Returns the dynamic library name a class originated from.
     *
     * @param cls The class you are inquiring about.
     *
     * @return The name of the library containing this class.
     */
//    @available(iOS 2.0, *)
//    public func class_getImageName(_ cls: Swift.AnyClass?) -> UnsafePointer<Int8>?
    
    /**
     * Returns the names of all the classes within a library.
     *
     * @param image The library or framework you are inquiring about.
     * @param outCount The number of class names returned.
     *
     * @return An array of C strings representing the class names.
     */
//    @available(iOS 2.0, *)
//    public func objc_copyClassNamesForImage(_ image: UnsafePointer<Int8>, _ outCount: UnsafeMutablePointer<UInt32>?) -> UnsafeMutablePointer<UnsafePointer<Int8>>?
    
    /* Working with Selectors */
    
    /**
     * Returns the name of the method specified by a given selector.
     *
     * @param sel A pointer of type \c SEL. Pass the selector whose name you wish to determine.
     *
     * @return A C string indicating the name of the selector.
     */
//    @available(iOS 2.0, *)
//    public func sel_getName(_ sel: Selector) -> UnsafePointer<Int8>
    
    /**
     * Registers a method with the Objective-C runtime system, maps the method
     * name to a selector, and returns the selector value.
     *
     * @param str A pointer to a C string. Pass the name of the method you wish to register.
     *
     * @return A pointer of type SEL specifying the selector for the named method.
     *
     * @note You must register a method name with the Objective-C runtime system to obtain the
     *  method’s selector before you can add the method to a class definition. If the method name
     *  has already been registered, this function simply returns the selector.
     */
//    @available(iOS 2.0, *)
//    public func sel_registerName(_ str: UnsafePointer<Int8>) -> Selector
    
    /**
     * Returns a Boolean value that indicates whether two selectors are equal.
     *
     * @param lhs The selector to compare with rhs.
     * @param rhs The selector to compare with lhs.
     *
     * @return \c YES if \e lhs and \e rhs are equal, otherwise \c NO.
     *
     * @note sel_isEqual is equivalent to ==.
     */
//    @available(iOS 2.0, *)
//    public func sel_isEqual(_ lhs: Selector, _ rhs: Selector) -> Bool
    
    /* Objective-C Language Features */
    
    /**
     * This function is inserted by the compiler when a mutation
     * is detected during a foreach iteration. It gets called
     * when a mutation occurs, and the enumerationMutationHandler
     * is enacted if it is set up. A fatal error occurs if a handler is not set up.
     *
     * @param obj The object being mutated.
     *
     */
//    @available(iOS 2.0, *)
//    public func objc_enumerationMutation(_ obj: Any)
    
    /**
     * Sets the current mutation handler.
     *
     * @param handler Function pointer to the new mutation handler.
     */
//    @available(iOS 2.0, *)
//    public func objc_setEnumerationMutationHandler(_ handler: (@convention(c) (Any) -> Swift.Void)?)
    
    /**
     * Set the function to be called by objc_msgForward.
     *
     * @param fwd Function to be jumped to by objc_msgForward.
     * @param fwd_stret Function to be jumped to by objc_msgForward_stret.
     *
     * @see message.h::_objc_msgForward
     */
//    @available(iOS 2.0, *)
//    public func objc_setForwardHandler(_ fwd: UnsafeMutableRawPointer, _ fwd_stret: UnsafeMutableRawPointer)
    
    /**
     * Creates a pointer to a function that will call the block
     * when the method is called.
     *
     * @param block The block that implements this method. Its signature should
     *  be: method_return_type ^(id self, method_args...).
     *  The selector is not available as a parameter to this block.
     *  The block is copied with \c Block_copy().
     *
     * @return The IMP that calls this block. Must be disposed of with
     *  \c imp_removeBlock.
     */
//    @available(iOS 4.3, *)
//    public func imp_implementationWithBlock(_ block: Any) -> IMP
    
    /**
     * Return the block associated with an IMP that was created using
     * \c imp_implementationWithBlock.
     *
     * @param anImp The IMP that calls this block.
     *
     * @return The block called by \e anImp.
     */
//    @available(iOS 4.3, *)
//    public func imp_getBlock(_ anImp: IMP) -> Any?
    
    /**
     * Disassociates a block from an IMP that was created using
     * \c imp_implementationWithBlock and releases the copy of the
     * block that was created.
     *
     * @param anImp An IMP that was created using \c imp_implementationWithBlock.
     *
     * @return YES if the block was released successfully, NO otherwise.
     *  (For example, the block might not have been used to create an IMP previously).
     */
//    @available(iOS 4.3, *)
//    public func imp_removeBlock(_ anImp: IMP) -> Bool
    
    /**
     * This loads the object referenced by a weak pointer and returns it, after
     * retaining and autoreleasing the object to ensure that it stays alive
     * long enough for the caller to use it. This function would be used
     * anywhere a __weak variable is used in an expression.
     *
     * @param location The weak pointer address
     *
     * @return The object pointed to by \e location, or \c nil if \e *location is \c nil.
     */
//    @available(iOS 5.0, *)
//    public func objc_loadWeak(_ location: AutoreleasingUnsafeMutablePointer<AnyObject?>) -> Any?
    
    /**
     * This function stores a new value into a __weak variable. It would
     * be used anywhere a __weak variable is the target of an assignment.
     *
     * @param location The address of the weak pointer itself
     * @param obj The new object this weak ptr should now point to
     *
     * @return The value stored into \e location, i.e. \e obj
     */
//    @available(iOS 5.0, *)
//    public func objc_storeWeak(_ location: AutoreleasingUnsafeMutablePointer<AnyObject?>, _ obj: Any?) -> Any?
    
    /* Associative References */
    
    /**
     * Policies related to associative references.
     * These are options to objc_setAssociatedObject()
     */
//    public enum objc_AssociationPolicy : UInt {
//
//
//        /**< Specifies a weak reference to the associated object. */
//        case OBJC_ASSOCIATION_ASSIGN
//
//        /**< Specifies a strong reference to the associated object.
//         *   The association is not made atomically. */
//        case OBJC_ASSOCIATION_RETAIN_NONATOMIC
//
//
//        /**< Specifies that the associated object is copied.
//         *   The association is not made atomically. */
//        case OBJC_ASSOCIATION_COPY_NONATOMIC
//
//
//        /**< Specifies a strong reference to the associated object.
//         *   The association is made atomically. */
//        case OBJC_ASSOCIATION_RETAIN
//
//
//        /**< Specifies that the associated object is copied.
//         *   The association is made atomically. */
//        case OBJC_ASSOCIATION_COPY
//    }
    
    /**
     * Sets an associated value for a given object using a given key and association policy.
     *
     * @param object The source object for the association.
     * @param key The key for the association.
     * @param value The value to associate with the key key for object. Pass nil to clear an existing association.
     * @param policy The policy for the association. For possible values, see “Associative Object Behaviors.”
     *
     * @see objc_setAssociatedObject
     * @see objc_removeAssociatedObjects
     */
//    @available(iOS 3.1, *)
//    public func objc_setAssociatedObject(_ object: Any, _ key: UnsafeRawPointer, _ value: Any?, _ policy: objc_AssociationPolicy)
    
    /**
     * Returns the value associated with a given object for a given key.
     *
     * @param object The source object for the association.
     * @param key The key for the association.
     *
     * @return The value associated with the key \e key for \e object.
     *
     * @see objc_setAssociatedObject
     */
//    @available(iOS 3.1, *)
//    public func objc_getAssociatedObject(_ object: Any, _ key: UnsafeRawPointer) -> Any?
    
    /**
     * Removes all associations for a given object.
     *
     * @param object An object that maintains associated objects.
     *
     * @note The main purpose of this function is to make it easy to return an object
     *  to a "pristine state”. You should not use this function for general removal of
     *  associations from objects, since it also removes associations that other clients
     *  may have added to the object. Typically you should use \c objc_setAssociatedObject
     *  with a nil value to clear an association.
     *
     * @see objc_setAssociatedObject
     * @see objc_getAssociatedObject
     */
//    @available(iOS 3.1, *)
//    public func objc_removeAssociatedObjects(_ object: Any)
//
//    public var OBSOLETE_OBJC_GETCLASSES: Int32 { get }
//
//    public var OBJC_NEXT_METHOD_LIST: Int32 { get }
}
