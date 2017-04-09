//
//  StrikeCell.swift
//  haGreve
//
//  Created by Vasco Gomes on 09/04/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import UIKit

class StrikeCell: UITableViewCell {

    @IBOutlet var strikeCompanyLbl: UILabel!
    @IBOutlet var strikeStartDateLbl: UILabel!
    @IBOutlet var strikeEndDateLbl: UILabel!
    @IBOutlet var strikeDescriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(strike : Strike){
        
        strikeDescriptionLbl.text = strike.strikeDescription!
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        //pass from date to string, to my specified format date
        let startDateString = dateFormatter.string(from:strike.startDate! as Date)
        let endDateString = dateFormatter.string(from:strike.endDate! as Date)

        strikeStartDateLbl
            
            .text = "De : \(startDateString)"
        strikeEndDateLbl.text = "A: \(endDateString)"
 
        strikeCompanyLbl.text = strike.company?.companyName
    }
}
