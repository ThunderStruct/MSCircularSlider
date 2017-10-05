//
//  ExamplesMenu.swift
//  MSCircularSliderExample
//
//  Created by Mohamed Shahawy on 10/1/17.
//  Copyright © 2017 Mohamed Shahawy. All rights reserved.
//

import UIKit

class ExamplesMenu: UITableViewController {
    
    var lastSelectedTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.title = lastSelectedTitle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        lastSelectedTitle = (tableView.cellForRow(at: indexPath)?.textLabel?.text!)!
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "SliderPropertiesSegue", sender: self)
        case 1:
            performSegue(withIdentifier: "MarkersLabelsSegue", sender: self)
        case 2:
            performSegue(withIdentifier: "DoubleHandleSegue", sender: self)
        case 3:
            performSegue(withIdentifier: "GradientColorsSegue", sender: self)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

