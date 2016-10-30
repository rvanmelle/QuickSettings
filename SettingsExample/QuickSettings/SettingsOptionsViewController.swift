//
//  SettingsOptionsViewController.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import Foundation

// Settings Options
protocol SettingsOptionsViewControllerDelegate : class {
}

class SettingsOptionsViewController: SettingsBaseViewController {
    
    weak var delegate : SettingsOptionsViewControllerDelegate?
    fileprivate var options : SettingsOptions
    fileprivate var selected : String
    
    init(options:SettingsOptions, selected:String, delegate:SettingsOptionsViewControllerDelegate) {
        self.selected = selected
        self.options = options
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
    }
    
}

extension SettingsOptionsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        selected = cell!.textLabel!.text!
        tableView.reloadData()
    }
}

extension SettingsOptionsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.reuseIdentifier, for: indexPath) as! SettingsTableCell
        let val = options.options[indexPath.row]
        cell.textLabel?.text = val
        cell.accessoryType = val == selected ? .checkmark : .none
        return cell
    }
}
