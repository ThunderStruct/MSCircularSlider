//
//  MSDoubleHandleCircularSlider.swift
//
//  Created by Mohamed Shahawy on 27/09/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

public protocol MSDoubleHandleCircularSliderDelegate: MSCircularSliderProtocol {
    func circularSlider(_ slider: MSCircularSlider, valueChangedTo firstValue: Double, secondValue: Double, isFirstHandle: Bool?, fromUser: Bool)   // fromUser indicates whether the value changed by sliding the handle (fromUser == true) or through other means (fromUser == false, isFirstHandle == nil)
    func circularSlider(_ slider: MSCircularSlider, startedTrackingWith firstValue: Double, secondValue: Double, isFirstHandle: Bool)
    func circularSlider(_ slider: MSCircularSlider, endedTrackingWith firstValue: Double, secondValue: Double, isFirstHandle: Bool)
}

extension MSDoubleHandleCircularSliderDelegate {
    // Optional Methods
    func circularSlider(_ slider: MSCircularSlider, startedTrackingWith firstValue: Double, secondValue: Double, isFirstHandle: Bool) {}
    func circularSlider(_ slider: MSCircularSlider, endedTrackingWith firstValue: Double, secondValue: Double, isFirstHandle: Bool) {}
}

@IBDesignable
public class MSDoubleHandleCircularSlider: MSCircularSlider {
    
    //================================================================================
    // MEMBERS
    //================================================================================
    
    // DELEGATE
    private weak var castDelegate: MSDoubleHandleCircularSliderDelegate? {
        get {
            return delegate as? MSDoubleHandleCircularSliderDelegate
        }
        set {
            delegate = newValue
        }
    }
    
    
    // DOUBLE HANDLE SLIDER PROPERTIES
    public var minimumHandlesDistance: CGFloat = 10 {    // distance between handles
        didSet {
            let maxValue = CGFloat.pi * calculatedRadius * maximumAngle / 360.0
            
            if minimumHandlesDistance < 1 {
                print("minimumHandlesDistance \(minimumHandlesDistance) should be 1 or more - setting member to 1")
                minimumHandlesDistance = 1
            }
            else if minimumHandlesDistance > maxValue {
                print("minimumHandlesDistance \(minimumHandlesDistance) should be \(maxValue) or less - setting member to \(maxValue)")
                minimumHandlesDistance = maxValue
            }
        }
    }
    
    // SECOND HANDLE'S PROPERTIES
    let secondHandle = MSCircularSliderHandle()
    
    public var secondCurrentValue: Double {      // second handle's value
        set {
            let val = min(max(minimumValue, newValue), maximumValue)
            
            // Update second angle
            secondAngle = angleFrom(value: val)
            
            castDelegate?.circularSlider(self, valueChangedTo: currentValue, secondValue: val, isFirstHandle: nil, fromUser: false)
            
            sendActions(for: UIControlEvents.valueChanged)
        }
        get {
            return valueFrom(angle: secondAngle)
        }
    }
    
    public var secondAngle: CGFloat = 60 {
        didSet {
            secondAngle = max(0.0, secondAngle).truncatingRemainder(dividingBy: maximumAngle + 1)
        }
    }
    
    public var secondHandleColor: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var secondHandleType: MSCircularSliderHandleType = .largeCircle {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var secondHandleEnlargementPoints: Int = 10 {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var secondHandleHighlightable: Bool = true {
        didSet {
            secondHandle.isHighlightable = secondHandleHighlightable
            setNeedsDisplay()
        }
    }
    
    // CALCULATED MEMBERS
    internal var secondHandleDiameter: CGFloat {
        switch handleType {
        case .smallCircle:
            return CGFloat(Double(lineWidth) / 2.0)
        case .mediumCircle:
            return CGFloat(lineWidth)
        case .largeCircle, .doubleCircle:
            return CGFloat(lineWidth + secondHandleEnlargementPoints)
            
        }
    }
    
    // OVERRIDDEN MEMBERS
    override public var maximumAngle: CGFloat {
        didSet {
            // to account for dynamic maximumAngle changes
            secondCurrentValue = valueFrom(angle: secondAngle)
        }
    }
    
    @available(*, unavailable, message: "this feature is not implemented yet")
    override public var snapToLabels: Bool {
        set {
            
        }
        get {
            return false
        }
    }
    
    @available(*, unavailable, message: "this feature is not implemented yet")
    override public var snapToMarkers: Bool {
        set {
            
        }
        get {
            return false
        }
    }
    
    //================================================================================
    // VIRTUAL METHODS
    //================================================================================
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        
        // Draw the second handle
        let handleCenter = super.pointOnCircleAt(angle: secondAngle)
        secondHandle.frame = self.drawSecondHandle(ctx: ctx!, atPoint: handleCenter, handle: secondHandle)
    }
    
    override func drawLine(ctx: CGContext) {
        unfilledColor.set()
        // Draw unfilled circle
        drawUnfilledCircle(ctx: ctx, center: centerPoint, radius: calculatedRadius, lineWidth: CGFloat(lineWidth), maximumAngle: maximumAngle, lineCap: unfilledLineCap)
        
        filledColor.set()
        // Draw filled circle
        drawArc(ctx: ctx, center: centerPoint, radius: calculatedRadius, lineWidth: CGFloat(lineWidth), fromAngle: CGFloat(angle), toAngle: CGFloat(secondAngle), lineCap: filledLineCap)
    }
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let handleCenter = pointOnCircleAt(angle: angle)
        let secondHandleCenter = pointOnCircleAt(angle: secondAngle)
        if pointInsideHandle(location, handleCenter: handleCenter) {
            handle.isPressed = true
        }
        if pointInsideHandle(location, handleCenter: secondHandleCenter) {
            secondHandle.isPressed = true
        }
        
        if handle.isPressed && secondHandle.isPressed {
            // determine closer handle
            if (hypotf(Float(handleCenter.x - location.x), Float(handleCenter.y - location.y)) < hypotf(Float(secondHandleCenter.x - location.x), Float(secondHandleCenter.y - location.y))) {
                // first handle is closer
                secondHandle.isPressed = false
            }
            else {
                // second handle is closer
                handle.isPressed = false
            }
        }
        
        if secondHandle.isPressed || handle.isPressed {
            castDelegate?.circularSlider(self, startedTrackingWith: currentValue, secondValue: secondCurrentValue, isFirstHandle: handle.isPressed)
            
            setNeedsDisplay()
            return true
        }
        return false
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        let newAngle = floor(calculateAngle(from: centerPoint, to: point))
        
        if handle.isPressed {
            moveFirstHandleTo(newAngle)
        }
        else if secondHandle.isPressed {
            moveSecondHandleTo(newAngle)
        }
        
        castDelegate?.circularSlider(self, valueChangedTo: currentValue, secondValue: secondCurrentValue, isFirstHandle: handle.isPressed, fromUser: false)
        
        sendActions(for: UIControlEvents.valueChanged)
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        castDelegate?.circularSlider(self, endedTrackingWith: currentValue, secondValue: secondCurrentValue, isFirstHandle: handle.isPressed)
        
        handle.isPressed = false
        secondHandle.isPressed = false
        
        setNeedsDisplay()
        
        // TODO:
        // Snap To Labels/Markings future feature
    }
    
    //================================================================================
    // DRAWING METHODS
    //================================================================================
    
    internal func drawSecondHandle(ctx: CGContext, atPoint handleCenter: CGPoint, handle: MSCircularSliderHandle) -> CGRect {
        // Comment out the call to the super class and customize the second handle here
        // Must set calculatedColor for secondHandle in this case to set the handle's "highlight" if needed
        // TODO: add separate secondHandleDiameter, secondHandleColor, and secondHandleType properties
        
        ctx.saveGState()
        var frame: CGRect!
        
        // Highlight == 0.9 alpha
        let calculatedHandleColor = handle.isHighlightable && handle.isPressed ? secondHandleColor.withAlphaComponent(0.9) : secondHandleColor
        
        // Handle color calculation
        if secondHandleType == .doubleCircle {
            calculatedHandleColor.set()
            drawFilledCircle(ctx: ctx, center: handleCenter, radius: 0.25 * secondHandleDiameter)
            
            calculatedHandleColor.withAlphaComponent(0.7).set()
            
            frame = drawFilledCircle(ctx: ctx, center: handleCenter, radius: 0.5 * secondHandleDiameter)
        }
        else {
            calculatedHandleColor.set()
            
            frame = drawFilledCircle(ctx: ctx, center: handleCenter, radius: 0.5 * secondHandleDiameter)
        }
        
        
        ctx.saveGState()
        return frame
    }
    
    //================================================================================
    // HANDLE-MOVING METHODS
    //================================================================================
    private func distanceBetweenHandles(_ firstHandle: CGRect, _ secondHandle: CGRect) -> CGFloat {
        let vector = CGPoint(x: firstHandle.minX - secondHandle.minX, y: firstHandle.minY - secondHandle.minY)
        let straightDistance = CGFloat(sqrt(square(Double(vector.x)) + square(Double(vector.y))))
        let circleDiameter = calculatedRadius * 2.0
        let circularDistance = circleDiameter * asin(straightDistance / circleDiameter)
        return circularDistance
    }
    
    private func moveFirstHandleTo(_ newAngle: CGFloat) {
        let center = pointOnCircleAt(angle: newAngle)
        let radius = handleDiameter / 2.0
        let newHandleFrame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        
        if !fullCircle && newAngle > secondAngle {
            // will cross over the open part of the arc
            return
        }
        
        if distanceBetweenHandles(newHandleFrame, secondHandle.frame) < minimumHandlesDistance + handleDiameter {
            // will cross the minimumHandlesDistance - no changes
            return
        }
        
        angle = newAngle
        setNeedsDisplay()
    }
    
    private func moveSecondHandleTo(_ newAngle: CGFloat) {
        let center = pointOnCircleAt(angle: newAngle)
        let radius = handleDiameter / 2.0
        let newHandleFrame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        
        if !fullCircle && newAngle > maximumAngle {
            // will cross over the open part of the arc
            return
        }
        
        if distanceBetweenHandles(newHandleFrame, handle.frame) < minimumHandlesDistance + handleDiameter {
            // will cross the minimumHandlesDistance - no changes
            return
        }
        secondAngle = newAngle
        setNeedsDisplay()
        
    }
    
}



