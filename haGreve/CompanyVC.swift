//
//  CompanyVC.swift
//  haGreve
//
//  Created by Vasco Gomes on 09/04/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import UIKit
import CoreData

class CompanyVC: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet var selectCompanySwitch: UISwitch!
    @IBOutlet var selectAllSwitch: UISwitch!
    @IBOutlet var companyPickerView: UIPickerView!

    var companyAllSelected : Bool = true
    var companies = [Company]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(self.companyAllSelected){
            companyPickerView.isHidden = true
            selectCompanySwitch.setOn(false, animated: true)
            selectAllSwitch.setOn(true, animated: true)
        }
        else {
            companyPickerView.isHidden = false
            selectCompanySwitch.setOn(true, animated: true)
            selectAllSwitch.setOn(false, animated: true)
        }
        
        companyPickerView.delegate = self
        
        loadCompanies()
    }
    
    func loadCompanies()
    {
        self.companies = DataService.downloadCompanies()
        self.companyPickerView.reloadAllComponents()
    }
    
    @IBAction func selectCompanyIsOn(_ sender: Any) {
        companyPickerView.isHidden = false
        selectCompanySwitch.setOn(true, animated: true)
        selectAllSwitch.setOn(false, animated: true)
        self.companyAllSelected = false
    }
    
    @IBAction func selectAllIsOn(_ sender: Any) {
        companyPickerView.isHidden = true
        selectCompanySwitch.setOn(false, animated: true)
        selectAllSwitch.setOn(true, animated: true)
        self.companyAllSelected = true
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let company = self.companies[row]
        return company.companyName
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //only 1 picker view
        return self.companies.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //how many columns there are
        //we don't neeed to check the tag because in both there are only 1 component
        return 1
    }
}
