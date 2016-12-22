//
//  AddProjectPopOverController.swift
//  ToolTiming
//
//  Created by Bradley Zellman on 12/21/16.
//  Copyright © 2016 Bradley Zellman. All rights reserved.
//

import Cocoa

class AddProjectPopOverController: NSViewController {

    weak var delegate : PuncherViewControllerDelegate?
    

    
    @IBAction func addButtonPressed(_ sender: Any) {
         delegate?.toggleAddProject()
    }
   }
