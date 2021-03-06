//
//  ViewController.swift
//  haGreve
//
//  Created by Vasco Gomes on 09/04/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import UIKit
import CoreData

class StrikeTableVC: UITableViewController, NSFetchedResultsControllerDelegate, DateVCDelegate, CompanyVCDelegate {
    @IBOutlet var strikeTableView: UITableView!
    
    var filterDateAllSelected : Bool = true
    var filterCompanyAllSelected : Bool = true
    var beginDate : Date? = nil
    var endDate : Date? = nil
    var companySelected : Company? = nil
    
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
        
        //to reload the data
        strikeTableView.reloadData()
    }
    
    func sendDateVCData(dateAllSelected: Bool!, startDate: Date?, endDate: Date?){
        self.filterDateAllSelected = dateAllSelected
        
        //the dates received have the current hour. Set it to 0 in both StartDate and EndDate
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        /*START DATE*/
        var componentsStartDate = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: startDate!)
        
        componentsStartDate.hour = 0
        componentsStartDate.minute = 0
        componentsStartDate.second = 0
        
        self.beginDate = gregorian.date(from: componentsStartDate)!
        
        /*END DATE*/
        var componentsEndDate = gregorian.components([.year, .month, .day, .hour, .minute, .second], from: endDate!)
        
        componentsEndDate.hour = 0
        componentsEndDate.minute = 0
        componentsEndDate.second = 0
        
        self.endDate = gregorian.date(from: componentsEndDate)!
    }
    
    func sendCompanyVCData(companyAllSelected: Bool!, company: Company?){
        self.filterCompanyAllSelected = companyAllSelected
        
        self.companySelected = company
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(controller != nil)
        {
            if let sections = controller.sections
            {
                let sectionInfo = sections[section]
                
                return sectionInfo.numberOfObjects
            }
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //in our case, there would be allways one section
        if(controller != nil)
        {
            if let sections = controller.sections
            {
                return sections.count
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //creating a cell passing the StrikeCell and the indexPath
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
        
        var datePredicate:NSPredicate? = nil
        var companyPredicate:NSPredicate? = nil
        
        //predicates if the dates or the company is selected
        if(!self.filterDateAllSelected){
            if((self.beginDate != nil) && (self.endDate != nil)){
                datePredicate = NSPredicate(format: "(startDate >= %@) AND (endDate <= %@)", self.beginDate! as NSDate, self.endDate! as NSDate)
            }
        }
        
        if(!self.filterCompanyAllSelected){
            if(self.companySelected != nil){
                companyPredicate = NSPredicate(format: "company.companyName == %@", (self.companySelected?.companyName!)!);
            }
        }
        
        //if both filter are selected, we should search with both predicates
        if(datePredicate != nil && companyPredicate != nil){
            fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [datePredicate!,companyPredicate!])
        } else if (datePredicate != nil && companyPredicate == nil){
            //if only date filter is selected
            fetchRequest.predicate = datePredicate
        } else if (datePredicate == nil && companyPredicate != nil){
            //if only company filter is selected
            fetchRequest.predicate = companyPredicate
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:context , sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        do{
            try controller.performFetch()
        } catch{
            let error = error as NSError!
            print("ERROR FETCHING DATA FROM DATABASE - \(error!)")
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
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DataVCSegue"
        {
            if let destination =  segue.destination as? DateVC
            {
                destination.dateAllSelected = filterDateAllSelected
                destination.delegate = self
            }
        }
        if segue.identifier == "CompanyVCSegue"
        {
            if let destination =  segue.destination as? CompanyVC
            {
                destination.companyAllSelected = filterCompanyAllSelected
                destination.delegate = self
            }
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
        } catch {
            print ("ERROR: Error deleting all data from Core Data")
        }
    }
}

