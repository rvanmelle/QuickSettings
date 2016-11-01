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
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.reuseIdentifier)
        tableView.register(SettingsTextTableCell.self, forCellReuseIdentifier: SettingsTextTableCell.reuseIdentifier)
        view.addSubview(tableView)
        view.pinItemFillAll(tableView)
    }
    
}


// Main Settings

public protocol SettingsViewControllerDelegate : class {
    func settingsViewController(vc:SettingsViewController, didUpdateSetting id:String)
}

public class SettingsViewController: SettingsBaseViewController {
    
    weak var delegate : SettingsViewControllerDelegate?
    
    public var root = GroupSetting(title: "Settings", children: [], footer:nil)
    public var defaultsStore : SettingsDataSource = UserDefaults.standard
    
    /**
     Create a new SettingsViewController
     - parameter settings: The array of settings to be displayed at the root level
     - parameter delegate: Delegate to be notified of changes
     - parameter dataStore: The datastore where settings will be read/written to. Defaults = UserDefaults.standard
     */
    public init(root:GroupSetting, delegate:SettingsViewControllerDelegate, dataStore:SettingsDataSource = UserDefaults.standard) {
        self.defaultsStore = dataStore
        self.root = root
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setting(for section:Int) -> Setting {
        return root.children[section]
    }
    
    fileprivate var numberOfGroups : Int {
        return root.children.count
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = root.title
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
}

extension SettingsViewController : SettingsOptionsViewControllerDelegate {
    
    func settingsOptionsViewController(vc: SettingsOptionsViewController, didSelect option: String, for key: String) {
        defaultsStore.set(option, forKey: key)
        delegate?.settingsViewController(vc: self, didUpdateSetting: key)
        tableView.reloadData()
    }
}

extension SettingsViewController : UITableViewDelegate {
    
    private func navigateToSelect(options:SettingsOptions, label:String, key:String, value:String) {
        let optionsVC = SettingsOptionsViewController(options: options, key:key, selected:value, delegate: self)
        optionsVC.title = label
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    private func navigateToGroup(subRoot:GroupSetting) {
        let optionsVC = SettingsViewController(root: subRoot, delegate: delegate!, dataStore: defaultsStore)
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = setting(for: indexPath.section)
        switch item {
        case let .Group(g):
            let subSetting = g.children[indexPath.row]
            switch subSetting {
            case let .Select(s):
                let currentValue = s.value(from: defaultsStore)
                navigateToSelect(options: s.options, label:s.label, key:s.key, value:currentValue!)
            case let .Group(g):
                navigateToGroup(subRoot: g)
            default:
                break
            }

        case let .Select(s):
            let newValue = s.options.options[indexPath.row]
            defaultsStore.set(newValue, forKey: s.key)
            delegate?.settingsViewController(vc: self, didUpdateSetting: s.key)
            tableView.reloadData()

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
        case let .Group(g):
            return g.title
        case let .Select(s):
            return s.label
        default:
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let item = setting(for: section)
        switch item {
        case let .Group(g):
            return g.footer
        default:
            return nil
        }

    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = setting(for: section)
        switch item {
        case let .Group(g):
            return g.children.count

        case let .Select(s):
            return s.options.options.count
        default:
            return 1
        }
    }
    
    @objc
    fileprivate func switchValueChanged(s:UISwitch) {
        if let key = s.restorationIdentifier, let _ = root.setting(for: key) {
            defaultsStore.set(s.isOn, forKey: key)
            delegate?.settingsViewController(vc: self, didUpdateSetting: key)
        }
    }
    
    private func configureTextCell(cell:SettingsTextTableCell, setting:TextSetting) {
        cell.textLabel?.text = setting.label
        cell.field.restorationIdentifier = setting.key
        cell.field.delegate = self
        cell.field.text = setting.value(from: defaultsStore)
    }
    
    private func configureToggleCell(cell:SettingsTableCell, setting:ToggleSetting) {
        cell.textLabel?.text = setting.label
        cell.detailTextLabel?.text = nil
        let s = UISwitch()
        s.isOn = setting.value(from: defaultsStore)
        s.restorationIdentifier = setting.key
        s.addTarget(self, action: #selector(switchValueChanged(s:)), for: .valueChanged)
        cell.accessoryView = s
    }
    
    private func configureSelectDisclosureCell(cell:SettingsTableCell, setting:SelectSetting) {
        cell.textLabel?.text = setting.label
        cell.detailTextLabel?.text = setting.value(from: defaultsStore)
        cell.accessoryType = .disclosureIndicator
    }
    
    private func configureInfoCell(cell:SettingsTableCell, setting:InfoSetting) {
        cell.textLabel?.text = setting.label
        cell.detailTextLabel?.text = setting.text
    }
    
    private func configureGroupCell(cell:SettingsTableCell, setting:GroupSetting) {
        cell.textLabel?.text = setting.title
        cell.accessoryType = .disclosureIndicator
    }
    
    private func configureSelectOptionCell(cell:SettingsTableCell, setting:SelectSetting, index:Int) {
        let options = setting.options.options
        let valueToDisplay = options[index]
        cell.textLabel?.text = valueToDisplay
        let currentValue = setting.value(from: defaultsStore)
        cell.accessoryType = (valueToDisplay == currentValue) ? .checkmark : .none
    }
    
    private func settingCell(from tableView:UITableView, for setting:Setting, atTopLevel:Bool, forRowAt indexPath : IndexPath) -> UITableViewCell {
        switch setting {
            
        case let .Select(s):
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
            if atTopLevel {
                configureSelectOptionCell(cell: cell, setting: s, index: indexPath.row)
            } else {
                configureSelectDisclosureCell(cell: cell, setting: s)
            }
            return cell
            
        case let .Text(t):
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTextTableCell.reuseIdentifier, for: indexPath) as! SettingsTextTableCell
            configureTextCell(cell: cell, setting: t)
            return cell
            
        case let .Toggle(t):
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
            configureToggleCell(cell: cell, setting: t)
            return cell
            
        case let .Info(i):
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
            configureInfoCell(cell: cell, setting: i)
            return cell
            
        case let .Group(g):
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
            configureGroupCell(cell: cell, setting: g)
            return cell
            
        case .Slider:
            fatalError()
        }

    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = setting(for: indexPath.section)
        
        switch item {
            
        case let .Group(g):
            let subSetting = g.children[indexPath.row]
            return settingCell(from: tableView, for: subSetting, atTopLevel: false, forRowAt: indexPath)
            
        case .Select, .Text, .Toggle, .Info:
            return settingCell(from: tableView, for: item, atTopLevel: true, forRowAt: indexPath)
            
        case .Slider:
            fatalError()
        }
        
    }
    
}

extension SettingsViewController : UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let key = textField.restorationIdentifier {
            defaultsStore.set(textField.text, forKey: key)
        }
    }
}

