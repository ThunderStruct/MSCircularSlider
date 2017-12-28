//
//  MSCircularSliderHandle.swift
//
//  Created by Mohamed Shahawy on 27/09/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

public enum MSCircularSliderHandleType: Int, RawRepresentable {
    case smallCircle = 0,
    mediumCircle,
    largeCircle,
    doubleCircle    // Semitransparent large circle with a nested small circle
}

@IBDesignable
public class MSCircularSliderHandle: CALayer {
    
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
