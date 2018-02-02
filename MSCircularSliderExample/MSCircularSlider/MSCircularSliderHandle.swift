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
    
    /** A reference to the parent slider */
    private var slider: MSCircularSlider {
        return delegate as! MSCircularSlider
    }
    
    /** The handle's current angle form north */
    @NSManaged public var angle: CGFloat
    
    /** The handle's current value - *default: minimumValue* */
    @NSManaged public var currentValue: Double
    
    /** Specifies whether or not the handle is touched */
    internal var isPressed: Bool = false {
        didSet {
            superlayer?.needsDisplay()
        }
    }
    
    /** Specifies whether or not the handle should highlight upon touchdown */
    internal var isHighlightable: Bool = true {
        didSet {
            superlayer?.needsDisplay()
        }
    }
    
    /** The handle's color - *default: .darkGray* */
    internal var color: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The handle's type - *default: .largeCircle* */
    internal var handleType: MSCircularSliderHandleType = .largeCircle {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The handle's image (overrides the handle color and type) - *default: nil* */
    internal var image: UIImage? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The handle's enlargement point from default size - *default: 10* */
    internal var enlargementPoints: Int = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The handle's center point */
    internal var center: (() -> CGPoint)!
    
    /** The calculated handle diameter based on its type */
    internal var diameter: CGFloat {
        switch handleType {
        case .smallCircle:
            return CGFloat(Double(slider.lineWidth) / 2.0)
        case .mediumCircle:
            return CGFloat(slider.lineWidth)
        case .largeCircle, .doubleCircle:
            return CGFloat(slider.lineWidth + enlargementPoints)
            
        }
    }
    
    //================================================================================
    // SETTERS AND GETTERS
    //================================================================================
    
    internal func setAngle(_ newAngle: CGFloat) {
        angle = max(0, newAngle).truncatingRemainder(dividingBy: slider.maximumAngle + 1)
    }
    
    //================================================================================
    // VIRTUAL METHODS
    //================================================================================
    
    override class public func needsDisplay(forKey key: String) -> Bool {
        if key == "angle" || key == "currentValue" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    //================================================================================
    // DRAWING
    //================================================================================
    
    internal func drawHandle(ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        ctx.saveGState()
        
        // Highlight == 0.9 alpha
        let calculatedHandleColor = isHighlightable && isPressed ? color.withAlphaComponent(0.9) : color
        
        // Handle drawing
        if image != nil {
            frame = CGRect(x: center().x - diameter * 0.5,
                           y: center().y - diameter * 0.5,
                           width: diameter,
                           height: diameter)
            image?.draw(in: frame)
            
        }
        else if handleType == .doubleCircle {
            calculatedHandleColor.withAlphaComponent(isHighlightable && isPressed ? 0.9 : 1.0).set()
            slider.drawFilledCircle(ctx: ctx, center: center(), radius: 0.25 * diameter)
            
            calculatedHandleColor.withAlphaComponent(isHighlightable && isPressed ? 0.6 : 0.7).set()
            
            frame = slider.drawFilledCircle(ctx: ctx, center: center(), radius: 0.5 * diameter)
        }
        else {
            calculatedHandleColor.set()
            
            frame = slider.drawFilledCircle(ctx: ctx, center: center(), radius: 0.5 * diameter)
        }
        
        ctx.saveGState()
        UIGraphicsPopContext()
    }
    
    public override func draw(in ctx: CGContext) {
        drawHandle(ctx: ctx)
    }
    
    //================================================================================
    // SUPPORT METHODS
    //================================================================================
    
    /** Checks whether or not a point lies within the handle's circle */
    override public func contains(_ point: CGPoint) -> Bool {
        let handleRadius = max(diameter, 44.0) * 0.5  // 44 points as per Apple's design guidelines
        
        return point.x >= center().x - handleRadius && point.x <= center().x + handleRadius && point.y >= center().y - handleRadius && point.y <= center().y + handleRadius
    }
    
}
