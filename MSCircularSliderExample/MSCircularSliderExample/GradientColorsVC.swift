//
//  GradientColorsVC.swift
//  MSCircularSliderExample
//
//  Created by Mohamed Shahawy on 10/2/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

class GradientColorsVC: UIViewController, MSCircularSliderDelegate, ColorPickerDelegate {
    // Outlets
    @IBOutlet weak var slider: MSGradientCircularSlider!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var firstColorBtn: UIButton!
    @IBOutlet weak var secondColorBtn: UIButton!
    @IBOutlet weak var thirdColorBtn: UIButton!
    
    
    // Members
    var currentColorPickTag = 0
    var colorPicker: ColorPickerView?
    
    // Action
    @IBAction func colorPickAction(_ sender: UIButton) {
        currentColorPickTag = sender.tag
        
        colorPicker?.isHidden = false
        
    }
    
    // Init
    override func viewDidLoad() {
        super.viewDidLoad()

        colorPicker = ColorPickerView(frame: CGRect(x: 0, y: view.center.y - view.frame.height * 0.3 / 2.0, width: view.frame.width, height: view.frame.height * 0.3))
        colorPicker?.isHidden = true
        colorPicker?.delegate = self
        view.addSubview(colorPicker!)
        
        valueLbl.text = String(format: "%.1f", (slider?.currentValue)!)
        
        slider.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Delegate Methos
    func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
        valueLbl.text = String(format: "%.1f", value)
    }
    
    func colorPickerTouched(sender: ColorPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizerState) {
        switch currentColorPickTag {
        case 0:
            firstColorBtn.setTitleColor(color, for: .normal)
            slider?.changeColor(at: 0, newColor: color)
        case 1:
            secondColorBtn.setTitleColor(color, for: .normal)
            slider?.changeColor(at: 1, newColor: color)
        case 2:
            thirdColorBtn.setTitleColor(color, for: .normal)
            slider?.changeColor(at: 2, newColor: color)
        default:
            break
        }
        
        colorPicker?.isHidden = true
    }
}
