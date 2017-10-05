//
//  MSDoubleHandleCircularSlider.swift
//
//  Created by Mohamed Shahawy on 27/09/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

protocol MSDoubleHandleCircularSliderDelegate: MSCircularSliderProtocol {
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
class MSDoubleHandleCircularSlider: MSCircularSlider {
    
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
    
    
    // SECOND HANDLE'S PROPERTIES
    var minimumHandlesDistance: CGFloat = 10 {    // distance between handles
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
    
    override var handleHighlightable: Bool {
        didSet {
            secondHandle.isHighlightable = handleHighlightable
            setNeedsDisplay()
        }
    }
    
    var secondCurrentValue: Double {      // second handle's value
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
    
    var secondAngle: CGFloat = 60 {
        didSet {
            //assert(secondAngle >= 0 && secondAngle <= 360, "secondAngle \(secondAngle) must be between 0 and 360 inclusive")
            secondAngle = max(0.0, secondAngle).truncatingRemainder(dividingBy: maximumAngle + 1)
        }
    }
    
    let secondHandle = MSCircularSliderHandle()
    
    // OVERRIDDEN MEMBERS
    override var maximumAngle: CGFloat {
        didSet {
            // to account for dynamic maximumAngle changes
            secondCurrentValue = valueFrom(angle: secondAngle)
        }
    }
    
    @available(*, unavailable, message: "this feature is not implemented yet")
    override var snapToLabels: Bool {
        set {
            
        }
        get {
            return false
        }
    }
    
    @available(*, unavailable, message: "this feature is not implemented yet")
    override var snapToMarkers: Bool {
        set {
            
        }
        get {
            return false
        }
    }
    
    //================================================================================
    // VIRTUAL METHODS
    //================================================================================
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        
        // Draw the second handle
        let handleCenter = super.pointOnCircleAt(angle: secondAngle)
        secondHandle.frame = self.drawHandle(ctx: ctx!, atPoint: handleCenter, handle: secondHandle)
    }
    
    override func drawLine(ctx: CGContext) {
        unfilledColor.set()
        // Draw unfilled circle
        drawUnfilledCircle(ctx: ctx, center: centerPoint, radius: calculatedRadius, lineWidth: CGFloat(lineWidth), maximumAngle: maximumAngle, lineCap: unfilledLineCap)
        
        filledColor.set()
        // Draw filled circle
        drawArc(ctx: ctx, center: centerPoint, radius: calculatedRadius, lineWidth: CGFloat(lineWidth), fromAngle: CGFloat(angle), toAngle: CGFloat(secondAngle), lineCap: filledLineCap)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
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
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
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
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
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
    
    override func drawHandle(ctx: CGContext, atPoint handleCenter: CGPoint, handle: MSCircularSliderHandle) -> CGRect {
        // Comment out the call to the super class and customize the second handle here
        // Must set calculatedColor for secondHandle in this case to set the handle's "highlight" if needed
        // TODO: add separate secondHandleDiameter, secondHandleColor, and secondHandleType properties
        
        return super.drawHandle(ctx: ctx, atPoint: handleCenter, handle: handle)
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



