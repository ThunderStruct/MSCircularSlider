//
//  SliderPropertiesVC.swift
//  MSCircularSliderExample
//
//  Created by Mohamed Shahawy on 10/2/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

class SliderProperties: UIViewController, MSCircularSliderDelegate, ColorPickerDelegate {
    // Outlets
    @IBOutlet weak var slider: MSCircularSlider!
    @IBOutlet weak var handleTypeLbl: UILabel!
    @IBOutlet weak var unfilledColorBtn: UIButton!
    @IBOutlet weak var filledColorBtn: UIButton!
    @IBOutlet weak var handleColorBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    
    // Members
    var currentColorPickTag = 0
    var colorPicker: ColorPickerView?
    var animationTimer: Timer?
    var animationReversed = false
    
    // Actions
    @IBAction func handleTypeValueChanged(_ sender: UIStepper) {
        slider.handleType = MSCircularSliderHandleType(rawValue: Int(sender.value)) ?? slider.handleType
        handleTypeLbl.text = handleTypeStrFrom(slider.handleType)
    }
    
    @IBAction func maxAngleAction(_ sender: UISlider) {
        slider.maximumAngle = CGFloat(sender.value)
        descriptionLbl.text = getDescription()
    }
    
    @IBAction func colorPickAction(_ sender: UIButton) {
        currentColorPickTag = sender.tag
        
        colorPicker?.isHidden = false
    }
    
    @IBAction func rotationAngleAction(_ sender: UISlider) {
        descriptionLbl.text = getDescription()
        if sender.value == 0 {
            slider.rotationAngle = nil
            return
        }
        slider.rotationAngle = CGFloat(sender.value)
    }
    
    @IBAction func lineWidthAction(_ sender: UIStepper) {
        slider.lineWidth = Int(sender.value)
        descriptionLbl.text = getDescription()
    }
    
    // Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleTypeLbl.text = handleTypeStrFrom(slider.handleType)
        
        colorPicker = ColorPickerView(frame: CGRect(x: 0, y: view.center.y - view.frame.height * 0.3 / 2.0, width: view.frame.width, height: view.frame.height * 0.3))
        colorPicker?.isHidden = true
        colorPicker?.delegate = self
        
        slider.delegate = self
        
        valueLbl.text = String(format: "%.1f", slider.currentValue)
        
        descriptionLbl.text = getDescription()
        
        view.addSubview(colorPicker!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Slider animation
        animateSlider()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Support Methods
    func handleTypeStrFrom(_ type: MSCircularSliderHandleType) -> String {
        switch type {
        case .smallCircle:
            return "Small Circle"
        case .mediumCircle:
            return "Medium Circle"
        case .largeCircle:
            return "Large Circle"
        case .doubleCircle:
            return "Double Circle"
        }
    }
    
    func getDescription() -> String {
        let rotationAngle = slider.rotationAngle == nil ? "Computed" : String(format: "%.1f", slider.rotationAngle!) + "°"
        return "Maximum Angle: \(String(format: "%.1f", slider.maximumAngle))°\nLine Width: \(slider.lineWidth)\nRotation Angle: \(rotationAngle)"
    }
    
    // Delegate Methods
    func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
        valueLbl.text = String(format: "%.1f", value)
    }
    
    func circularSlider(_ slider: MSCircularSlider, startedTrackingWith value: Double) {
        // optional delegate method
    }
    
    func circularSlider(_ slider: MSCircularSlider, endedTrackingWith value: Double) {
        // optional delegate method
    }
    
    func colorPickerTouched(sender: ColorPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        switch currentColorPickTag {
        case 0:
            unfilledColorBtn.setTitleColor(color, for: .normal)
            slider.unfilledColor = color
        case 1:
            filledColorBtn.setTitleColor(color, for: .normal)
            slider.filledColor = color
        case 2:
            handleColorBtn.setTitleColor(color, for: .normal)
            slider.handleColor = color
        default:
            break
        }
        
        colorPicker?.isHidden = true
    }
    
    func animateSlider() {
        animationTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSliderValue), userInfo: nil, repeats: true)
    }
    
    @objc func updateSliderValue() {
        slider.currentValue += animationReversed ? -1.0 : 1.0
        
        if slider.currentValue >= slider.maximumValue {
            animationTimer?.invalidate()
            // Reverse animation
            animationReversed = true
            animationTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSliderValue), userInfo: nil, repeats: true)
        }
        else if slider.currentValue <= slider.minimumValue && animationReversed {
            // Animation ended
            animationTimer?.invalidate()
        }
    }
}
