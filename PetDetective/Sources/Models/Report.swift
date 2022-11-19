//
//  Report.swift
//  PetDetective
//
//  Created by 고석준 on 2022/03/29.
//

import Foundation

struct Report {
    var boardId: Int
    var userId: Int
    var petId: Int
    var missingLocation: String
    var missingTime: Date
    var status: String
    var money: Int?
}
