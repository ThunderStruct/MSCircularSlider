//
//  MSGradientCircularSlider.swift
//
//  Created by Mohamed Shahawy on 27/09/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

@IBDesignable
public class MSGradientCircularSlider: MSCircularSlider {
    
    // Gradient colors array

    /** The slider's gradient colors array - Note: use the provided methods to apply changes */
    public var gradientColors: [UIColor] = [.lightGray, .blue, .darkGray] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The slider's current angle */
    override public var angle: CGFloat {
        didSet {
            let anglePercentage = Double(angle) * 100.0 / Double(maximumAngle)
            filledColor = colorFor(percentage: anglePercentage)
            
            setNeedsDisplay()
        }
    }
    
    //================================================================================
    // SETTER METHODS
    //================================================================================
    
    /** Appends a new color to the `gradientColors` array */
    public func addColor(_ color: UIColor) {
        gradientColors.append(color)
        
        let anglePercentage = Double(angle) * 100.0 / Double(maximumAngle)
        filledColor = colorFor(percentage: anglePercentage)
        setNeedsDisplay()
    }
    
    /** Replaces the color at a certain index with the given new color */
    public func changeColor(at index: Int, newColor: UIColor) {
        assert(gradientColors.count > index && index >= 0, "gradient color index out of bounds")
        gradientColors[index] = newColor
        
        let anglePercentage = Double(angle) * 100.0 / Double(maximumAngle)
        filledColor = colorFor(percentage: anglePercentage)
        setNeedsDisplay()
    }
    
    /** Removes a gradientColors at a given index */
    public func removeColor(at index: Int) {
        assert(gradientColors.count > index && index >= 0, "gradient color index out of bounds")
        assert(gradientColors.count <= 2, "gradient colors array must contain at least 2 elements")
        gradientColors.remove(at: index)
        
        let anglePercentage = Double(angle) * 100.0 / Double(maximumAngle)
        filledColor = colorFor(percentage: anglePercentage)
        setNeedsDisplay()
    }
    
    //================================================================================
    // SUPPORT METHODS
    //================================================================================
    
    /** Calculates the color blend at a certain filled percentage */
    private func blend(from: UIColor, to: UIColor, percentage: Double) -> UIColor {
        var fromR: CGFloat = 0.0
        var fromG: CGFloat = 0.0
        var fromB: CGFloat = 0.0
        var fromA: CGFloat = 0.0
        var toR: CGFloat = 0.0
        var toG: CGFloat = 0.0
        var toB: CGFloat = 0.0
        var toA: CGFloat = 0.0
        
        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        
        let dR = toR - fromR
        let dG = toG - fromG
        let dB = toB - fromB
        let dA = toA - fromA
        
        let rR = fromR + dR * CGFloat(percentage)
        let rG = fromG + dG * CGFloat(percentage)
        let rB = fromB + dB * CGFloat(percentage)
        let rA = fromA + dA * CGFloat(percentage)
        
        return UIColor(red: rR, green: rG, blue: rB, alpha: rA)
    }
    
    /** Calculates the color for the current angle */
    private func colorFor(percentage: Double) -> UIColor {
        let colorPercentageInterval = 100.0 / Double(gradientColors.count - 1)
        
        let currentInterval = percentage / colorPercentageInterval - (percentage == 100 ? 1 : 0)
        
        let intervalPercentage = currentInterval - Double(Int(currentInterval))     // how far along between two colors
        
        return blend(from: gradientColors[Int(floor(currentInterval))],
                     to: gradientColors[min(Int(floor(currentInterval + 1)), gradientColors.count - 1)],
                     percentage: intervalPercentage)
        
    }
}



