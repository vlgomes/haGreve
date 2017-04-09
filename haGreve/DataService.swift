//
//  DataService.swift
//  haGreve
//
//  Created by Vasco Gomes on 09/04/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import Foundation
import SystemConfiguration

class DataService{

    static let dataService = DataService()
    
    static func downloadStrikes(){
        
        let url = URL(string: URL_STRIKES)
        
        //the call as to by synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: url!){
            (data, response, error) in
            
            if error != nil {
                
                print("ERROR: ",error!)
                
            } else {
                if let urlContent = data {
                    
                    do {
                        
                        if let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Any>{
                            
                            //pass through all values in json array
                            for index in 0..<jsonResult.count {
                                
                                if let strikeJson = jsonResult[index] as? Dictionary<String,Any>
                                {
                                    
                                    let strike = Strike(context: context)

                                    if let startDateJSON = strikeJson["start_date"] as? String{
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                        
                                        if let startDate: NSDate = dateFormatter.date(from: startDateJSON) as NSDate?{
                                            strike.startDate = startDate
                                        }
                                    }
                                    
                                    if let endDateJSON = strikeJson["end_date"] as? String{
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                        
                                        if let endDate: NSDate = dateFormatter.date(from: endDateJSON) as NSDate?{
                                            
                                            strike.endDate = endDate
                                        }
                                    }
                                    
                                    if let allDay = strikeJson["all_day"] as? Bool{
                                        
                                        strike.allDay = allDay
                                    }
                                    
                                    if let canceled = strikeJson["canceled"] as? Bool{
                                        
                                        strike.canceled = canceled
                                    }
                                    
                                    if let sourceLink = strikeJson["source_link"] as? String{
                                        
                                        strike.sourceLink = sourceLink
                                    }
                                    
                                    if let StrikeId = strikeJson["id"] as? Int32{
                                        
                                        strike.id = StrikeId
                                    }
                                    
                                    if let strikeDescription = strikeJson["description"] as? String{
                                        
                                        strike.strikeDescription = strikeDescription
                                    }
                                    
                                    if let companyJson = strikeJson["company"] as? Dictionary<String,Any>{

                                        let company = Company(context: context)
                                        
                                        if let id = companyJson["id"] as? Int32{
                                            
                                            company.id = id
                                        }
                                        
                                        if let companyName = companyJson["name"] as? String{
                                            
                                            company.companyName = companyName
                                        }
                                        
                                        strike.company = company
                                    }
                                    
                                    
                                    if let submitterJson = strikeJson["submitter"] as? Dictionary<String,Any>{
                                        
                                        let submitter = Submitter(context: context)
                                        
                                        if let firstName = submitterJson["first_name"] as? String{
                                            
                                            submitter.firstName = firstName
                                        }
                                        
                                        if let lastName = submitterJson["last_name"] as? String{
                                            
                                            submitter.lastName = lastName
                                        }
                                        
                                        strike.submitter = submitter
                                    }
                                    
                                    //saves the data to database
                                    ad.saveContext()
                                }
                            }
                        }
                    } catch {
                        print("ERROR: JSON Processing of Strikes Failed")
                    }
                    
                }
            }
            semaphore.signal()
        }
        
        task.resume()
        
        semaphore.wait(timeout: .distantFuture)
    }
    
    static func downloadCompanies(){
        let url = URL(string: URL_COMPANIES)
        
        let task = URLSession.shared.dataTask(with: url!){
            (data, response, error) in
            
            if error != nil {
                
                print("ERROR: ",error!)
                
            } else {
                if let urlContent = data {
                    
                    do {
                        
                        if let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Any>{
                            
                            //pass through all values in json array
                            for index in 0..<jsonResult.count {
                                
                                if let companyJson = jsonResult[index] as? Dictionary<String,Any>{
                                    
                                    let company = Company(context: context)
                                    
                                    if let id = companyJson["id"] as? Int32{
                                        
                                        company.id = id
                                    }
                                    
                                    if let companyName = companyJson["name"] as? String{
                                        
                                        company.companyName = companyName
                                    }
                                    
                                    ad.saveContext()
                                }
                            }
                        }
                    } catch {
                        print("ERROR: JSON Processing of Companies Failed")
                    }
                }
            }
        }
        
        task.resume()
    }
    
    //DISCLAIMER
    //This code was retrieved from http://stackoverflow.com/questions/39558868/check-internet-connection-ios-10
    static func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
