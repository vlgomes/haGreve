//
//  ViewController.swift
//  haGreve
//
//  Created by Vasco Gomes on 09/04/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check if internet is available, if it is, delete all records from database and retrieve most recent ones from web service
        if(DataService.isInternetAvailable()){
            deleteAllRecords()
            DataService.downloadStrikes()
        }
        
        
        //se não tiver, fico com os dados existentes já na BD
        
        
        
        
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

