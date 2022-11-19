//
//  ReportBoardCell.swift
//  PetDetective
//
//  Created by 고석준 on 2022/03/23.
//

import UIKit

class ReportBoardCell: UICollectionViewCell {
    
    @IBOutlet weak var petImg: UIImageView!
    @IBOutlet weak var petInfo: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
}
