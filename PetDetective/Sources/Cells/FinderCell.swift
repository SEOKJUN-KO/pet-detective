//
//  FinderCell.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/22.
//

import UIKit

class FinderCell: UICollectionViewCell {

    @IBOutlet weak var petImg: UIImageView!
    @IBOutlet weak var petLocation: UILabel!
    @IBOutlet weak var careOption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.petImg.layer.borderWidth = 1.0
        self.petImg.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }

}
