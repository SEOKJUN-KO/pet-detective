//
//  AlarmCell.swift
//  PetDetective
//
//  Created by 고석준 on 2022/05/01.
//

import UIKit

class AlarmCell: UITableViewCell {


    @IBOutlet weak var alarmTitle: UILabel!
    @IBOutlet weak var alarmBody: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
