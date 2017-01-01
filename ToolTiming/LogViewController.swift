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
    
    
    
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        
        let directoryToSave = chooseSaveDirectory()
        let exportString = createExportString()
        
        writeDataStringToFile(dataString: exportString, urlPath: directoryToSave)
        
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
        var export: String! = "Project Name, Data Import, Design, Development Team Consult, Development, General Communication, Graphics, Marketing, Other, QA, Scheduled Meeting, Technical Support, Test Builds, Troubleshooting, Description, Web Development, Date And Time \n"
        
        
        
        for project in fetchedDetails {
            let projectObject = project as! ProjectDetails
            
            
            var projectName = "N/A"
            if projectObject.project?.name != nil {
                projectName = (projectObject.project?.name)!
            }
            
            export.append(projectName)
            export.append(",")
            
            let data_import = projectObject.data_import.description
            export.append(data_import)
            export.append(",")
            
            let design = projectObject.design.description
            export.append(design)
            export.append(",")
            
            let dev_tem_consult = projectObject.dev_tem_consult.description
            export.append(dev_tem_consult)
            export.append(",")
            
            let development = projectObject.development.description
            export.append(development)
            export.append(",")
            
            let general_comm = projectObject.general_comm.description
            export.append(general_comm)
            export.append(",")
            
            let graphics = projectObject.graphics.description
            export.append(graphics)
            export.append(",")
            
            let marketing = projectObject.marketing.description
            export.append(marketing)
            export.append(",")
            
            let other = projectObject.other.description
            export.append(other)
            export.append(",")
            
            let qa = projectObject.qa.description
            export.append(qa)
            export.append(",")
            
            let scheduled_meetings = projectObject.scheduled_meetings.description
            export.append(scheduled_meetings)
            export.append(",")
            
            let tech_support = projectObject.tech_support.description
            export.append(tech_support)
            export.append(",")
            
            let test_builds = projectObject.test_builds.description
            export.append(test_builds)
            export.append(",")
            
            let troubleshooting = projectObject.troubleshooting.description
            export.append(troubleshooting)
            export.append(",")
            
            let desc = projectObject.desc
            export.append(desc!)
            export.append(",")
            
            let web_dev = projectObject.web_dev.description
            export.append(web_dev)
            export.append(",")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.short
            let dateToConvert = projectObject.date_and_time as NSDate!
            let projectDate = dateFormatter.string(from: dateToConvert as! Date)
            
            let date_and_time = projectDate
            export.append(date_and_time)
            export.append("\n")
            

            
//            export += projectName + "," + data_import + "," + design + "," + dev_tem_consult + "," + development + "," + general_comm + "," + graphics + "," + marketing + "," + other + "," + qa + "," + scheduled_meetings + "," + tech_support + "," + test_builds + "," + troubleshooting + "," + desc + "," + web_dev + "," + date_and_time + "\n"
        }
        
        print("This is what the app will export: \(export)")
        return export
    }
    
//    func saveAndExport(exportString: String) {
//        let exportFilePath = NSTemporaryDirectory() + "export.csv"
//        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
//        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
////        var fileHandleError: NSError? = nil
//        var fileHandle: FileHandle? = nil
//        
//        do {
//            fileHandle = try FileHandle(forWritingTo: exportFileURL as URL)
//        } catch {
//            print("Error with fileHandle")
//        }
//        
//        if fileHandle != nil {
//            fileHandle!.seekToEndOfFile()
//            let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
//            fileHandle!.write(csvData!)
//            
//            fileHandle!.closeFile()
//            
////            let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
//
//        }
//    }
    
    func chooseSaveDirectory() -> URL {
        let fileDialog: NSOpenPanel = NSOpenPanel()
        fileDialog.title = "Choose an output directory"
        fileDialog.canChooseDirectories = true
        fileDialog.canChooseFiles = false
        fileDialog.canCreateDirectories = true
        fileDialog.allowsMultipleSelection = false
        
        fileDialog.runModal()
        
        let urlToReturn = fileDialog.urls.first
        return urlToReturn!
        
    }
    
    
    func writeDataStringToFile(dataString: String, urlPath: URL){
        let fileName = "Timesheet Export.csv"
        let dataString = dataString
        
//        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        
            let path = urlPath.appendingPathComponent(fileName)
            
            //writing
            do {
                try dataString.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {/* error handling here */}
            
            //reading
//            do {
//                let text2 = try String(contentsOf: path, encoding: String.Encoding.utf8)
//            }
//            catch {/* error handling here */}
//        }

        
    }
    
    
}
