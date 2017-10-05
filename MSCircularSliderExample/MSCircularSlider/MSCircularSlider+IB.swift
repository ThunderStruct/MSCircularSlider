//
//  MSCircularSlider+IB.swift
//
//  Created by Mohamed Shahawy on 27/09/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

extension MSCircularSlider {
    
    //================================================================================
    // VALUE PROPERTIES
    //================================================================================
    
    @IBInspectable var _minimumValue: Double {
        get {
            return minimumValue
        }
        set {
            minimumValue = newValue
        }
    }
    
    @IBInspectable var _maximumValue: Double {
        get {
            return maximumValue
        }
        set {
            maximumValue = newValue
        }
    }
    
    @IBInspectable var _currentValue: Double {
        get {
            return currentValue
        }
        set {
            currentValue = min(max(newValue, minimumValue), maximumValue)
        }
    }
    
    //================================================================================
    // SHAPE PROPERTIES
    //================================================================================
    
    @IBInspectable var _maximumAngle: CGFloat {
        get {
            return maximumAngle
        }
        set {
            let modifiedNewValue = newValue < 0.0 ? 360.0 - (newValue.truncatingRemainder(dividingBy: 360.0)) : newValue
            maximumAngle = modifiedNewValue < 360.0 ? modifiedNewValue : modifiedNewValue.truncatingRemainder(dividingBy: 360.0)
        }
    }
    
    @IBInspectable var _lineWidth: Int {
        get {
            return lineWidth
        }
        set {
            lineWidth = newValue
        }
    }
    
    @IBInspectable var _filledColor: UIColor {
        get {
            return filledColor
        }
        set {
            filledColor = newValue
        }
    }
    
    @IBInspectable var _unfilledColor: UIColor {
        get {
            return unfilledColor
        }
        set {
            unfilledColor = newValue
        }
    }
    
    @IBInspectable var _rotationAngle: CGFloat {
        get {
            return rotationAngle ?? 0 as CGFloat
        }
        set {
            rotationAngle = newValue
        }
    }
    
    //================================================================================
    // HANDLE PROPERTIES
    //================================================================================
    
    @IBInspectable var _handleType: Int {   // Takes values from 0 to 3 only
        get {
            return handleType.rawValue
        }
        set {
            if let temp = MSCircularSliderHandleType(rawValue: newValue) {
                handleType = temp
            }
        }
    }
    
    @IBInspectable var _handleColor: UIColor {
        get {
            return handleColor
        }
        set {
            handleColor = newValue
        }
    }
    
    @IBInspectable var _handleEnlargementPoints: Int {
        get {
            return handleEnlargementPoints
        }
        set {
            handleEnlargementPoints = newValue
        }
    }
    
    @IBInspectable var _handleHighlightable: Bool {
        get {
            return handleHighlightable
        }
        set {
            handleHighlightable = newValue
        }
    }
    
    //================================================================================
    // LABELS PROPERTIES
    //================================================================================
    
    @IBInspectable var _commaSeparatedLabels: String {
        get {
            return labels.isEmpty ? "" : labels.joined(separator: ",")
        }
        set {
            if !newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                
                labels = newValue.components(separatedBy: ",")
            }
        }
    }
    
    @IBInspectable var _labelFont: UIFont {
        get {
            return labelFont
        }
        set {
            labelFont = newValue
        }
    }
    
    @IBInspectable var _labelColor: UIColor {
        get {
            return labelColor
        }
        set {
            labelColor = newValue
        }
    }
    
    @IBInspectable var _labelOffset: CGFloat {
        get {
            return labelOffset
        }
        set {
            labelOffset = newValue
        }
    }
    
    @IBInspectable var _snapToLabels: Bool {
        get {
            return snapToLabels
        }
        set {
            snapToLabels = newValue
        }
    }
    
    //================================================================================
    // MARKERS PROPERTIES
    //================================================================================
    
    @IBInspectable var _markerCount: Int {
        get {
            return markerCount
        }
        set {
            markerCount = max(0, newValue)
        }
    }
    
    @IBInspectable var _markerColor: UIColor {
        get {
            return markerColor
        }
        set {
            markerColor = newValue
        }
    }
    
    @IBInspectable var _markerImage: UIImage {
        get {
            return markerImage ?? UIImage()
        }
        set {
            markerImage = newValue
        }
    }
    
    @IBInspectable var _snapToMarkers: Bool {
        get {
            return snapToMarkers
        }
        set {
            snapToMarkers = newValue
        }
    }
    
}




