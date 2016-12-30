//
//  LogViewController.swift
//  ToolTiming
//
//  Created by Bradley Zellman on 12/26/16.
//  Copyright © 2016 Bradley Zellman. All rights reserved.
//

import Cocoa



class LogViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let ProjectCell = "ProjectCellID"
        static let TaskCell = "TaskCellID"
        static let TimeCell = "TimeCellID"
        static let DateCell = "DateCellID"
        static let DescCell = "DescCellID"
        
    }

    @IBOutlet weak var tableView: NSTableView!
    
    
    var managedContext = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    var fetchedDetails = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
        fetchItems()
    }
    
    
    func fetchItems(){
        let projectsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectDetails")
        projectsFetch.sortDescriptors = [NSSortDescriptor(key: "date_and_time", ascending: true)]
        
        do {
            let fetchedProjectDetails = try managedContext.fetch(projectsFetch)
            fetchedDetails = fetchedProjectDetails as! [NSManagedObject]
            print("fetched")
            tableView.reloadData()
            print("reloaded")
        } catch {
            fatalError("Failure to fetch Context: \(error)")
        }
    }
    
    // Find out what task was logged by searching for the attribut with a time value above 0 and return the attribute and float value Return Array [Task Name, Time for Task, Date and Time, Project Description]
    func findTaskFromProjectDetail(project: ProjectDetails) -> Array<String> {
        
        /// Create Signleton from this upon refactor
        let projectDetailsDictionary:NSDictionary = ["Data Import": "data_import",
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
        
        
        let taskArray = projectDetailsDictionary.allValues
        
        for value in taskArray{
            let projectValue  = project.value(forKey: value as! String)
            
            //set and return array in loop to prevent uncessciary itteration
            if projectValue as? Float != nil && projectValue as! Float > 0.00 {
                
                //Set Project Details Type
                let humanTaskNameString = projectDetailsDictionary.allKeys(for: value)
                
                //Set Project Time Value to String
                let timeValuefloat = projectValue as! Float
                print("The time value float is \(timeValuefloat)")
                let timeValueString = timeValuefloat.description
                print("The time value string is \(timeValueString)")
                
                
                //Set Project Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.short
                let dateToConvert = project.date_and_time as NSDate!
                let projectDate = dateFormatter.string(from: dateToConvert as! Date)
                print(projectDate)
                
                //Set Project Description
                var projectDescription = ""
                if project.desc != nil {
                    projectDescription = project.desc!
                } else {
                    projectDescription = ""
                }
                
                let returnArray = [humanTaskNameString.first!, timeValueString, projectDate, projectDescription]
                return returnArray as! Array<String>
            }
        }
        return []
    }
    
    
    
    
    
    @IBAction func closedButtonPressed(_ sender: Any) {
        dismissViewController(self)
    }
    
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print(fetchedDetails.count)
        return fetchedDetails.count
    }
    
    

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // get an NSTableCellView with an identifier that is the same as the identifier for the column
        // NOTE: you need to set the identifier of both the Column and the Table Cell View
        // in this case the columns are "name" and "value"
        
        var text: String = ""
        var cellIdentifier: String = ""
        var projectName : String
        
       
        // get the "Item" for the row
        let project = fetchedDetails[row] as! ProjectDetails
        
        let task_description = findTaskFromProjectDetail(project: project)
        
        if tableColumn == tableView.tableColumns[0] {
            if project.project?.name != nil {
                projectName = (project.project?.name)!
                text = projectName
            } else {
                text = "N/A"
            }
            cellIdentifier = CellIdentifiers.ProjectCell
        }
          else if tableColumn == tableView.tableColumns[1] {
            text = task_description[0]
            cellIdentifier = CellIdentifiers.TaskCell
        }
        else if tableColumn == tableView.tableColumns[2] {
            text = task_description[1]
            cellIdentifier = CellIdentifiers.TimeCell
        }
        else if tableColumn == tableView.tableColumns[3] {
            text = task_description[2]
            cellIdentifier = CellIdentifiers.DateCell
        }
        else if tableColumn == tableView.tableColumns[4] {
            text = task_description[3]
            cellIdentifier = CellIdentifiers.DescCell
        }

        
        // Set the Cell
            
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func createExportString() -> String {
//
//        var projectName: String?
//        var data_import: String?
//        var design: String?
//        var dev_tem_consult: String?
//        var development: String?
//        var general_comm: String?
//        var graphics: String?
//        var marketing: String?
//        var other: String?
//        var qa: String?
//        var scheduled_meetings: String?
//        var tech_support: String?
//        var test_builds: String?
//        var troubleshooting: String?
//        var desc: String?
//        var web_dev: String?
//        var date_and_time: String?
//        
        var export: String! = NSLocalizedString("Project Name, Data Import, Design, Development Team Consult, Development, General Communication, Graphics, Marketing, Other, QA, Scheduled Meeting, Technical Support, Test Builds, Troubleshooting, Description, Web Development, Date And Time \n", comment: "")
        
        
        
        for project in fetchedDetails {
            let projectObject = project as! ProjectDetails

            
            export += "\(projectObject.project?.name)" + "," + "\(projectObject.data_import)" + "," + "\(projectObject.design)" + "," + "\(projectObject.dev_tem_consult)" + "," + "\(projectObject.development)" + "," + "\(projectObject.general_comm)" + "," + "\(projectObject.graphics)" + "," + "\(projectObject.marketing)" + "," + "\(projectObject.other)" + "," + "\(projectObject.qa)" + "," + "\(projectObject.scheduled_meetings)" + "," + "\(projectObject.tech_support)" + "," + "\(projectObject.test_builds)" + "," + "\(projectObject.troubleshooting)" + "," + "\(projectObject.desc)" + "," + "\(projectObject.web_dev)" + "," + "\(projectObject.date_and_time)" + "\n"
        }
        
//        print("This is what the app will export: \(export)")
        return "BOOP"
    }
    
    
}
