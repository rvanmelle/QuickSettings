//
//  UIView+Extensions.swift
//  SettingsExample
//
//  Created by Reid van Melle on 2016-10-31.
//  Copyright © 2016 Reid van Melle. All rights reserved.
//

import UIKit

internal extension UIView {

    func addSubviews(_ views: [UIView]) {
        for v in views {
            addSubview(v)
        }
    }

    // MARK: - Auto Layout

    @discardableResult func pinItem(_ item: AnyObject, attribute: NSLayoutAttribute,
                                    to toItem: AnyObject, toAttribute: NSLayoutAttribute?=nil,
                                    withOffset offset: CGFloat=0, andScale scale: CGFloat=1, priority: UILayoutPriority?=nil) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .equal,
                                            toItem: toItem, attribute: toAttribute ?? attribute,
                                            multiplier: scale, constant: offset)

        if let priority = priority {
            constraint.priority = priority
        }

        self.addConstraint(constraint)
        return constraint
    }

    // MARK: - Convenience

    // Center

    @discardableResult func pinItemCenterHorizontally(_ item: AnyObject, to toItem: AnyObject) -> NSLayoutConstraint {
        return pinItem(item, attribute: .centerX, to: toItem)
    }

    @discardableResult func pinItemCenterHorizontally(_ item: AnyObject, to toItem: AnyObject, withOffset offset: CGFloat) -> NSLayoutConstraint {
        return pinItem(item, attribute: .centerX, to: toItem, withOffset: offset)
    }

    @discardableResult func pinItemCenterVertically(_ item: AnyObject, to toItem: AnyObject) -> NSLayoutConstraint {
        return pinItem(item, attribute: .centerY, to: toItem)
    }

    @discardableResult func pinItemCenterVertically(_ item: AnyObject, to toItem: AnyObject, withOffset offset: CGFloat) -> NSLayoutConstraint {
        return pinItem(item, attribute: .centerY, to: toItem, withOffset: offset)
    }

    // Fill
    @discardableResult func pinItemFillHorizontally(_ item: AnyObject) -> [NSLayoutConstraint] {
        return [pinItem(item, attribute: .left, to: self), pinItem(item, attribute: .right, to: self)]
    }

    @discardableResult func pinItemFillVertically(_ item: AnyObject) -> [NSLayoutConstraint] {
        return [pinItem(item, attribute: .top, to: self), pinItem(item, attribute: .bottom, to: self)]
    }

    @discardableResult func pinItemFillMarginsHorizontally(_ item: AnyObject) -> [NSLayoutConstraint] {
        return [pinItem(item, attribute: .left, to: self, toAttribute: .leftMargin),
                pinItem(item, attribute: .right, to: self, toAttribute: .rightMargin)]
    }

    @discardableResult func pinItemFillMarginsVertically(_ item: AnyObject) -> [NSLayoutConstraint] {
        return [pinItem(item, attribute: .top, to: self, toAttribute: .topMargin),
                pinItem(item, attribute: .bottom, to: self, toAttribute: .bottomMargin)]
    }

    @discardableResult func pinItemFillAll(_ item: AnyObject) -> [NSLayoutConstraint] {
        return pinItemFillHorizontally(item) + pinItemFillVertically(item)
    }

    @discardableResult func pinItemFillMarginsAll(_ item: AnyObject) -> [NSLayoutConstraint] {
        return pinItemFillMarginsHorizontally(item) + pinItemFillMarginsVertically(item)
    }

    // Others

    @discardableResult func pinItemPosition(_ item: AnyObject, to toItem: AnyObject) -> [NSLayoutConstraint] {
        return [pinItemCenterHorizontally(item, to: toItem), pinItemCenterVertically(item, to: toItem)]
    }

    @discardableResult func pinItemSize(_ item: AnyObject, to toItem: AnyObject) -> [NSLayoutConstraint] {
        return [pinItem(item, attribute: .height, to: toItem), pinItem(item, attribute: .width, to: toItem)]
    }

    @discardableResult func pinItemSquare() -> NSLayoutConstraint {
        return superview!.pinItem(self, attribute: .height, to: self, toAttribute: .width)
    }
}
