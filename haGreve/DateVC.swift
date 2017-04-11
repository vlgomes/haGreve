//
//  DataVC.swift
//  haGreve
//
//  Created by Vasco Gomes on 09/04/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import UIKit

protocol DateVCDelegate : class {
    func sendDateVCData(dateAllSelected: Bool!, startDate: Date?, endDate: Date?)
}

class DateVC: UIViewController {
    
    var dateAllSelected : Bool = true
    @IBOutlet var selectDateSwitch: UISwitch!
    @IBOutlet var selectAllSwitch: UISwitch!
    @IBOutlet var datesStackView: UIStackView!
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    weak var delegate: DateVCDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        if(self.dateAllSelected){
            datesStackView.isHidden = true
            selectDateSwitch.setOn(false, animated: true)
            selectAllSwitch.setOn(true, animated: true)
        }
        else {
            datesStackView.isHidden = false
            selectDateSwitch.setOn(true, animated: true)
            selectAllSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func selectDateIsOn(_ sender: Any) {
        datesStackView.isHidden = false
        selectDateSwitch.setOn(true, animated: true)
        selectAllSwitch.setOn(false, animated: true)
        self.dateAllSelected = false
    }
    
    @IBAction func selectAllIsOn(_ sender: Any) {
        datesStackView.isHidden = true
        selectDateSwitch.setOn(false, animated: true)
        selectAllSwitch.setOn(true, animated: true)
        self.dateAllSelected = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let selected = self.selectAllSwitch.isOn
        let startDate = self.startDatePicker.date
        let endDate = self.endDatePicker.date

        delegate?.sendDateVCData(dateAllSelected: selected, startDate: startDate, endDate: endDate)
    }
}
