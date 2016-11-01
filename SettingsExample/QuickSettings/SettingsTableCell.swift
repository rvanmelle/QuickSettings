//
//  SettingsTableCell.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-30.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import Foundation

class SettingsTableCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
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

class SettingsTextTableCell : UITableViewCell {
    
    let field = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textAlignment = .right
        contentView.addSubview(field)
        contentView.pinItemFillMarginsVertically(field)
        contentView.pinItem(field, attribute: .right, to:  contentView, toAttribute: .rightMargin)
        contentView.pinItem(field, attribute: .left, to: contentView, toAttribute: .centerX)
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

