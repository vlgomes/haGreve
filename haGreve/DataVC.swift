//
//  DataVC.swift
//  haGreve
//
//  Created by Vasco Gomes on 09/04/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import UIKit

class DataVC: UIViewController {
    
    var dateAllSelected : Bool = true
    @IBOutlet var selectDateSwitch: UISwitch!
    @IBOutlet var selectAllSwitch: UISwitch!
    @IBOutlet var datesStackView: UIStackView!

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
}
