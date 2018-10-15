//
//  SettingsTableCell.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import Foundation

class QSSettingsTableCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    class func dequeue(_ tableView: UITableView, for indexPath: IndexPath) -> QSSettingsTableCell {
        guard let tbc = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? QSSettingsTableCell else {
            fatalError()
        }
        return tbc
    }

    class func register(_ tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }

    static var reuseIdentifier: String {
        return "SettingsTableCell"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        accessoryView = nil
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
}

class QSSettingsActionTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.textAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    class func dequeue(_ tableView: UITableView, for indexPath: IndexPath) -> QSSettingsActionTableCell {
        guard let tbc = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? QSSettingsActionTableCell else {
            fatalError()
        }
        return tbc
    }

    class func register(_ tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }

    static var reuseIdentifier: String {
        return "SettingsActionTableCell"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        accessoryView = nil
        textLabel?.text = nil
        textLabel?.font = textLabel?.font.withTraits()
        textLabel?.textColor = UIColor.black
    }
}

class QSSettingsTextTableCell: UITableViewCell {

    let field = UITextField()

    var textType: QSTextSettingType = .text {
        didSet {
            field.autocorrectionType = textType.autocorrection
            field.autocapitalizationType = textType.autocapitalization
            field.isSecureTextEntry = textType.secure
            field.keyboardType = textType.keyboard
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textAlignment = .right
        field.returnKeyType = .done
        contentView.addSubview(field)
        contentView.pinItemFillMarginsVertically(field)
        contentView.pinItem(field, attribute: .right, to:  contentView, toAttribute: .rightMargin)
        contentView.pinItem(field, attribute: .left, to: contentView, toAttribute: .centerX)
    }

    class func dequeue(_ tableView: UITableView, for indexPath: IndexPath) -> QSSettingsTextTableCell {
        guard let tbc = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? QSSettingsTextTableCell else {
            fatalError()
        }
        return tbc
    }

    class func register(_ tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    static var reuseIdentifier: String {
        return "SettingsTextTableCell"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        accessoryView = nil
        textLabel?.text = nil
        detailTextLabel?.text = nil
        field.text = nil
    }

}
