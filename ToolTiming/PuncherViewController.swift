//
//  PuncherViewController.swift
//  ToolTiming
//
//  Created by Bradley Zellman on 12/20/16.
//  Copyright © 2016 Bradley Zellman. All rights reserved.
//

import Cocoa


class PuncherViewController: NSViewController {
    
    

   
    
    @IBOutlet weak var projectPopUpButton: NSPopUpButton!
    @IBOutlet weak var taskPopUpButton: NSPopUpButton!
    @IBOutlet weak var timePopUpButton: NSPopUpButton!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var newProjectButton: NSButton!
    
    let projectPopover = NSPopover()
    let toggleNotificationKey = "toggleNotificationKey"
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    
    
    
    let standardTimeArray = ["0.25", "0.50", "0.75", "1.00", "1.25", "1.50", "1.75", "2.00"]
    let projectDetailsDictionary:NSDictionary = ["Data Import": "data_import",
                                  "Description": "desc",
                                  "Design": "design",
                                  "Development Team Consultation": "dev_tem_consult",
                                  "Internal Development": "development",
                                  "General Communication": "general_comm",
                                  "Graphics":"graphics",
                                  "Marketing": "marketing",
                                  "Other": "other",
                                  "QA": "qa",
                                  "Scheduled Meetings": "scheduled_meetings",
                                  "Tech Support": "tech_support",
                                  "Test Build Assembly": "test_builds",
                                  "Troubleshooting": "troubleshooting",
                                  "Web Sites": "web_dev"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded")
        self.setPopUpButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(PuncherViewController.toggleAddProject), name: NSNotification.Name(rawValue: toggleNotificationKey), object: nil)
        
        projectPopover.contentViewController = AddProjectViewController(nibName: "AddProjectViewController", bundle: nil)
        
    }
    
    
    override func viewWillAppear() {
        self.fetchItems()
        setProjectsButton()
    }
    
    func setPopUpButtons() {
        // lists all available tasks
       let  taskNameArray = projectDetailsDictionary.allKeys
        for name in taskNameArray{
            taskPopUpButton.addItem(withTitle: name as! String)
        }
        
        for time in standardTimeArray{
            timePopUpButton.addItem(withTitle: time)
        }
        
        
    }
    
    
    
    func fetchItems(){
        let managedContex = appDelegate.managedObjectContext
        let projectsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectDetails")
        projectsFetch.sortDescriptors = [NSSortDescriptor(key: "date_and_time", ascending: true)]
        
        do {
            let fetchedProjectDetails = try managedContex.fetch(projectsFetch)
            print("fetched")
            
            for projectDetails in fetchedProjectDetails {
                let project = projectDetails as! ProjectDetails
                print(project.project?.name!)
                print(project)
            }
            
        } catch {
            fatalError("Failure to fetch Context: \(error)")
        }
        
    }
    
    func setProjectsButton(){
        let managedContex = appDelegate.managedObjectContext
        let projectsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        
        projectsFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let fetchedProjects = try managedContex.fetch(projectsFetch)
            
            for project in fetchedProjects {
                projectPopUpButton.addItem(withTitle: (project as! Project).name!)
            }
            
            
        } catch {
            fatalError("Failure to fetch Context: \(error)")
        }
        
    }

    

    
    func toggleAddProject() {
        print("Toggeld")
        if projectPopover.isShown {
            projectPopover.performClose(Any?.self)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        print("Button Pressed")
        
        let managedContex = appDelegate.managedObjectContext
        
        //Get Current Project
        
        let projectsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        projectsFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        print(projectPopUpButton.title)
        projectsFetch.predicate = NSPredicate(format: "name == %@", projectPopUpButton.title)
        do {
            let fetchedProject = try managedContex.fetch(projectsFetch)
            for project in fetchedProject {
                let project = project as! Project
                print("fetching project Name")
                print(project.name!)
                
                
                ///
                
                let project_details = NSEntityDescription.insertNewObject(forEntityName: "ProjectDetails", into: managedContex) as! ProjectDetails
                
                // Set Timestamp
                project_details.date_and_time = NSDate()
                
                //Set description
                let descString = descriptionTextField.stringValue
                project_details.desc = descString
                project_details.project = project
                
                // Set for time, entity and project detail
                let item = taskPopUpButton.selectedItem?.title
                let keyForEntity = projectDetailsDictionary[item!]
                print(keyForEntity!)
                let timeFloat = Float((timePopUpButton.selectedItem?.title)!)
                let myNumber = NSNumber(value: timeFloat!)
                project_details.setValue(myNumber, forKey:keyForEntity as! String)
                
                do {
                    try managedContex.save()
                    print("saved")
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
                
                ///
                
            }
        } catch {
            fatalError("Failure to fetch Context: \(error)")
        }
        
        


        
    }
    
    @IBAction func addProjectButtonPressed(_ sender: Any) {
        projectPopover.show(relativeTo: newProjectButton.bounds, of: newProjectButton, preferredEdge: NSRectEdge.minY)
    }
    
}
