//
//  MSDoubleHandleCircularSlider+IB.swift
//  MoodiTrack
//
//  Created by Mohamed Shahawy on 9/30/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

extension MSDoubleHandleCircularSlider {
    
    //================================================================================
    // SECOND HANDLE PROPERTIES
    //================================================================================
    
    @IBInspectable var _minimumHandlesDistance: CGFloat {
        get {
            return minimumHandlesDistance
        }
        set {
            minimumHandlesDistance = newValue
        }
    }
    
    @IBInspectable var _secondCurrentValue: Double {
        get {
            return secondCurrentValue
        }
        set {
            secondCurrentValue = newValue
        }
    }
}
