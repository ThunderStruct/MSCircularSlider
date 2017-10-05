//
//  MSCircularSliderHandle.swift
//
//  Created by Mohamed Shahawy on 27/09/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

enum MSCircularSliderHandleType: Int, RawRepresentable {
    case SmallCircle = 0,
    MediumCircle,
    LargeCircle,
    DoubleCircle    // Semitransparent big circle with a nested small circle
}

@IBDesignable
class MSCircularSliderHandle: CALayer {
    
    //================================================================================
    // MEMBERS
    //================================================================================
    
    internal var isPressed: Bool = false {
        didSet {
            superlayer?.needsDisplay()
        }
    }
    
    internal var isHighlightable: Bool = true {
        didSet {
            superlayer?.needsDisplay()
        }
    }
    
}
