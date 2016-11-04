//
//  Model.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import Foundation

/**
 To create a list of option items, create something that conforms to the 
 SettingsOptions protocol. This includes a list of the string options to be
 displayed to the user and a defaultValue if nothing has been selected.
 */
public protocol QSSettingsOptions {
    var options : [String] { get }
    var defaultValue : String { get }
}

/**
 This is a quick wrapper for an enum : String which makes it conform to
 SettingsOptions. This allows a string enumeration to be easily used to display
 a set of options to the user.
*/
public class QSEnumSettingsOptions<T:Hashable> : QSSettingsOptions where T : RawRepresentable, T.RawValue == String {
    
    private let defaultVal : T
    public init(defaultValue:T) {
        self.defaultVal = defaultValue
    }
    
    public var defaultValue: String {
        return defaultVal.rawValue
    }
    
    public var options : [String] {
        return Array(iterateEnum(T.self)).map { $0.rawValue }
    }
}

private func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafePointer(to: &i) {
            $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

// http://nshipster.com/swift-documentation/
// http://useyourloaf.com/blog/swift-documentation-quick-guide/

/**
 Initializes the dataStore to fill in any missing values with defaults.
 - parameter settings: the settings to be initialized
 - parameter datastore: the conforming datastore to be initialized
 - important: THIS WILL NOT OVERWRITE EXISTING VALUES
 */
public func QSInit(settings:[QSSettable], datastore : QSSettingsDataSource) {
    for s in settings { s.initialize(datastore) }
}

/**
 Initializes the dataStore to fill in any missing values with defaults.
 - parameter settings: the settings to be initialized
 - parameter datastore: the conforming datastore to be initialized
 - Warning: DESTRUCTIVE OPERATION -- this will overwrite existing data with defaults
 */
public func QSReset(settings:[QSSettable], datastore : QSSettingsDataSource) {
    for s in settings { s.reset(datastore) }
}

public protocol QSSettable {
    func reset(_ dataSource:QSSettingsDataSource)
    func initialize(_ dataSource:QSSettingsDataSource)
    func settingForId(target:String) -> QSSettable?
    
    var uniqueId : String? { get }
}

public struct QSInfo : QSSettable {
    let label : String
    let text : String
    
    /**
     Handy function to create an Info setting
     - parameter label: the info title to display to the user
     - parameter text: the text info to display to the user
     - returns: a Setting of type QSInfo
     */
    public init(label:String, text:String) {
        self.label = label
        self.text = text
    }
    public func reset(_ dataSource:QSSettingsDataSource) {}
    public func initialize(_ dataSource:QSSettingsDataSource) {}
    public func settingForId(target: String) -> QSSettable? { return nil }
    public var uniqueId: String? { return nil }
}

public struct QSToggle : QSSettable  {
    let label : String
    let key : String
    let defaultValue : Bool
    
    /**
     Create a Toggle setting
     - parameter label: the string to display to the user
     - parameter id: the key used to store/retrieve from the datastore
     - parameter defaultValue: value to be used if none has been set
     - returns: a Setting of type Setting.Toggle
     */
    public init(label: String, key: String, defaultValue: Bool) {
        self.label = label
        self.key = key
        self.defaultValue = defaultValue
    }
    
    internal func value(from dataSource:QSSettingsDataSource) -> Bool {
        return dataSource.hasValue(forKey: key) ? dataSource.bool(forKey: key) : defaultValue
    }
    
    public func reset(_ dataSource:QSSettingsDataSource) {}
    public func initialize(_ dataSource:QSSettingsDataSource) {}
    public func settingForId(target: String) -> QSSettable? { return key == target ? self : nil }
    public var uniqueId: String? { return key }
}

public enum QSTextSettingType  {
    case text
    case name
    case url
    case int
    case phone
    case password
    case email
    case decimal
    
    
    var autocorrection : UITextAutocorrectionType {
        switch self {
        case .text: return .yes
        case .decimal, .email, .int, .name, .password, .phone, .url: return .no
        }
    }
    var autocapitalization : UITextAutocapitalizationType {
        switch self {
        case .text, .decimal, .email, .int, .password, .phone, .url: return .none
        case .name: return .words
        }
    }
    
    var keyboard : UIKeyboardType {
        switch self {
        case .text: return .default
        case .decimal: return .decimalPad
        case .email: return .emailAddress
        case .int: return .numberPad
        case .name: return .namePhonePad
        case .password: return .default
        case .phone: return .phonePad
        case .url: return .URL
        }
    }
    
    var secure : Bool {
        switch self {
        case .password: return true
        case .text, .decimal, .email, .int, .name, .phone, .url: return false
        }
    }
    
}

public struct QSText : QSSettable  {
    let label : String
    let key : String
    let defaultValue : String?
    let type : QSTextSettingType
    
    /**
     Handy function to create a Text setting
     - parameter label: the string to display to the user
     - parameter id: the key used to store/retrieve from the datastore
     - parameter defaultValue: value to be used if none has been set
     - returns: a Setting of type QSText
     */
    public init(label: String, key: String, defaultValue: String?, type:QSTextSettingType = .text) {
        self.label = label
        self.key = key
        self.defaultValue = defaultValue
        self.type = type
    }
    
    internal func value(from dataSource:QSSettingsDataSource) -> String? {
        return dataSource.hasValue(forKey: key) ? dataSource.string(forKey: key) : defaultValue
    }
    
    public func reset(_ dataSource:QSSettingsDataSource) {
        dataSource.set(defaultValue, forKey: key)
    }
    public func initialize(_ dataSource:QSSettingsDataSource) {
        if !dataSource.hasValue(forKey: key) { reset(dataSource) }
    }
    public func settingForId(target: String) -> QSSettable? { return key == target ? self : nil }
    public var uniqueId: String? { return key }
}

public struct QSSlider : QSSettable  {
    let label : String
    let key : String
    let min : Float
    let max : Float
    let defaultValue : Float
    
    /**
     Handy function to create a Slider setting
     - parameter label: the string to display to the user
     - parameter id: the key used to store/retrieve from the datastore
     - parameter min: minimum value for the slider
     - parameter max: maximum value for the slider
     - parameter defaultValue: value to be used if none has been set
     - returns: a Setting of type QSSlider
     */
    public init(label: String, key: String, min:Float, max:Float, defaultValue: Float) {
        self.label = label
        self.key = key
        self.min = min
        self.max = max
        self.defaultValue = defaultValue
    }
    
    public func reset(_ dataSource:QSSettingsDataSource) {
        dataSource.set(defaultValue, forKey: key)
    }
    public func initialize(_ dataSource:QSSettingsDataSource) {
        if !dataSource.hasValue(forKey: key) { reset(dataSource) }
    }
    public func settingForId(target: String) -> QSSettable? { return key == target ? self : nil }
    public var uniqueId: String? { return key }
}

public struct QSGroup : QSSettable  {
    let title : String
    let children : [QSSettable]
    let footer : String?
    
    /**
     Create a Group setting
     - parameter title: the title of the group to be displayed to the user
     - parameter children: the list of Setting objects to be display in the group
     - parameter footer: a description string displayed underneath the group
     - returns: a Setting of type QSGroup
     */
    public init(title: String, children: [QSSettable], footer: String? = nil) {
        self.title = title
        self.children = children
        self.footer = footer
    }
    
    internal func setting(for key:String) -> QSSettable? {
        for c in children {
            if let s = c.settingForId(target: key) {
                return s
            }
        }
        return nil
    }
    
    public func reset(_ dataSource:QSSettingsDataSource) {
        for c in children {
            c.reset(dataSource)
        }
    }
    public func initialize(_ dataSource:QSSettingsDataSource) {
        for c in children {
            c.initialize(dataSource)
        }
    }
    public func settingForId(target: String) -> QSSettable? {
        for c in children {
            if let _ = c.settingForId(target:target) { return c }
        }
        return nil
    }
    public var uniqueId: String? { return nil }
}

public struct QSSelect : QSSettable  {
    let label : String
    let key : String
    let options : QSSettingsOptions
    
    /**
     Create a Select setting
     - parameter label: the string to display to the user
     - parameter id: the key used to store/retrieve from the datastore
     - parameter options: an object conforming to SettingsOptions
     - returns: a Setting of type QSSelect
     */
    public init(label: String, key: String, options:QSSettingsOptions) {
        self.label = label
        self.key = key
        self.options = options
    }
    
    internal func value(from dataSource:QSSettingsDataSource) -> String? {
        if dataSource.hasValue(forKey: key) {
            let proposedValue = dataSource.string(forKey: key)!
            if options.options.contains(proposedValue) {
                return proposedValue
            } else {
                return options.defaultValue
            }
        } else {
            return options.defaultValue
        }
    }
    
    public func reset(_ dataSource:QSSettingsDataSource) {
        dataSource.set(options.defaultValue, forKey: key)
    }
    public func initialize(_ dataSource:QSSettingsDataSource) {
        if !dataSource.hasValue(forKey: key) { reset(dataSource) }
    }
    public func settingForId(target: String) -> QSSettable? { return key == target ? self : nil }
    public var uniqueId: String? { return key }
}

public protocol QSSettingsDataSource {
    
    func bool(forKey:String) -> Bool
    func float(forKey:String) -> Float
    func integer(forKey:String) -> Int
    func string(forKey:String) -> String?
    func hasValue(forKey:String) -> Bool
    
    func set(_ value:Bool, forKey:String)
    func set(_ value:Float, forKey:String)
    func set(_ value:Any?, forKey:String)
}


/**
 Make user defaults conform to the SettingsDataSource protocol
 */
extension UserDefaults : QSSettingsDataSource {
    public func hasValue(forKey key: String) -> Bool {
        if let _ = value(forKey: key) {
            return true
        } else {
            return false
        }
    }
}
