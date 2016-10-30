//
//  SettingsViewController.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import Foundation


// Base Class

public class SettingsBaseViewController: UIViewController {
    
    var tableView: UITableView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.view.frame, style: .grouped)
        self.tableView!.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.reuseIdentifier)
        self.view.addSubview(self.tableView)
    }
    
}


// Main Settings

public protocol SettingsViewControllerDelegate : class {
    func settingsViewController(vc:SettingsViewController, didUpdateSetting id:String)
}

public class SettingsViewController: SettingsBaseViewController, SettingsOptionsViewControllerDelegate {
    
    weak var delegate : SettingsViewControllerDelegate?
    
    private var items : [Setting] = []
    fileprivate var defaultsStore : UserDefaults
    
    public init(settings:[Setting], delegate:SettingsViewControllerDelegate) {
        self.defaultsStore = UserDefaults.standard
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        
        items = settings
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func setting(for section:Int) -> Setting {
        return items[section]
    }
    
    func setting(for id:String) -> Setting? {
        for s in items {
            if let result = s.settingForId(target: id) {
                return result
            }
        }
        return nil
    }
    
    var numberOfGroups : Int {
        return items.count
    }
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
    }
    
}

extension SettingsViewController : UITableViewDelegate {
    
    private func navigateToSelect(options:SettingsOptions, value:String) {
        let optionsVC = SettingsOptionsViewController(options: options,  selected:value, delegate: self)
        optionsVC.view.frame = view.frame
        optionsVC.tableView.frame = view.frame
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = setting(for: indexPath.section)
        switch item {
        case let .Group(_, groupSettings):
            let subSetting = groupSettings[indexPath.row]
            switch subSetting {
            case let .Select(_, key,options):
                let currentValue = subSetting.string(forKey: key, dataSource: self.defaultsStore)
                navigateToSelect(options: options, value:currentValue!)
            default:
                break
            }
        case .Select(_, _, _):
            break
        default:
            break
        }
        
        
    }
}

extension SettingsViewController : UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfGroups
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = setting(for: section)
        switch item {
        case let .Group(name, _):
            return name
        case let .Select(label: label, _, _):
            return label
        default:
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = setting(for: section)
        switch item {
        case let .Group(_, groupSettings):
            return groupSettings.count
        case let .Select(label: _, id: _, options: options):
            return options.options.count
        default:
            return 1
        }
    }
    
    @objc
    func switchValueChanged(s:UISwitch) {
        if let id = s.restorationIdentifier, let _ = setting(for: id) {
            defaultsStore.set(s.isOn, forKey: id)
            delegate?.settingsViewController(vc: self, didUpdateSetting: id)
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
        
        let item = setting(for: indexPath.section)
        
        switch item {
            
        case let .Group(_, groupSettings):
            let subSetting = groupSettings[indexPath.row]
            subSetting.configure(cell: cell, dataSource:self.defaultsStore)
            if let s = cell.accessoryView as? UISwitch {
                s.restorationIdentifier = subSetting.uniqueId
                s.addTarget(self, action: #selector(switchValueChanged(s:)), for: .valueChanged)
            }
            
        case let .Select(_, key, options):
            let options = options.options
            let valueToDisplay = options[indexPath.row]
            cell.textLabel?.text = valueToDisplay
            let currentValue = item.string(forKey: key, dataSource: self.defaultsStore)
            cell.accessoryType = (valueToDisplay == currentValue) ? .checkmark : .none
        default:
            break
        }
        
        return cell
        
    }
    
}

