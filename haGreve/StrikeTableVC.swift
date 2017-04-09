//
//  ViewController.swift
//  haGreve
//
//  Created by Vasco Gomes on 09/04/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import UIKit
import CoreData

class StrikeTableVC: UITableViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet var strikeTableView: UITableView!
    
    var controller : NSFetchedResultsController<Strike>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check if internet is available, if it is, delete all records from database and retrieve most recent ones from web service
        if(DataService.isInternetAvailable()){
            deleteAllRecords()
            DataService.downloadStrikes()
        }
        
        strikeTableView.delegate = self
        strikeTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get data from database
        attemptFetch()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(controller != nil)
        {
            if let sections = controller.sections
            {
                //if there is anything it will return its number
                let sectionInfo = sections[section]
                return sectionInfo.numberOfObjects
            }
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if(controller != nil)
        {
            if let sections = controller.sections
            {
                return sections.count
            }
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //creating a cell passing the itemCell and the indexPath
        let cell =  tableView.dequeueReusableCell(withIdentifier: "StrikeCell", for: indexPath) as! StrikeCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func configureCell(cell : StrikeCell, indexPath : NSIndexPath)
    {
        let strike = controller.object(at: (indexPath as NSIndexPath) as IndexPath)
        
        cell.configureCell(strike: strike)
    }
    
    //fetch data from database
    func attemptFetch()
    {
        let fetchRequest : NSFetchRequest<Strike> = Strike.fetchRequest()
        
        //the default is sorting by date
        let dateSort = NSSortDescriptor(key: "startDate", ascending: false)
        
        fetchRequest.sortDescriptors = [dateSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:context , sectionNameKeyPath: "strikeDescription", cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        //a fetch can fail so we have to do a do catch
        do{
            try controller.performFetch()
        } catch{
            let error = error as NSError!
            print("\(error!)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        strikeTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        strikeTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //this will be called when a section is changed, thus managing section insertion and deletion
        switch(type)
        {
        case NSFetchedResultsChangeType.insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            strikeTableView.insertSections(sectionIndexSet as IndexSet, with: .fade)
            
            break;
            
        case NSFetchedResultsChangeType.delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            
            strikeTableView.deleteSections(sectionIndexSet as IndexSet,with: .fade)
            break;
            
        default:
            break;
        }
    }

    
    //listens for when we want to make a change
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type)
        {
        case.insert:
            if let indexPath = newIndexPath{
                strikeTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        case.delete :
            if let indexPath = indexPath{
                strikeTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
            
        case.update:
            if let indexPath = indexPath{
                let cell = strikeTableView.cellForRow(at: indexPath) as! StrikeCell
                
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
            
        //this is when its been dragged
        case.move :
            if let indexPath = indexPath {
                //delete at the old location
                strikeTableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath{
                strikeTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }

    func deleteAllRecords() {
        let deleteSubmitterFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Submitter")
        let deleteSubmittersRequest = NSBatchDeleteRequest(fetchRequest: deleteSubmitterFetchRequest)
        
        let deleteCompanyFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Company")
        let deleteCompanysRequest = NSBatchDeleteRequest(fetchRequest: deleteCompanyFetchRequest)
        
        let deleteStrikeFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Strike")
        let deleteStrikeRequest = NSBatchDeleteRequest(fetchRequest: deleteStrikeFetchRequest)
        
        do {
            try context.execute(deleteSubmittersRequest)
            try context.execute(deleteCompanysRequest)
            try context.execute(deleteStrikeRequest)
            try context.save()
            print("Succefully deleted all records in database")
        } catch {
            print ("ERROR: Error deleting all data from Core Data")
        }
    }
}

