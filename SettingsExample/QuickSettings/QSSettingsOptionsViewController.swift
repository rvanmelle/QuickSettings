//
//  SettingsOptionsViewController.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import Foundation

// Settings Options
protocol QSSettingsOptionsViewControllerDelegate : class {
    func settingsOptionsViewController(settingsVC: QSSettingsOptionsViewController, didSelect option: String, for key: String)
}

class QSSettingsOptionsViewController: QSSettingsBaseViewController {

    weak var delegate: QSSettingsOptionsViewControllerDelegate?

    fileprivate var options: QSSettingsOptions
    fileprivate var selected: String
    fileprivate var optionKey: String

    init(options: QSSettingsOptions, key: String, selected: String, delegate: QSSettingsOptionsViewControllerDelegate) {
        self.selected = selected
        self.options = options
        self.optionKey = key
        //super.init(nibName: nil, bundle: nil)
        super.init(style: .grouped)
        self.delegate = delegate

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}

extension QSSettingsOptionsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        selected = cell!.textLabel!.text!
        delegate?.settingsOptionsViewController(settingsVC: self, didSelect: selected, for: optionKey)
        tableView.reloadData()
    }
}

extension QSSettingsOptionsViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = QSSettingsTableCell.dequeue(tableView, for: indexPath)
        let val = options.options[indexPath.row]
        cell.textLabel?.text = val
        cell.accessoryType = val == selected ? .checkmark : .none
        return cell
    }
}
