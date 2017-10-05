//
//  DoubleHandleVC.swift
//  MSCircularSliderExample
//
//  Created by Mohamed Shahawy on 10/2/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

class DoubleHandleVC: UIViewController, MSDoubleHandleCircularSliderDelegate, ColorPickerDelegate {
    
    // Outlets
    @IBOutlet weak var slider: MSDoubleHandleCircularSlider!
    @IBOutlet weak var valuesLbl: UILabel!
    @IBOutlet weak var handleTypeLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var unfilledColorBtn: UIButton!
    @IBOutlet weak var filledColorBtn: UIButton!
    @IBOutlet weak var handleColorBtn: UIButton!
    @IBOutlet weak var minDistSlider: UISlider!
    
    
    // Members
    var currentColorPickTag = 0
    var colorPicker: ColorPickerView?
    
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
    
    @IBAction func minDistanceValueChanged(_ sender: UISlider) {
        slider.minimumHandlesDistance = CGFloat(sender.value)
        descriptionLbl.text = getDescription()
    }
    
    // Init
    override func viewDidLoad() {
        super.viewDidLoad()

        handleTypeLbl.text = handleTypeStrFrom(slider.handleType)
        
        colorPicker = ColorPickerView(frame: CGRect(x: 0, y: view.center.y - view.frame.height * 0.3 / 2.0, width: view.frame.width, height: view.frame.height * 0.3))
        colorPicker?.isHidden = true
        colorPicker?.delegate = self
        view.addSubview(colorPicker!)
        
        slider.delegate = self
        
        valuesLbl.text = String(format: "%.1f, %.1f", slider.currentValue, slider.secondCurrentValue)
        
        minDistSlider.maximumValue = Float(CGFloat.pi * slider.calculatedRadius * slider.maximumAngle / 360.0)
        
        descriptionLbl.text = getDescription()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Support Methods
    func handleTypeStrFrom(_ type: MSCircularSliderHandleType) -> String {
        switch type {
        case .SmallCircle:
            return "Small Circle"
        case .MediumCircle:
            return "Medium Circle"
        case .LargeCircle:
            return "Large Circle"
        case .DoubleCircle:
            return "Double Circle"
        }
    }
    
    func getDescription() -> String {
        return "Maximum Angle: \(String(format: "%.1f", slider.maximumAngle))°\nMinimum Distance Between Handles: \(String(format: "%.1f", slider.minimumHandlesDistance))"
    }
    
    // Delegate Methods
    func circularSlider(_ slider: MSCircularSlider, valueChangedTo firstValue: Double, secondValue: Double, isFirstHandle: Bool?, fromUser: Bool) {
        valuesLbl.text = String(format: "%.1f, %.1f", firstValue, secondValue)
    }
    
    func colorPickerTouched(sender: ColorPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizerState) {
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

}
