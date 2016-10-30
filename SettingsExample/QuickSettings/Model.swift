//
//  Model.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import Foundation

public protocol SettingsOptions {
    var options : [String] { get }
    var defaultValue : String { get }
}

public class EnumSettingsOptions<T:Hashable> : SettingsOptions where T : RawRepresentable, T.RawValue == String {
    
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

public func quickToggle(label:String, id:String, defaultValue:Bool) -> Setting {
    return Setting.Toggle(label: label, id: id, default: defaultValue)
}

public func quickSlider(label:String, id:String, min:Float, max:Float, defaultValue:Float) -> Setting {
    return Setting.Slider(label: label, id: id, min: min, max: max, default: defaultValue)
}

public func quickText(label:String, id:String, defaultValue:String? = nil) -> Setting {
    return Setting.Text(label: label, id: id, default: defaultValue)
}

public func quickSelect(label:String, id:String, options:SettingsOptions) -> Setting {
    return Setting.Select(label: label, id: id, options: options)
}

public func quickGroup(title:String, children:[Setting], footer:String?=nil) -> Setting {
    return Setting.Group(title: title, children: children)
}

public enum Setting {
    
    case Toggle(label:String, id:String, default:Bool)
    case Slider(label:String, id:String, min:Float, max:Float, default:Float)
    case Text(label:String, id:String, default:String?)
    case Select(label:String, id:String, options:SettingsOptions)
    indirect case Group(title:String, children:[Setting])
    
    var uniqueId : String? {
        switch self {
        case let .Toggle(_, id, _):
            return id
        case let .Slider(_,id,_,_,_):
            return id
        case let .Text(_,id,_):
            return id
        case let .Select(_,id,_):
            return id
        default:
            return nil
        }
    }
    
    func settingForId(target:String) -> Setting? {
        switch self {
        case let .Toggle(_, id, _):
            return id == target ? self : nil
        case let .Slider(_,id,_,_,_):
            return id == target ? self : nil
        case let .Text(_,id,_):
            return id == target ? self : nil
        case let .Select(_,id,_):
            return id == target ? self : nil
        case let .Group(_, children: children):
            for c in children {
                if let s = c.settingForId(target: target) {
                    return s
                }
            }
            return nil
        }
        
    }
    
}

protocol SettingsDataSource {
    
    func bool(forKey:String) -> Bool
    func float(forKey:String) -> Float
    func integer(forKey:String) -> Int
    func string(forKey:String) -> String?
    func hasValue(forKey:String) -> Bool
    
    func set(_ value:Bool, forKey:String)
    func set(_ value:Float, forKey:String)
    func set(_ value:Any?, forKey:String)
}


extension UserDefaults : SettingsDataSource {
    func hasValue(forKey key: String) -> Bool {
        if let _ = value(forKey: key) {
            return true
        } else {
            return false
        }
    }
    
}

extension Setting {
    
    fileprivate func bool(forKey key:String, dataSource:SettingsDataSource) -> Bool {
        switch self {
        case let .Toggle(_,_,defaultValue):
            return dataSource.hasValue(forKey: key) ? dataSource.bool(forKey: key) : defaultValue
        default:
            fatalError()
        }
    }
    fileprivate func float(forKey key:String, dataSource:SettingsDataSource) -> Float {
        switch self {
        case let .Slider(_,_,_,_,defaultValue):
            return dataSource.hasValue(forKey: key) ? dataSource.float(forKey: key) : defaultValue
        default:
            fatalError()
        }
        
    }
    fileprivate func integer(forKey key:String, dataSource:SettingsDataSource) -> Int {
        fatalError()
    }
    
    internal func string(forKey key:String, dataSource:SettingsDataSource) -> String? {
        switch self {
        case let .Text(_,_,defaultValue):
            return dataSource.hasValue(forKey: key) ? dataSource.string(forKey: key) : defaultValue
            
        case let .Select(_, _, settingsOptions):
            if dataSource.hasValue(forKey: key) {
                let proposedValue = dataSource.string(forKey: key)!
                if settingsOptions.options.contains(proposedValue) {
                    return proposedValue
                } else {
                    return settingsOptions.defaultValue
                }
            } else {
                return settingsOptions.defaultValue
            }
            
        default:
            fatalError()
        }
        
    }
    
    
    
    func configure(cell:UITableViewCell, dataSource:SettingsDataSource) {
        switch self {
        case .Group:
            fatalError()
            
        case let .Toggle(label,key,_):
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = nil
            let s = UISwitch()
            s.isOn = bool(forKey: key, dataSource: dataSource)
            cell.accessoryView = s
            
        case let .Text(label,key,_):
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = string(forKey: key, dataSource: dataSource)
            
        case let .Select(label, key, _):
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = string(forKey: key, dataSource: dataSource)
            cell.accessoryType = .disclosureIndicator
            
        case .Slider:
            fatalError()
            
        }
    }
}
