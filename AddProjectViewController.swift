//
//  AddProjectViewController.swift
//  ToolTiming
//
//  Created by Bradley Zellman on 12/21/16.
//  Copyright © 2016 Bradley Zellman. All rights reserved.
//

import Cocoa

class AddProjectViewController: NSViewController {
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    let toggleNotificationKey = "toggleNotificationKey"

    @IBOutlet weak var projectNameTextField: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func saveNewProject() {
        let managedContex = appDelegate.managedObjectContext
        
        let newProjectName = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedContex) as! Project
        
        
        //Set Project Name
        let projectNameString = projectNameTextField.stringValue
        
        newProjectName.name = projectNameString
        
        do {
            try managedContex.save()
            print("saved")
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("Pressed")
        saveNewProject()
        NotificationCenter.default.post(name: Notification.Name(rawValue: toggleNotificationKey), object: self)
        
    }
    
    
    
    
    
}
