//
//  SettingsViewController.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import Foundation


// Base Class

public class QSSettingsBaseViewController: UITableViewController {
    
    //let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        QSSettingsTableCell.register(tableView)
        QSSettingsTextTableCell.register(tableView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(singleTapHandler(gesture:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //tableView.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(tableView)
        //view.pinItemFillAll(tableView)
    }
    
    @objc
    fileprivate func singleTapHandler(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}


// Main Settings

public protocol QSSettingsViewControllerDelegate : class {
    func settingsViewController(vc:QSSettingsViewController, didUpdateSetting id:String)
}

public class QSSettingsViewController: QSSettingsBaseViewController {
    
    weak var delegate : QSSettingsViewControllerDelegate?
    
    public var root = QSGroup(title: "Settings", children: [], footer:nil)
    public var defaultsStore : QSSettingsDataSource = UserDefaults.standard
    
    private var footerLabel : UILabel?
    private var footerLabelInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    /**
     Create a new SettingsViewController
     - parameter settings: The array of settings to be displayed at the root level
     - parameter delegate: Delegate to be notified of changes
     - parameter dataStore: The datastore where settings will be read/written to. Defaults = UserDefaults.standard
     */
    public init(root:QSGroup, delegate:QSSettingsViewControllerDelegate, dataStore:QSSettingsDataSource = UserDefaults.standard) {
        self.defaultsStore = dataStore
        self.root = root
        super.init(style: .grouped)
        //super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    fileprivate func setting(for section:Int) -> QSSettable {
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
        
        if let footer = root.footer {
            let footerView = UIView()
            let label = UILabel()
            label.text = footer
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = UIFont.italicSystemFont(ofSize: 14)
            label.textColor = UIColor.gray
            label.numberOfLines = 0
            footerView.addSubview(label)
            
            footerLabel = label
            tableView.tableFooterView = footerView
            
            footerView.pinItem(label, attribute: .top, to: footerView, toAttribute: .top, withOffset: footerLabelInsets.left)
            footerView.pinItem(label, attribute: .bottom, to: footerView, toAttribute: .bottom, withOffset: -footerLabelInsets.right)
            footerView.pinItem(label, attribute: .left, to: footerView, toAttribute: .left, withOffset: footerLabelInsets.top)
            footerView.pinItem(label, attribute: .right, to: footerView, toAttribute: .right, withOffset: -footerLabelInsets.bottom)
            
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let label = footerLabel {
            label.preferredMaxLayoutWidth = tableView.bounds.width - (footerLabelInsets.left + footerLabelInsets.right)
        }
        
        if let footerView = tableView.tableFooterView {
            let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var footerFrame = footerView.frame
            
            if height != footerFrame.size.height {
                footerFrame.size.height = height
                footerView.frame = footerFrame
                tableView.tableFooterView = footerView
            }
        }
    }
    
}

extension QSSettingsViewController : QSSettingsOptionsViewControllerDelegate {
    
    func settingsOptionsViewController(vc: QSSettingsOptionsViewController, didSelect option: String, for key: String) {
        defaultsStore.set(option, forKey: key)
        delegate?.settingsViewController(vc: self, didUpdateSetting: key)
        tableView.reloadData()
    }
}

extension QSSettingsViewController  {
    
    private func navigateToSelect(options:QSSettingsOptions, label:String, key:String, value:String) {
        let optionsVC = QSSettingsOptionsViewController(options: options, key:key, selected:value, delegate: self)
        optionsVC.title = label
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    private func navigateToGroup(subRoot:QSGroup) {
        let optionsVC = QSSettingsViewController(root: subRoot, delegate: delegate!, dataStore: defaultsStore)
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = setting(for: indexPath.section)
        switch item {
        case let g as QSGroup:
            let subSetting = g.children[indexPath.row]
            switch subSetting {
            case let s as QSSelect:
                let currentValue = s.value(from: defaultsStore)
                navigateToSelect(options: s.options, label:s.label, key:s.key, value:currentValue!)
            case let g as QSGroup:
                navigateToGroup(subRoot: g)
            default:
                break
            }

        case let s as QSSelect:
            let newValue = s.options.options[indexPath.row]
            defaultsStore.set(newValue, forKey: s.key)
            delegate?.settingsViewController(vc: self, didUpdateSetting: s.key)
            tableView.reloadData()

        default:
            break
        }
    }
}

extension QSSettingsViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfGroups
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = setting(for: section)
        switch item {
        case let g as QSGroup:
            return g.title
        case let s as QSSelect:
            return s.label
        default:
            return nil
        }
    }
    
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let item = setting(for: section)
        switch item {
        case let g as QSGroup:
            return g.footer
        default:
            return nil
        }

    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = setting(for: section)
        switch item {
        case let g as QSGroup:
            return g.children.count

        case let s as QSSelect:
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
    
    private func configureTextCell(cell:QSSettingsTextTableCell, setting:QSText) {
        cell.textLabel?.text = setting.label
        cell.field.restorationIdentifier = setting.key
        cell.field.delegate = self
        cell.field.text = setting.value(from: defaultsStore)
        cell.textType = setting.type
    }
    
    private func configureToggleCell(cell:QSSettingsTableCell, setting:QSToggle) {
        cell.textLabel?.text = setting.label
        cell.detailTextLabel?.text = nil
        let s = UISwitch()
        s.isOn = setting.value(from: defaultsStore)
        s.restorationIdentifier = setting.key
        s.addTarget(self, action: #selector(switchValueChanged(s:)), for: .valueChanged)
        cell.accessoryView = s
    }
    
    private func configureSelectDisclosureCell(cell:QSSettingsTableCell, setting:QSSelect) {
        cell.textLabel?.text = setting.label
        cell.detailTextLabel?.text = setting.value(from: defaultsStore)
        cell.accessoryType = .disclosureIndicator
    }
    
    private func configureInfoCell(cell:QSSettingsTableCell, setting:QSInfo) {
        cell.textLabel?.text = setting.label
        cell.detailTextLabel?.text = setting.text
    }
    
    private func configureGroupCell(cell:QSSettingsTableCell, setting:QSGroup) {
        cell.textLabel?.text = setting.title
        cell.accessoryType = .disclosureIndicator
    }
    
    private func configureSelectOptionCell(cell:QSSettingsTableCell, setting:QSSelect, index:Int) {
        let options = setting.options.options
        let valueToDisplay = options[index]
        cell.textLabel?.text = valueToDisplay
        let currentValue = setting.value(from: defaultsStore)
        cell.accessoryType = (valueToDisplay == currentValue) ? .checkmark : .none
    }
    
    private func settingCell(from tableView:UITableView, for setting:QSSettable, atTopLevel:Bool, forRowAt indexPath : IndexPath) -> UITableViewCell {
        switch setting {
            
        case let s as QSSelect:
            let cell = QSSettingsTableCell.dequeue(tableView, for: indexPath)
            if atTopLevel {
                configureSelectOptionCell(cell: cell, setting: s, index: indexPath.row)
            } else {
                configureSelectDisclosureCell(cell: cell, setting: s)
            }
            return cell
            
        case let t as QSText:
            let cell = QSSettingsTextTableCell.dequeue(tableView, for: indexPath)
            configureTextCell(cell: cell, setting: t)
            return cell
            
        case let t as QSToggle:
            let cell = QSSettingsTableCell.dequeue(tableView, for: indexPath)
            configureToggleCell(cell: cell, setting: t)
            return cell
            
        case let i as QSInfo:
            let cell = QSSettingsTableCell.dequeue(tableView, for: indexPath)
            configureInfoCell(cell: cell, setting: i)
            return cell
            
        case let g as QSGroup:
            let cell = QSSettingsTableCell.dequeue(tableView, for: indexPath)
            configureGroupCell(cell: cell, setting: g)
            return cell
            
        case is QSSlider:
            fatalError()
        default:
            fatalError()
        }

    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = setting(for: indexPath.section)
        
        switch item {
            
        case let g as QSGroup:
            let subSetting = g.children[indexPath.row]
            return settingCell(from: tableView, for: subSetting, atTopLevel: false, forRowAt: indexPath)
            
        case is QSSelect, is QSText, is QSToggle, is QSInfo:
            return settingCell(from: tableView, for: item, atTopLevel: true, forRowAt: indexPath)
            
        case is QSSlider:
            fatalError()
        default:
            fatalError()
        }
        
    }
    
}

extension QSSettingsViewController : UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let key = textField.restorationIdentifier {
            defaultsStore.set(textField.text, forKey: key)
        }
    }
}

