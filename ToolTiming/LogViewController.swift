//
//  LogViewController.swift
//  ToolTiming
//
//  Created by Bradley Zellman on 12/26/16.
//  Copyright © 2016 Bradley Zellman. All rights reserved.
//

import Cocoa



class LogViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate {
    
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
    var tableRowAndProjectDictionary: [Int: ProjectDetails] = [:]
    let toggleLogNotificationKey = "toggleLogNotificationKey"
    var selectedRow : Int = 0
    
    
    @IBAction func deleteItemPressed(_ sender: Any) {
        let projectToDelete = tableRowAndProjectDictionary[selectedRow]
        managedContext.delete(projectToDelete!)
        
        do {
            try managedContext.save()
            
            print("saved")
        } catch {
            fatalError("Failure to save context: \(error)")
        }

        fetchItems()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear() {
        fetchItems()
    }
    
    
    func fetchItems(){
        let projectsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ProjectDetails")
        projectsFetch.sortDescriptors = [NSSortDescriptor(key: "date_and_time", ascending: false)]
        
        do {
            let fetchedProjectDetails = try managedContext.fetch(projectsFetch)
            fetchedDetails = fetchedProjectDetails as! [NSManagedObject]
            print("fetched")
            
            addProjectToProjustRowDictionary()
            tableView.reloadData()
            print("reloaded")
        } catch {
            fatalError("Failure to fetch Context: \(error)")
        }
    }
    
    func addProjectToProjustRowDictionary() {
        
        var projectIntToAddToDictionary = 0
        let projectCount = fetchedDetails.count - 1
        
        for projectIndex in 0...projectCount{
            let project : ProjectDetails = fetchedDetails[projectIndex] as! ProjectDetails
            tableRowAndProjectDictionary[projectIntToAddToDictionary] = project
            projectIntToAddToDictionary += 1

        }
        
        print(tableRowAndProjectDictionary)
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
                let timeValueString = timeValuefloat.description
//                print("The time value string is \(timeValueString)")
                
                
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        print(tableView.selectedRow)
        selectedRow = tableView.selectedRow
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        
        let directoryToSave = chooseSaveDirectory()
        let exportString = createExportString()
        
        writeDataStringToFile(dataString: exportString, urlPath: directoryToSave)
    }
    
    
    @IBAction func closedButtonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: toggleLogNotificationKey), object: self)
    }
    
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fetchedDetails.count
    }
    
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        var projectName : String
        
       
        // get the "Item" for the row
        let project = fetchedDetails[row] as! ProjectDetails
        
        let taskDescription = findTaskFromProjectDetail(project: project)
        print(taskDescription.count)
        
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
            if taskDescription.count >= 1  {
                text = taskDescription[0]
            } else {
                text = "N/A"
            }
            
            cellIdentifier = CellIdentifiers.TaskCell
        }
        else if tableColumn == tableView.tableColumns[2] {
            if taskDescription.count >= 2 {
                text = taskDescription[1]
            } else {
                text = "N/A"
            }
            
            
            cellIdentifier = CellIdentifiers.TimeCell
        }
        else if tableColumn == tableView.tableColumns[3] {
            if taskDescription.count >= 3  {
                text = taskDescription[2]
            } else {
                text = "N/A"
            }
            
            cellIdentifier = CellIdentifiers.DateCell
        }
        else if tableColumn == tableView.tableColumns[4] {
            if taskDescription.count >= 4  {
                text = taskDescription[3]
            } else {
                text = "N/A"
            }
            
            cellIdentifier = CellIdentifiers.DescCell
        }

        
        // Set the Cell
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    // MARK: Export Functions
    
    func createExportString() -> String {
        
        print(tableRowAndProjectDictionary.keys)
        var export: String! = "Project Name, Date, Unbillable, General Communication, Scheduled Meetings, QA, Test Builds, Troubleshooting, Development Team Consultation, Web Design, Graphics, Design, Data Import, Internal Development, Technical Support,  Marketing, Other, Total, Description \n"
        
        
        for project in fetchedDetails {
            let projectObject = project as! ProjectDetails
            
            
            var projectName = "N/A"
            if projectObject.project?.name != nil {
                projectName = (projectObject.project?.name)!
            }
            
            export.append(projectName)
            export.append(",")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.short
            let dateToConvert = projectObject.date_and_time as NSDate!
            let projectDate = dateFormatter.string(from: dateToConvert as! Date)
            
            let date_and_time = projectDate
            export.append(date_and_time)
            export.append(",")
            export.append(" ,")
            
            let general_comm = projectObject.general_comm.description
            export.append(general_comm)
            export.append(",")
            
            let scheduled_meetings = projectObject.scheduled_meetings.description
            export.append(scheduled_meetings)
            export.append(",")
            
            let qa = projectObject.qa.description
            export.append(qa)
            export.append(",")
            
            let test_builds = projectObject.test_builds.description
            export.append(test_builds)
            export.append(",")
            
            let troubleshooting = projectObject.troubleshooting.description
            export.append(troubleshooting)
            export.append(",")
            
            let dev_tem_consult = projectObject.dev_tem_consult.description
            export.append(dev_tem_consult)
            export.append(",")
            
            let web_dev = projectObject.web_dev.description
            export.append(web_dev)
            export.append(",")
            
            let graphics = projectObject.graphics.description
            export.append(graphics)
            export.append(",")
            
            let design = projectObject.design.description
            export.append(design)
            export.append(",")
            
            let data_import = projectObject.data_import.description
            export.append(data_import)
            export.append(",")
            
            let internal_development = projectObject.development.description
            export.append(internal_development)
            export.append(",")
            
            let tech_support = projectObject.tech_support.description
            export.append(tech_support)
            export.append(",")
            
            let marketing = projectObject.marketing.description
            export.append(marketing)
            export.append(",")
            
            let other = projectObject.other.description
            export.append(other)
            export.append(",")
            
            export.append(" ,")
            
            let desc = projectObject.desc
            export.append(desc!)
//            export.append(",")
            export.append("\n")
            

            
//            export += projectName + "," + data_import + "," + design + "," + dev_tem_consult + "," + development + "," + general_comm + "," + graphics + "," + marketing + "," + other + "," + qa + "," + scheduled_meetings + "," + tech_support + "," + test_builds + "," + troubleshooting + "," + desc + "," + web_dev + "," + date_and_time + "\n"
        }
        
        
        
        return export
        
        
    }
    
    
    func chooseSaveDirectory() -> URL {
        let fileDialog: NSOpenPanel = NSOpenPanel()
        fileDialog.title = "Choose an output directory"
        fileDialog.canChooseDirectories = true
        fileDialog.canChooseFiles = false
        fileDialog.canCreateDirectories = true
        fileDialog.allowsMultipleSelection = false
        fileDialog.level = 10
        
        fileDialog.runModal()
        
        let urlToReturn = fileDialog.urls.first
        return urlToReturn!
        
    }
    
    
    func writeDataStringToFile(dataString: String, urlPath: URL){
        let fileName = "Timesheet Export.csv"
        let dataString = dataString
        
            let path = urlPath.appendingPathComponent(fileName)
            
            //writing
            do {
                try dataString.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {/* error handling here */}

        
    }
    
    
}
