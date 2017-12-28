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
    // DOUBLE HANDLE SLIDER PROPERTIES
    //================================================================================
    
    @IBInspectable public var _minimumHandlesDistance: CGFloat {
        get {
            return minimumHandlesDistance
        }
        set {
            minimumHandlesDistance = newValue
        }
    }
    
    @IBInspectable public var _secondCurrentValue: Double {
        get {
            return secondCurrentValue
        }
        set {
            secondCurrentValue = newValue
        }
    }
    
    //================================================================================
    // SECOND HANDLE PROPERTIES
    //================================================================================
    
    @IBInspectable public var _secondHandleType: Int {   // Takes values from 0 to 3 only
        get {
            return secondHandleType.rawValue
        }
        set {
            if let temp = MSCircularSliderHandleType(rawValue: newValue) {
                secondHandleType = temp
            }
        }
    }
    
    @IBInspectable public var _secondHandleColor: UIColor {
        get {
            return secondHandleColor
        }
        set {
            secondHandleColor = newValue
        }
    }
    
    @IBInspectable public var _secondHandleEnlargementPoints: Int {
        get {
            return secondHandleEnlargementPoints
        }
        set {
            secondHandleEnlargementPoints = newValue
        }
    }
    
    @IBInspectable public var _secondHandleHighlightable: Bool {
        get {
            return secondHandleHighlightable
        }
        set {
            secondHandleHighlightable = newValue
        }
    }
    
    
}
