//
//  Helpers.swift
//  Tracker
//
//  Created by Reid van Melle on 2017-04-03.
//  Copyright © 2017 Standable Inc. All rights reserved.
//

import Foundation

extension UIFont {

    func withTraits(_ traits: UIFontDescriptorSymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits)) else { fatalError() }
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
