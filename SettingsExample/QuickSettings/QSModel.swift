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
public func QSInit(settings:[QSSetting], datastore : QSSettingsDataSource) {
    for s in settings { s.initialize(datastore) }
}

/**
 Initializes the dataStore to fill in any missing values with defaults.
 - parameter settings: the settings to be initialized
 - parameter datastore: the conforming datastore to be initialized
 - Warning: DESTRUCTIVE OPERATION -- this will overwrite existing data with defaults
 */
public func QSReset(settings:[QSSetting], datastore : QSSettingsDataSource) {
    for s in settings { s.reset(datastore) }
}

/** 
 Handy function to create a Toggle setting 
 - parameter label: the string to display to the user
 - parameter id: the key used to store/retrieve from the datastore
 - parameter defaultValue: value to be used if none has been set
 - returns: a Setting of type Setting.Toggle
 */
public func QSToggle(label:String, id:String, defaultValue:Bool) -> QSSetting {
    return QSSetting.Toggle(QSToggleSetting(label: label, key: id, defaultValue: defaultValue))
}

/**
 Handy function to create a Slider setting
 - parameter label: the string to display to the user
 - parameter id: the key used to store/retrieve from the datastore
 - parameter min: minimum value for the slider
 - parameter max: maximum value for the slider
 - parameter defaultValue: value to be used if none has been set
 - returns: a Setting of type Setting.Slider
 */
public func QSSlider(label:String, id:String, min:Float, max:Float, defaultValue:Float) -> QSSetting {
    return QSSetting.Slider(QSSliderSetting(label: label, key: id, min: min, max: max, defaultValue: defaultValue))
}

/**
 Handy function to create a Text setting
 - parameter label: the string to display to the user
 - parameter id: the key used to store/retrieve from the datastore
 - parameter defaultValue: value to be used if none has been set
 - returns: a Setting of type Setting.Text
 */
public func QSText(label:String, id:String, defaultValue:String? = nil, type:QSTextSettingType = .text) -> QSSetting {
    return QSSetting.Text(QSTextSetting(label: label, key: id, defaultValue: defaultValue, type:type))
}

/**
 Handy function to create an Info setting
 - parameter label: the info title to display to the user
 - parameter text: the text info to display to the user
 - returns: a Setting of type Setting.Info
 */
public func QSInfo(label:String, text:String) -> QSSetting {
    return QSSetting.Info(QSInfoSetting(label: label, text: text))
}

/**
 Handy function to create a Select setting
 - parameter label: the string to display to the user
 - parameter id: the key used to store/retrieve from the datastore
 - parameter options: an object conforming to SettingsOptions
 - returns: a Setting of type Setting.Select
 */
public func QSSelect(label:String, id:String, options:QSSettingsOptions) -> QSSetting {
    return QSSetting.Select(QSSelectSetting(label: label, key: id, options: options))
}

/**
 Handy function to create a Group setting
 - parameter title: the title of the group to be displayed to the user
 - parameter children: the list of Setting objects to be display in the group
 - parameter footer: a description string displayed underneath the group
 - returns: a Setting of type Setting.Group
 */
public func QSGroup(title:String, children:[QSSetting], footer:String?=nil) -> QSSetting {
    return QSSetting.Group(QSGroupSetting(title: title, children: children, footer:footer))
}

public struct QSInfoSetting {
    let label : String
    let text : String
    
    public init(label:String, text:String) {
        self.label = label
        self.text = text
    }
}

public struct QSToggleSetting {
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
}

public enum QSTextSettingType {
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

public struct QSTextSetting {
    let label : String
    let key : String
    let defaultValue : String?
    let type : QSTextSettingType
    
    public init(label: String, key: String, defaultValue: String?, type:QSTextSettingType = .text) {
        self.label = label
        self.key = key
        self.defaultValue = defaultValue
        self.type = type
    }
    
    internal func value(from dataSource:QSSettingsDataSource) -> String? {
        return dataSource.hasValue(forKey: key) ? dataSource.string(forKey: key) : defaultValue
    }
}

public struct QSSliderSetting {
    let label : String
    let key : String
    let min : Float
    let max : Float
    let defaultValue : Float
    
    public init(label: String, key: String, min:Float, max:Float, defaultValue: Float) {
        self.label = label
        self.key = key
        self.min = min
        self.max = max
        self.defaultValue = defaultValue
    }
}

public struct QSGroupSetting {
    let title : String
    let children : [QSSetting]
    let footer : String?
    
    public init(title: String, children: [QSSetting], footer: String?) {
        self.title = title
        self.children = children
        self.footer = footer
    }
    
    internal func setting(for key:String) -> QSSetting? {
        for c in children {
            if let s = c.settingForId(target: key) {
                return s
            }
        }
        return nil
    }
}

public struct QSSelectSetting {
    let label : String
    let key : String
    let options : QSSettingsOptions
    
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
}

public enum QSSetting {
    
    case Toggle(QSToggleSetting)
    case Slider(QSSliderSetting)
    case Text(QSTextSetting)
    case Select(QSSelectSetting)
    case Info(QSInfoSetting)
    indirect case Group(QSGroupSetting)
    
    internal var uniqueId : String? {
        switch self {
        case let .Toggle(s):
            return s.key
        case let .Slider(s):
            return s.key
        case let .Text(t):
            return t.key
        case let .Select(s):
            return s.key
        default:
            return nil
        }
    }
    
    internal func settingForId(target:String) -> QSSetting? {
        switch self {
        case let .Toggle(s):
            return s.key == target ? self : nil
        case let .Slider(s):
            return s.key == target ? self : nil
        case let .Text(t):
            return t.key == target ? self : nil
        case let .Select(s):
            return s.key == target ? self : nil
        case let .Group(g):
            for c in g.children {
                if let s = c.settingForId(target: target) {
                    return s
                }
            }
            return nil
        case .Info:
            return nil
        }
        
    }
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

extension QSSetting {
    
    internal func reset(_ dataSource:QSSettingsDataSource) {
        switch self {
        case let .Toggle(s):
            dataSource.set(s.defaultValue, forKey: s.key)
        case let .Slider(s):
            dataSource.set(s.defaultValue, forKey: s.key)
        case let .Text(t):
            dataSource.set(t.defaultValue, forKey: t.key)
        case let .Select(s):
            dataSource.set(s.options.defaultValue, forKey: s.key)
        case let .Group(g):
            for c in g.children {
                c.reset(dataSource)
            }
        case .Info: break
        }
    }

    
    internal func initialize(_ dataSource:QSSettingsDataSource) {
        switch self {
        case let .Toggle(s):
            if !dataSource.hasValue(forKey: s.key) { reset(dataSource) }
        case let .Slider(s):
            if !dataSource.hasValue(forKey: s.key) { reset(dataSource) }
        case let .Text(t):
            if !dataSource.hasValue(forKey: t.key) { reset(dataSource) }
        case let .Select(s):
            if !dataSource.hasValue(forKey: s.key) { reset(dataSource) }
        case let .Group(g):
            for c in g.children {
                c.initialize(dataSource)
            }
        case .Info: break
        }
    }
    
}
