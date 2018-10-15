//
//  Helpers.swift
//  Tracker
//
//  Created by Reid van Melle on 2017-04-03.
//  Copyright © 2017 Reid van Melle Inc. All rights reserved.
//

import Foundation

internal extension UIFont {

    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) else { fatalError() }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func bold() -> UIFont {
        return withTraits(.traitBold)
    }

    func italic() -> UIFont {
        return withTraits(.traitItalic)
    }

    func boldItalic() -> UIFont {
        return withTraits(.traitBold, .traitItalic)
    }
    
}
