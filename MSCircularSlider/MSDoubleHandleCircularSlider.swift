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
    /** A middle ground for casting the delegate */
    private weak var castDelegate: MSDoubleHandleCircularSliderDelegate? {
        get {
            return delegate as? MSDoubleHandleCircularSliderDelegate
        }
        set {
            delegate = newValue
        }
    }
    
    
    // DOUBLE HANDLE SLIDER PROPERTIES
    
    /** The slider's second handle's current value - *default: `valueFrom(angle: 60.0)`* */
    public var secondCurrentValue: Double {
        set {
            let val = min(max(minimumValue, newValue), maximumValue)
            secondHandle.currentValue = val
            
            // Update second angle
            secondAngle = angleFrom(value: val)
            
            castDelegate?.circularSlider(self, valueChangedTo: currentValue, secondValue: val, isFirstHandle: nil, fromUser: false)
            
            sendActions(for: UIControlEvents.valueChanged)
            setNeedsDisplay()
        }
        get {
            return valueFrom(angle: secondHandle.angle)
        }
    }
    
    /** The minimum distance between the two handles - *default: 10* */
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
    
    /** The slider's second handle layer */
    let secondHandle = MSCircularSliderHandle()
    
    /** The second handle's current angle from north - *default: 60.0 * */
    public var secondAngle: CGFloat {
        set {
            secondHandle.angle = max(0, newValue).truncatingRemainder(dividingBy: maximumAngle + 1)
        }
        get {
            return secondHandle.angle
        }
    }
    /** The second handle's color - *default: .darkGray* */
    public var secondHandleColor: UIColor {
        set {
            secondHandle.color = newValue
        }
        get {
            return secondHandle.color
        }
    }
    
    /** The second handle's image (overrides the handle color and type) - *default: nil* */
    public var secondHandleImage: UIImage? {
        set {
            secondHandle.image = newValue
        }
        get {
            return secondHandle.image
        }
    }
    
    /** The second handle's type - *default: .largeCircle* */
    public var secondHandleType: MSCircularSliderHandleType {
        set {
            secondHandle.handleType = newValue
        }
        get {
            return secondHandle.handleType
        }
    }
    
    /** The second handle's enlargement point from default size - *default: 10* */
    public var secondHandleEnlargementPoints: Int {
        set {
            secondHandle.enlargementPoints = newValue
        }
        get {
            return secondHandle.enlargementPoints
        }
    }
    
    /** Specifies whether the second handle should highlight upon touchdown or not - *default: true* */
    public var secondHandleHighlightable: Bool {
        set {
            secondHandle.isHighlightable = newValue
        }
        get {
            return secondHandle.isHighlightable
        }
    }
    
    /** Specifies whether or not the second handle should rotate to always point outwards - *default: false* */
    public var secondHandleRotatable: Bool {
        set {
            secondHandle.isRotatable = newValue
        }
        get {
            return secondHandle.isRotatable
        }
    }
    
    // CALCULATED MEMBERS
    
    /** The calculated second handle's diameter based on its type */
    public var secondHandleDiameter: CGFloat {
        return secondHandle.diameter
    }
    
    // OVERRIDDEN MEMBERS
    
    /** The slider's circular angle - *default: 360.0 (full circle)* */
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
    
    override func initHandle() {
        super.initHandle()
        secondHandle.delegate = self
        secondHandle.center = {
            return self.pointOnCircleAt(angle: self.secondAngle)
        }
        secondHandle.angle = CGFloat(max(0, 60.0).truncatingRemainder(dividingBy: Double(maximumAngle + 1)))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        
        // Draw the second handle
        secondHandle.draw(in: ctx!)
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
        
        
        if handle.contains(location) {
            handle.isPressed = true
        }
        if secondHandle.contains(location) {
            secondHandle.isPressed = true
        }
        
        if handle.isPressed && secondHandle.isPressed {
            // determine closer handle
            if (hypotf(Float(handle.center().x - location.x), Float(handle.center().y - location.y)) < hypotf(Float(secondHandle.center().x - location.x), Float(secondHandle.center().y - location.y))) {
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
        
        // Snap To Labels/Markings future feature
    }
    
    //================================================================================
    // HANDLE-MOVING METHODS
    //================================================================================
    
    /** Calculates the current distance between the two handles */
    private func distanceBetweenHandles(_ firstHandle: CGRect, _ secondHandle: CGRect) -> CGFloat {
        let vector = CGPoint(x: firstHandle.minX - secondHandle.minX, y: firstHandle.minY - secondHandle.minY)
        let straightDistance = CGFloat(sqrt(square(Double(vector.x)) + square(Double(vector.y))))
        let circleDiameter = calculatedRadius * 2.0
        let circularDistance = circleDiameter * asin(straightDistance / circleDiameter)
        return circularDistance
    }
    
    /** Moves the first handle to a given angle */
    private func moveFirstHandleTo(_ newAngle: CGFloat) {
        let center = pointOnCircleAt(angle: newAngle)
        let radius = handle.diameter / 2.0
        let newHandleFrame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        
        if !fullCircle && newAngle > secondAngle {
            // will cross over the open part of the arc
            return
        }
        
        if distanceBetweenHandles(newHandleFrame, secondHandle.frame) < minimumHandlesDistance + secondHandle.diameter {
            // will cross the minimumHandlesDistance - no changes
            return
        }
        
        angle = newAngle
        setNeedsDisplay()
    }
    
    /** Moves the second handle to a given angle */
    private func moveSecondHandleTo(_ newAngle: CGFloat) {
        let center = pointOnCircleAt(angle: newAngle)
        let radius = secondHandle.diameter / 2.0
        let newHandleFrame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        
        if !fullCircle && (newAngle > maximumAngle || newAngle < angle) {
            // will cross over the open part of the arc
            return
        }
        
        if distanceBetweenHandles(newHandleFrame, handle.frame) < minimumHandlesDistance + secondHandle.diameter {
            // will cross the minimumHandlesDistance - no changes
            return
        }
        secondAngle = newAngle
        setNeedsDisplay()
        
    }
    
}



