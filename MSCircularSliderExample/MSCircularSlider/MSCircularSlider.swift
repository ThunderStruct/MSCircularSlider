//
//  MSCircularSlider.swift
//
//  Created by Mohamed Shahawy on 27/09/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit
import QuartzCore

public protocol MSCircularSliderProtocol: class {
    // Acts as an abstract class only - not to be used
}

public protocol MSCircularSliderDelegate: MSCircularSliderProtocol {
    func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool)   // fromUser indicates whether the value changed by sliding the handle (fromUser == true) or through other means (fromUser == false)
    func circularSlider(_ slider: MSCircularSlider, startedTrackingWith value: Double)
    func circularSlider(_ slider: MSCircularSlider, endedTrackingWith value: Double)
}

extension MSCircularSliderDelegate {
    // Optional Methods
    func circularSlider(_ slider: MSCircularSlider, startedTrackingWith value: Double) {}
    func circularSlider(_ slider: MSCircularSlider, endedTrackingWith value: Double) {}
}


@objc(MSCircularSlider)
@IBDesignable
public class MSCircularSlider: UIControl {
    
    //================================================================================
    // MEMBERS
    //================================================================================
    
    // DELEGATE
    
    /** The slider's main delegate */
    weak public var delegate: MSCircularSliderProtocol? = nil
    
    /** A middle ground for casting the delegate */
    private weak var castDelegate: MSCircularSliderDelegate? {
        get {
            return delegate as? MSCircularSliderDelegate
        }
        set {
            delegate = newValue
        }
    }
    
    // VALUE/ANGLE MEMBERS
    
    /** The slider's least possible value - *default: 0.0* */
    public var minimumValue: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The slider's value at maximumAngle - *default: 100.0* */
    public var maximumValue: Double = 100.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The handle's current value - *default: minimumValue* */
    public var currentValue: Double {
        set {
            let val = min(max(minimumValue, newValue), maximumValue)
            handle.currentValue = val
            angle = angleFrom(value: val)
            
            castDelegate?.circularSlider(self, valueChangedTo: val, fromUser: false)
            
            sendActions(for: UIControlEvents.valueChanged)
            
            setNeedsDisplay()
        } get {
            return valueFrom(angle: handle.angle)
        }
    }
    
    /** The slider's circular angle - *default: 360.0 (full circle)* */
    public var maximumAngle: CGFloat = 360.0 {     // Full circle by default
        didSet {
            if maximumAngle > 360.0 {
                print("maximumAngle \(maximumAngle) should be 360° or less - setting member to 360°")
                maximumAngle = 360.0
            }
            else if maximumAngle < 0 {
                print("maximumAngle \(maximumAngle) should be 0° or more - setting member to 0°")
                maximumAngle = 360.0
            }
            
            currentValue = valueFrom(angle: angle)
            
            setNeedsDisplay()
        }
    }
    
    /** The slider layer's rotation - *default: nil / pointing north* */
    public var rotationAngle: CGFloat? = nil {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The slider's radius - *default: computed* */
    private var radius: CGFloat = -1.0 {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    // LINE MEMBERS
    
    /** The slider's line width - *default: 5*  */
    public var lineWidth: Int = 5 {
        didSet {
            setNeedsUpdateConstraints()
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** The color of the filled part of the slider - *default: .darkGray* */
    public var filledColor: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The color of the unfilled part of the slider - *default: .lightGray* */
    public var unfilledColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The slider's ending line cap - *default: .round* */
    public var unfilledLineCap: CGLineCap = .round {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The slider's beginning line cap - *default: .round* */
    public var filledLineCap: CGLineCap = .round {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // HANDLE MEMBERS
    
    /** The slider's handle layer */
    let handle = MSCircularSliderHandle()
    
    /** The handle's current angle from north - *default: 0.0 * */
    public var angle: CGFloat {
        set {
            handle.angle = max(0, newValue).truncatingRemainder(dividingBy: maximumAngle + 1)
        }
        get {
            return handle.angle
        }
    }
    
    /** The handle's color - *default: .darkGray* */
    public var handleColor: UIColor {
        set {
            handle.color = newValue
            setNeedsDisplay()
        }
        get {
            return handle.color
        }
    }
    
    /** The handle's type - *default: .largeCircle* */
    public var handleType: MSCircularSliderHandleType {
        set {
            handle.handleType = newValue
            setNeedsDisplay()
        }
        get {
            return handle.handleType
        }
    }
    
    /** The handle's enlargement point from default size - *default: 10* */
    public var handleEnlargementPoints: Int {
        set {
            handle.enlargementPoints = newValue
        }
        get {
            return handle.enlargementPoints
        }
    }
    
    /** Specifies whether the handle should highlight upon touchdown or not - *default: true* */
    public var handleHighlightable: Bool {
        set {
            handle.isHighlightable = newValue
        }
        get {
            return handle.isHighlightable
        }
    }
    
    /** The handle's image (overrides the handle color and type) - *default: nil* */
    public var handleImage: UIImage? {
        set {
            handle.image = newValue
        }
        get {
            return handle.image
        }
    }
    
    /** Specifies whether or not the handle should rotate to always point outwards - *default: false* */
    public var handleRotatable: Bool {
        set {
            handle.isRotatable = newValue
        }
        get {
            return handle.isRotatable
        }
    }
    
    /** The calculated handle's diameter based on its type */
    public var handleDiameter: CGFloat {
        return handle.diameter
    }
    
    // LABEL MEMBERS
    
    /** The slider's labels array (laid down counter-clockwise) */
    public var labels: [String] = [] {         // All labels are evenly spaced
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** Specifies whether or not the handle should snap to the nearest label upon touch release - *default: false* */
    public var snapToLabels: Bool = false {        // The 'snap' occurs on touchUp
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The labels' font - *default: .systemFont(ofSize: 12.0)* */
    public var labelFont: UIFont = .systemFont(ofSize: 12.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The labels' color - *default: .black* */
    public var labelColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The labels' offset from center (negative values push inwards) - *default: 0* */
    public var labelOffset: CGFloat = 0 {    // Negative values move the labels closer to the center
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The labels' distance from center */
    private var labelInwardsDistance: CGFloat {
        return 0.1 * -(radius) - 0.5 * CGFloat(lineWidth) - 0.5 * labelFont.pointSize
    }
    
    // MARKER MEMBERS
    
    /** The number of markers to be displayed - *default: 0* */
    public var markerCount: Int = 0 {      // All markers are evenly spaced
        didSet {
            markerCount = max(markerCount, 0)
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The markers' color - *default: .darkGray* */
    public var markerColor: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** The markers' bezier path (takes precendence over `markerImage`)- *default: nil / circle shape will be drawn* */
    public var markerPath: UIBezierPath? = nil {   // Takes precedence over markerImage
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** The markers' image - *default: nil* */
    public var markerImage: UIImage? = nil {       // Mutually-exclusive with markerPath
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    /** Specifies whether or not the handle should snap to the nearest marker upon touch release - *default: false* */
    public var snapToMarkers: Bool = false {        // The 'snap' occurs on touchUp
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    // CALCULATED MEMBERS
    
    /** The slider's calculated radius based on the components' sizes */
    public var calculatedRadius: CGFloat {
        if (radius == -1.0) {
            let minimumSize = min(bounds.size.height, bounds.size.width)
            let halfLineWidth = ceilf(Float(lineWidth) / 2.0)
            let halfHandleWidth = ceilf(Float(handleDiameter) / 2.0)
            return minimumSize * 0.5 - CGFloat(max(halfHandleWidth, halfLineWidth))
        }
        return radius
    }
    
    /** The slider's center point */
    internal var centerPoint: CGPoint {
        return CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
    }
    
    /** A read-only property that indicates whether or not the slider is a full circle */
    public var fullCircle: Bool {
        return maximumAngle == 360.0
    }
    
    //================================================================================
    // SETTER METHODS
    //================================================================================
    
    /** Appends a new label to the `labels` array */
    public func addLabel(_ string: String) {
        labels.append(string)
        
        setNeedsUpdateConstraints()
        setNeedsDisplay()
    }
    
    /** Replaces the label at a certain index with the given string */
    public func changeLabel(at index: Int, string: String) {
        assert(labels.count > index && index >= 0, "label index out of bounds")
        labels[index] = string
        
        setNeedsUpdateConstraints()
        setNeedsDisplay()
    }
    
    /** Removes a label at a given index */
    public func removeLabel(at index: Int) {
        assert(labels.count > index && index >= 0, "label index out of bounds")
        labels.remove(at: index)
        
        setNeedsUpdateConstraints()
        setNeedsDisplay()
    }
    
    //================================================================================
    // INIT AND VIRTUAL METHODS
    //================================================================================
    
    func initHandle() {
        handle.delegate = self
        handle.center = {
            return self.pointOnCircleAt(angle: self.angle)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initHandle()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        initHandle()
    }
    
    override public var intrinsicContentSize: CGSize {
        let diameter = radius * 2
        let handleRadius = ceilf(Float(handleDiameter) / 2.0)
        
        let totalWidth = diameter + CGFloat(2 *  max(handleRadius, ceilf(Float(lineWidth) / 2.0)))
        
        return CGSize(width: totalWidth, height: totalWidth)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        
        // Draw filled and unfilled lines
        drawLine(ctx: ctx!)
        
        // Draw markings
        drawMarkings(ctx: ctx!)
        
        // Draw handle
        handle.draw(in: ctx!)
        
        // Draw labels
        drawLabels(ctx: ctx!)
        
        // Rotate slider
        let rotationalTransform = getRotationalTransform()
        self.transform = rotationalTransform
        for view in subviews {      // cancel rotation on all subviews added by the user
            view.transform = rotationalTransform.inverted()
        }
        
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard event != nil else {
            return false
        }
        
        if handle.contains(point) {
            
            return true
        }
        else {
            return pointInsideCircle(point)
        }
    }
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        if handle.contains(location) {
            handle.isPressed = true
            castDelegate?.circularSlider(self, startedTrackingWith: currentValue)
            setNeedsDisplay()
            return true
        }
        
        return pointInsideCircle(location)
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let lastPoint = touch.location(in: self)
        let lastAngle = floor(calculateAngle(from: centerPoint, to: lastPoint))
        
        moveHandle(newAngle: lastAngle)
        
        castDelegate?.circularSlider(self, valueChangedTo: currentValue, fromUser: true)
        
        sendActions(for: UIControlEvents.valueChanged)
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        castDelegate?.circularSlider(self, endedTrackingWith: currentValue)
        snapHandle()
        
        handle.isPressed = false
        
        setNeedsDisplay()
    }
    
    
    //================================================================================
    // DRAWING METHODS
    //================================================================================
    
    /** Draws a circular line in the given context */
    internal func drawLine(ctx: CGContext) {
        unfilledColor.set()
        // Draw unfilled circle
        drawUnfilledCircle(ctx: ctx, center: centerPoint, radius: calculatedRadius, lineWidth: CGFloat(lineWidth), maximumAngle: maximumAngle, lineCap: unfilledLineCap)
        
        filledColor.set()
        // Draw filled circle
        drawArc(ctx: ctx, center: centerPoint, radius: calculatedRadius, lineWidth: CGFloat(lineWidth), fromAngle: 0, toAngle: CGFloat(angle), lineCap: filledLineCap)
    }
    
    /** Draws the slider's labels (if any exist) in the given context */
    private func drawLabels(ctx: CGContext) {
        if labels.count > 0 {
            let attributes = [NSAttributedStringKey.font: labelFont, NSAttributedStringKey.foregroundColor: labelColor] as [NSAttributedStringKey : Any]
            
            for i in 0 ..< labels.count {
                let label = labels[i] as NSString
                let labelFrame = frameForLabelAt(i)
                
                ctx.saveGState()
                
                // Invert transform to cancel rotation on labels
                ctx.concatenate(CGAffineTransform(translationX: labelFrame.origin.x + (labelFrame.width / 2),
                                                  y: labelFrame.origin.y + (labelFrame.height / 2)))
                ctx.concatenate(getRotationalTransform().inverted())
                ctx.concatenate(CGAffineTransform(translationX: -(labelFrame.origin.x + (labelFrame.width / 2)),
                                                  y: -(labelFrame.origin.y + (labelFrame.height / 2))))
                
                // Draw label
                label.draw(in: labelFrame, withAttributes: attributes)
                
                ctx.restoreGState()
            }
        }
    }
    
    /** Draws the slider's markers (if any exist) in the given context */
    private func drawMarkings(ctx: CGContext) {
        for i in 0 ..< markerCount {
            let markFrame = frameForMarkingAt(i)
            
            ctx.saveGState()
            
            ctx.concatenate(CGAffineTransform(translationX: markFrame.origin.x + (markFrame.width / 2),
                                              y: markFrame.origin.y + (markFrame.height / 2)))
            ctx.concatenate(getRotationalTransform().inverted())
            ctx.concatenate(CGAffineTransform(translationX: -(markFrame.origin.x + (markFrame.width / 2)),
                                              y: -(markFrame.origin.y + (markFrame.height / 2))))
            
            if self.markerPath != nil {
                markerColor.setFill()
                markerPath?.fill()
            }
            else if self.markerImage != nil {
                self.markerImage?.draw(in: markFrame)
            }
            else {
                let markPath = UIBezierPath(ovalIn: markFrame)
                markerColor.setFill()
                markPath.fill()
            }
            
            ctx.restoreGState()
        }
    }
    
    /** Draws a filled circle in context */
    @discardableResult
    internal func drawFilledCircle(ctx: CGContext, center: CGPoint, radius: CGFloat) -> CGRect {
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        ctx.fillEllipse(in: frame)
        return frame
    }
    
    /** Draws an unfilled circle in context */
    internal func drawUnfilledCircle(ctx: CGContext, center: CGPoint, radius: CGFloat, lineWidth: CGFloat, maximumAngle: CGFloat, lineCap: CGLineCap) {
        
        drawArc(ctx: ctx, center: center, radius: radius, lineWidth: lineWidth, fromAngle: 0, toAngle: maximumAngle, lineCap: lineCap)
    }
    
    /** Draws an arc in context */
    internal func drawArc(ctx: CGContext, center: CGPoint, radius: CGFloat, lineWidth: CGFloat, fromAngle: CGFloat, toAngle: CGFloat, lineCap: CGLineCap) {
        let cartesianFromAngle = toCartesian(toRad(Double(fromAngle)))
        let cartesianToAngle = toCartesian(toRad(Double(toAngle)))
        
        ctx.addArc(center: center, radius: radius, startAngle: CGFloat(cartesianFromAngle), endAngle: CGFloat(cartesianToAngle), clockwise: false)
        
        ctx.setLineWidth(lineWidth)
        ctx.setLineCap(lineCap)
        ctx.drawPath(using: CGPathDrawingMode.stroke)
    }
    
    //================================================================================
    // CALCULATION METHODS
    //================================================================================
    
    /** Calculates the angle between two points on a circle */
    internal func calculateAngle(from: CGPoint, to: CGPoint) -> CGFloat {
        var vector = CGPoint(x: to.x - from.x, y: to.y - from.y)
        let magnitude = CGFloat(sqrt(square(Double(vector.x)) + square(Double(vector.y))))
        vector.x /= magnitude
        vector.y /= magnitude
        let cartesianRad = Double(atan2(vector.y, vector.x))
        
        var compassRad = toCompass(cartesianRad)
        
        if (compassRad < 0) {
            compassRad += (2 * Double.pi)
        }
        
        assert(compassRad >= 0 && compassRad <= 2 * Double.pi, "angle must be positive")
        return CGFloat(toDeg(compassRad))
    }
    
    /** Returns a `CGPoint` on a circle given its radius and an angle */
    private func pointOn(radius: CGFloat, angle: CGFloat) -> CGPoint {
        var result = CGPoint()
        
        let cartesianAngle = CGFloat(toCartesian(toRad(Double(angle))))
        result.y = round(radius * sin(cartesianAngle))
        result.x = round(radius * cos(cartesianAngle))
        
        return result
    }
    
    /** Returns a `CGPoint` on the slider's circle given an angle */
    internal func pointOnCircleAt(angle: CGFloat) -> CGPoint {
        let offset = pointOn(radius: calculatedRadius, angle: angle)
        return CGPoint(x: centerPoint.x + offset.x, y: centerPoint.y + offset.y)
    }
    
    /** Calculates the bounds of a marker's frame given its index */
    private func frameForMarkingAt(_ index: Int) -> CGRect {
        var percentageAlongCircle: CGFloat!
        
        // Calculate degrees for marking
        percentageAlongCircle = fullCircle ? ((100.0 / CGFloat(markerCount)) * CGFloat(index)) / 100.0 : ((100.0 / CGFloat(markerCount - 1)) * CGFloat(index)) / 100.0
        
        
        let markerDegrees = percentageAlongCircle * maximumAngle
        let pointOnCircle = pointOnCircleAt(angle: markerDegrees)
        
        let markSize = CGSize(width: ((CGFloat(lineWidth) + handleDiameter) / CGFloat(2)),
                              height: ((CGFloat(lineWidth) + handleDiameter) / CGFloat(2)))
        
        // center along line
        let offsetFromCircle = CGPoint(x: -markSize.width / 2.0,
                                       y: -markSize.height / 2.0)
        
        return CGRect(x: pointOnCircle.x + offsetFromCircle.x,
                      y: pointOnCircle.y + offsetFromCircle.y,
                      width: markSize.width,
                      height: markSize.height)
    }
    
    /** Calculates the bounds of a label's frame given its index */
    private func frameForLabelAt(_ index: Int) -> CGRect {
        let label = labels[index]
        var percentageAlongCircle: CGFloat!
        
        // calculate degrees for label
        percentageAlongCircle = fullCircle ? ((100.0 / CGFloat(labels.count)) * CGFloat(index)) / 100.0 : ((100.0 / CGFloat(labels.count - 1)) * CGFloat(index)) / 100.0
        
        
        let labelDegrees = percentageAlongCircle * maximumAngle
        let pointOnCircle = pointOnCircleAt(angle: labelDegrees)
        
        let labelSize = sizeOf(string: label, withFont: labelFont)
        let offsetFromCircle = offsetForLabelAt(index: index, withSize: labelSize)
        
        return CGRect(x: pointOnCircle.x + offsetFromCircle.x,
                      y: pointOnCircle.y + offsetFromCircle.y,
                      width: labelSize.width,
                      height: labelSize.height)
    }
    
    /** Calculates the labels' offset so it would not intersect with the slider's line */
    private func offsetForLabelAt(index: Int, withSize labelSize: CGSize) -> CGPoint {
        let percentageAlongCircle = fullCircle ? ((100.0 / CGFloat(labels.count)) * CGFloat(index)) / 100.0 : ((100.0 / CGFloat(labels.count - 1)) * CGFloat(index)) / 100.0
        let labelDegrees = percentageAlongCircle * maximumAngle
        
        let radialDistance = labelInwardsDistance + labelOffset
        let inwardOffset = pointOn(radius: radialDistance, angle: CGFloat(labelDegrees))
        
        return CGPoint(x: -labelSize.width * 0.5 + inwardOffset.x, y: -labelSize.height * 0.5 + inwardOffset.y)
    }
    
    /** Calculates the angle of a certain arc */
    private func degreesFor(arcLength: CGFloat, onCircleWithRadius radius: CGFloat, withMaximumAngle degrees: CGFloat) -> CGFloat {
        let totalCircumference = CGFloat(2 * Double.pi) * radius
        
        let arcRatioToCircumference = arcLength / totalCircumference
        
        return degrees * arcRatioToCircumference
    }
    
    /** Checks whether or not a point lies within the slider's circle */
    private func pointInsideCircle(_ point: CGPoint) -> Bool {
        let p1 = centerPoint
        let p2 = point
        let xDist = p2.x - p1.x
        let yDist = p2.y - p1.y
        let distance = sqrt((xDist * xDist) + (yDist * yDist))
        return distance < calculatedRadius + CGFloat(lineWidth) * 0.5
    }
    

    
    //================================================================================
    // CONTROL METHODS
    //================================================================================
    
    /** Sets the `currentValue` with optional animation
    public func setValue(_ newValue: Double, withAnimation animated: Bool = false, animationDuration duration: Double = 0.75, completionBlock: (() -> Void)? = nil) {
        if !animated {
            currentValue = newValue
            return
        }
        
        // Animate
        let newVal = min(max(minimumValue, newValue), maximumValue)
        
        let anim = CABasicAnimation(keyPath: "currentValue")
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.fromValue = currentValue
        anim.toValue = newVal
        anim.isRemovedOnCompletion = true
        
        handle.add(anim, forKey: "currentValue")
        handle.currentValue = newVal
    }*/
    
    /** Moves the handle to `newAngle` */
    private func moveHandle(newAngle: CGFloat) {
        if newAngle > maximumAngle {    // for incomplete circles
            if newAngle > maximumAngle + (360 - maximumAngle) / 2.0 {
                angle = 0
                setNeedsDisplay()
            }
            else {
                angle = maximumAngle
                setNeedsDisplay()
            }
        }
        else {
            angle = newAngle
        }
        setNeedsDisplay()
    }
    
    /** Snaps the handle to the nearest label/marker depending on the settings */
    private func snapHandle() {
        // Snapping calculation
        var fixedAngle = 0.0 as CGFloat
        
        if angle < 0 {
            fixedAngle = -angle
        }
        else {
            fixedAngle = maximumAngle - angle
        }
        
        
        var minDist = maximumAngle
        var newAngle = 0.0 as CGFloat
        
        if snapToLabels {
            for i in 0 ..< labels.count + 1 {
                let percentageAlongCircle = Double(i) / Double(labels.count - (fullCircle ? 0 : 1))
                let degreesToLbl = CGFloat(percentageAlongCircle) * maximumAngle
                if abs(fixedAngle - degreesToLbl) < minDist {
                    newAngle = degreesToLbl != 0 || !fullCircle ? maximumAngle - degreesToLbl : 0
                    minDist = abs(fixedAngle - degreesToLbl)
                }
                
            }
            
            currentValue = valueFrom(angle: newAngle)
        }
        
        if snapToMarkers {
            for i in 0 ..< markerCount + 1 {
                let percentageAlongCircle = Double(i) / Double(markerCount - (fullCircle ? 0 : 1))
                let degreesToMarker = CGFloat(percentageAlongCircle) * maximumAngle
                if abs(fixedAngle - degreesToMarker) < minDist {
                    newAngle = degreesToMarker != 0 || !fullCircle ? maximumAngle - degreesToMarker : 0
                    minDist = abs(fixedAngle - degreesToMarker)
                }
                
            }
            
            currentValue = valueFrom(angle: newAngle)
        }
        
        setNeedsDisplay()

    }
    
    //================================================================================
    // SUPPORT METHODS
    //================================================================================
    
    /** Calculates the angle from north given a value */
    internal func angleFrom(value: Double) -> CGFloat {
        return (CGFloat(value) * maximumAngle) / CGFloat(maximumValue - minimumValue)
    }
    
    /** Calculates the value given an angle from north */
    internal func valueFrom(angle: CGFloat) -> Double {
        return (maximumValue - minimumValue) * Double(angle) / Double(maximumAngle)
    }
    
    /** Converts degrees to radians */
    private func toRad(_ degrees: Double) -> Double {
        return ((Double.pi * degrees) / 180.0)
    }
    
    /** Converts radians to degrees */
    private func toDeg(_ radians: Double) -> Double {
        return ((180.0 * radians) / Double.pi)
    }
    
    /** Squares a given Double value */
    internal func square(_ value: Double) -> Double {
        return value * value
    }
    
    /** Converts cartesian radians to compass radians */
    private func toCompass(_ cartesianRad: Double) -> Double {
        return cartesianRad + (Double.pi / 2)
    }
    
    /** Converts compass radians to cartesian radians */
    private func toCartesian(_ compassRad: Double) -> Double {
        return compassRad - (Double.pi / 2)
    }
    
    /** Calculates the size of a label given the string and its font */
    private func sizeOf(string: String, withFont font: UIFont) -> CGSize {
        let attributes = [NSAttributedStringKey.font: font]
        return NSAttributedString(string: string, attributes: attributes).size()
    }
    
    /** Calculates the entire layer's rotation (used to cancel out any rotation affecting custom subviews) */
    public func getRotationalTransform() -> CGAffineTransform {
        if fullCircle {
            // No rotation required
            let transform = CGAffineTransform.identity.rotated(by: CGFloat(0))
            return transform
        }
        else {
            if let rotation = self.rotationAngle {
                return CGAffineTransform.identity.rotated(by: CGFloat(toRad(Double(rotation))))
            }
            
            let radians = Double(-(maximumAngle / 2)) / 180.0 * Double.pi
            let transform = CGAffineTransform.identity.rotated(by: CGFloat(radians))
            return transform
        }
    }
    
}


