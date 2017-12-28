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
    weak public var delegate: MSCircularSliderProtocol? = nil
    private weak var castDelegate: MSCircularSliderDelegate? {
        get {
            return delegate as? MSCircularSliderDelegate
        }
        set {
            delegate = newValue
        }
    }
    
    // VALUE/ANGLE MEMBERS
    public var minimumValue: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var maximumValue: Double = 100.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var currentValue: Double {
        set {
            let val = min(max(minimumValue, newValue), maximumValue)
            angle = angleFrom(value: val)
            
            castDelegate?.circularSlider(self, valueChangedTo: val, fromUser: false)
            
            sendActions(for: UIControlEvents.valueChanged)
            
            
            setNeedsDisplay()
        } get {
            return valueFrom(angle: angle)
        }
    }
    
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
    
    public var angle: CGFloat = 0 {
        didSet {
            angle = max(0, angle).truncatingRemainder(dividingBy: maximumAngle + 1)
        }
    }
    
    public var rotationAngle: CGFloat? = nil {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    private var radius: CGFloat = -1.0 {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    // LINE MEMBERS
    public var lineWidth: Int = 5 {
        didSet {
            setNeedsUpdateConstraints()
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    
    public var filledColor: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    public var unfilledColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var unfilledLineCap: CGLineCap = .round {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var filledLineCap: CGLineCap = .round {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // HANDLE MEMBERS
    let handle = MSCircularSliderHandle()
    
    public var handleColor: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var handleType: MSCircularSliderHandleType = .largeCircle {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var handleEnlargementPoints: Int = 10 {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var handleHighlightable: Bool = true {
        didSet {
            handle.isHighlightable = handleHighlightable
            setNeedsDisplay()
        }
    }
    
    // LABEL MEMBERS
    public var labels: [String] = [] {         // All labels are evenly spaced
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var snapToLabels: Bool = false {        // The 'snap' occurs on touchUp
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var labelFont: UIFont = .systemFont(ofSize: 12.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var labelColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var labelOffset: CGFloat = 0 {    // Negative values move the labels closer to the center
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    private var labelInwardsDistance: CGFloat {
        return 0.1 * -(radius) - 0.5 * CGFloat(lineWidth) - 0.5 * labelFont.pointSize
    }
    
    // MARKER MEMBERS
    public var markerCount: Int = 0 {      // All markers are evenly spaced
        didSet {
            markerCount = max(markerCount, 0)
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var markerColor: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var markerPath: UIBezierPath? = nil {   // Takes precedence over markerImage
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var markerImage: UIImage? = nil {       // Mutually-exclusive with markerPath
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    public var snapToMarkers: Bool = false {        // The 'snap' occurs on touchUp
        didSet {
            setNeedsUpdateConstraints()
            setNeedsDisplay()
        }
    }
    
    // CALCULATED MEMBERS
    public var calculatedRadius: CGFloat {
        if (radius == -1.0) {
            let minimumSize = min(bounds.size.height, bounds.size.width)
            let halfLineWidth = ceilf(Float(lineWidth) / 2.0)
            let halfHandleWidth = ceilf(Float(handleDiameter) / 2.0)
            return minimumSize * 0.5 - CGFloat(max(halfHandleWidth, halfLineWidth))
        }
        return radius
    }
    
    internal var centerPoint: CGPoint {
        return CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
    }
    
    public var fullCircle: Bool {
        return maximumAngle == 360.0
    }
    
    internal var handleDiameter: CGFloat {
        switch handleType {
        case .smallCircle:
            return CGFloat(Double(lineWidth) / 2.0)
        case .mediumCircle:
            return CGFloat(lineWidth)
        case .largeCircle, .doubleCircle:
            return CGFloat(lineWidth + handleEnlargementPoints)
            
        }
    }
    
    //================================================================================
    // SETTER METHODS
    //================================================================================
    
    public func addLabel(_ string: String) {
        labels.append(string)
        
        setNeedsUpdateConstraints()
        setNeedsDisplay()
    }
    
    public func changeLabel(at index: Int, string: String) {
        assert(labels.count > index && index >= 0, "label index out of bounds")
        labels[index] = string
        
        setNeedsUpdateConstraints()
        setNeedsDisplay()
    }
    
    public func removeLabel(at index: Int) {
        assert(labels.count > index && index >= 0, "label index out of bounds")
        labels.remove(at: index)
        
        setNeedsUpdateConstraints()
        setNeedsDisplay()
    }
    
    //================================================================================
    // VIRTUAL METHODS
    //================================================================================
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
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
        let handleCenter = pointOnCircleAt(angle: angle)
        handle.frame = drawHandle(ctx: ctx!, atPoint: handleCenter, handle: handle)
        
        // Draw labels
        drawLabels(ctx: ctx!)
        
        // Rotate slider
        self.transform = getRotationalTransform()
        for view in subviews {      // cancel rotation on all subviews added by the user
            view.transform = getRotationalTransform().inverted()
        }
        
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard event != nil else {
            return false
        }
        
        if pointInsideHandle(point, handleCenter: pointOnCircleAt(angle: angle)) {
            
            return true
        }
        else {
            return pointInsideCircle(point)
        }
    }
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        if pointInsideHandle(location, handleCenter: pointOnCircleAt(angle: angle)) {
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
    
    internal func drawLine(ctx: CGContext) {
        unfilledColor.set()
        // Draw unfilled circle
        drawUnfilledCircle(ctx: ctx, center: centerPoint, radius: calculatedRadius, lineWidth: CGFloat(lineWidth), maximumAngle: maximumAngle, lineCap: unfilledLineCap)
        
        filledColor.set()
        // Draw filled circle
        drawArc(ctx: ctx, center: centerPoint, radius: calculatedRadius, lineWidth: CGFloat(lineWidth), fromAngle: 0, toAngle: CGFloat(angle), lineCap: filledLineCap)
    }
    
    internal func drawHandle(ctx: CGContext, atPoint handleCenter: CGPoint, handle: MSCircularSliderHandle) -> CGRect {
        ctx.saveGState()
        var frame: CGRect!
        
        // Highlight == 0.9 alpha
        let calculatedHandleColor = handle.isHighlightable && handle.isPressed ? handleColor.withAlphaComponent(0.9) : handleColor
        
        // Handle color calculation
        if handleType == .doubleCircle {
            calculatedHandleColor.set()
            drawFilledCircle(ctx: ctx, center: handleCenter, radius: 0.25 * handleDiameter)
            
            calculatedHandleColor.withAlphaComponent(0.7).set()
            
            frame = drawFilledCircle(ctx: ctx, center: handleCenter, radius: 0.5 * handleDiameter)
        }
        else {
            calculatedHandleColor.set()
            
            frame = drawFilledCircle(ctx: ctx, center: handleCenter, radius: 0.5 * handleDiameter)
        }
        
        
        ctx.saveGState()
        return frame
    }
    
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
    
    @discardableResult
    private func drawFilledCircle(ctx: CGContext, center: CGPoint, radius: CGFloat) -> CGRect {
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        ctx.fillEllipse(in: frame)
        return frame
    }
    
    internal func drawUnfilledCircle(ctx: CGContext, center: CGPoint, radius: CGFloat, lineWidth: CGFloat, maximumAngle: CGFloat, lineCap: CGLineCap) {
        
        drawArc(ctx: ctx, center: center, radius: radius, lineWidth: lineWidth, fromAngle: 0, toAngle: maximumAngle, lineCap: lineCap)
    }
    
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
    
    private func pointOn(radius: CGFloat, angle: CGFloat) -> CGPoint {
        var result = CGPoint()
        
        let cartesianAngle = CGFloat(toCartesian(toRad(Double(angle))))
        result.y = round(radius * sin(cartesianAngle))
        result.x = round(radius * cos(cartesianAngle))
        
        return result
    }
    
    internal func pointOnCircleAt(angle: CGFloat) -> CGPoint {
        let offset = pointOn(radius: calculatedRadius, angle: angle)
        return CGPoint(x: centerPoint.x + offset.x, y: centerPoint.y + offset.y)
    }
    
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
    
    private func offsetForLabelAt(index: Int, withSize labelSize: CGSize) -> CGPoint {
        let percentageAlongCircle = fullCircle ? ((100.0 / CGFloat(labels.count)) * CGFloat(index)) / 100.0 : ((100.0 / CGFloat(labels.count - 1)) * CGFloat(index)) / 100.0
        let labelDegrees = percentageAlongCircle * maximumAngle
        
        let radialDistance = labelInwardsDistance + labelOffset
        let inwardOffset = pointOn(radius: radialDistance, angle: CGFloat(labelDegrees))
        
        return CGPoint(x: -labelSize.width * 0.5 + inwardOffset.x, y: -labelSize.height * 0.5 + inwardOffset.y)
    }
    
    private func degreesFor(arcLength: CGFloat, onCircleWithRadius radius: CGFloat, withMaximumAngle degrees: CGFloat) -> CGFloat {
        let totalCircumference = CGFloat(2 * Double.pi) * radius
        
        let arcRatioToCircumference = arcLength / totalCircumference
        
        return degrees * arcRatioToCircumference
    }
    
    private func pointInsideCircle(_ point: CGPoint) -> Bool {
        let p1 = centerPoint
        let p2 = point
        let xDist = p2.x - p1.x
        let yDist = p2.y - p1.y
        let distance = sqrt((xDist * xDist) + (yDist * yDist))
        return distance < calculatedRadius + CGFloat(lineWidth) * 0.5
    }
    
    internal func pointInsideHandle(_ point: CGPoint, handleCenter: CGPoint) -> Bool {
        let handleRadius = max(handleDiameter, 44.0) * 0.5  // 44 points as per Apple's design guidelines
        
        return point.x >= handleCenter.x - handleRadius && point.x <= handleCenter.x + handleRadius && point.y >= handleCenter.y - handleRadius && point.y <= handleCenter.y + handleRadius
    }
    
    //================================================================================
    // CONTROL METHODS
    //================================================================================
    
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
    
    private func snapHandle() {
        // Snapping calculation
        // TODO: eliminate mutual-exclusion - use same minDist for both labels and markings to snap to nearest label or marking
        var fixedAngle = 0.0 as CGFloat
        
        if angle < 0 {
            fixedAngle = -angle
        }
        else {
            fixedAngle = maximumAngle - angle
        }
        
        if snapToLabels {
            var minDist = maximumAngle
            var newAngle = 0.0 as CGFloat
            
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
            var minDist = maximumAngle
            var newAngle = 0.0 as CGFloat
            
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
    
    internal func angleFrom(value: Double) -> CGFloat {
        return (CGFloat(value) * maximumAngle) / CGFloat(maximumValue - minimumValue)
    }
    
    internal func valueFrom(angle: CGFloat) -> Double {
        return (maximumValue - minimumValue) * Double(angle) / Double(maximumAngle)
    }
    
    private func toRad(_ degrees: Double) -> Double {
        return ((Double.pi * degrees) / 180.0)
    }
    
    private func toDeg(_ radians: Double) -> Double {
        return ((180.0 * radians) / Double.pi)
    }
    
    internal func square(_ value: Double) -> Double {
        return value * value
    }
    
    private func toCompass(_ cartesianRad: Double) -> Double {
        return cartesianRad + (Double.pi / 2)
    }
    
    private func toCartesian(_ compassRad: Double) -> Double {
        return compassRad - (Double.pi / 2)
    }
    
    private func sizeOf(string: String, withFont font: UIFont) -> CGSize {
        let attributes = [NSAttributedStringKey.font: font]
        return NSAttributedString(string: string, attributes: attributes).size()
    }
    
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


