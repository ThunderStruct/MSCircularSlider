//
//  MarkersLabelsVC.swift
//  MSCircularSliderExample
//
//  Created by Mohamed Shahawy on 10/2/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

class MarkersLabelsVC: UIViewController, MSCircularSliderDelegate, ColorPickerDelegate {
    // Outlets
    @IBOutlet weak var sliderView: UIView!  // frame reference
    @IBOutlet weak var markerCountLbl: UILabel!
    @IBOutlet weak var labelsColorBtn: UIButton!
    @IBOutlet weak var markersColorBtn: UIButton!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var snapToLabelSwitch: UISwitch!
    @IBOutlet weak var snapToMarkerSwitch: UISwitch!
    
    // Members
    var slider: MSCircularSlider?
    var currentColorPickTag = 0
    var colorPicker: ColorPickerView?
    
    // Actions
    @IBAction func labelsTextfieldDidChange(_ sender: UITextField) {
        let text = sender.text!
        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
            
            slider?.labels = text.components(separatedBy: ",")
        }
        else {
            slider?.labels.removeAll()
        }
    }
    
    @IBAction func markerCountStepperValueChanged(_ sender: UIStepper) {
        slider?.markerCount = Int(sender.value)
        markerCountLbl.text = "\(slider?.markerCount ?? 0) Marker\(slider?.markerCount == 1 ? "": "s")"
    }
    
    @IBAction func colorPickAction(_ sender: UIButton) {
        currentColorPickTag = sender.tag
        
        colorPicker?.isHidden = false
    }
    
    @IBAction func snapToLabelsValueChanged(_ sender: UISwitch) {
        slider?.snapToLabels = sender.isOn
        //snapToMarkerSwitch.setOn(false, animated: true) // mutually-exclusive
    }
    
    @IBAction func snapToMarkersValueChanged(_ sender: UISwitch) {
        slider?.snapToMarkers = sender.isOn
        //snapToLabelSwitch.setOn(false, animated: true)  // mutually-exclusive
    }
    
    
    // Init
    override func viewDidLoad() {
        super.viewDidLoad()

        // Slider programmatic instantiation
        slider = MSCircularSlider(frame: sliderView.frame)
        slider?.delegate = self
        view.addSubview(slider!)
        
        colorPicker = ColorPickerView(frame: CGRect(x: 0, y: view.center.y - view.frame.height * 0.3 / 2.0, width: view.frame.width, height: view.frame.height * 0.3))
        colorPicker?.isHidden = true
        colorPicker?.delegate = self
        view.addSubview(colorPicker!)
        
        valueLbl.text = String(format: "%.1f", (slider?.currentValue)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func colorPickerTouched(sender: ColorPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizerState) {
        switch currentColorPickTag {
        case 0:
            labelsColorBtn.setTitleColor(color, for: .normal)
            slider?.labelColor = color
        case 1:
            markersColorBtn.setTitleColor(color, for: .normal)
            slider?.markerColor = color
        default:
            break
        }
        
        colorPicker?.isHidden = true
    }

}
