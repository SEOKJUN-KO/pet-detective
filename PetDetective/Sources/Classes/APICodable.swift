//
//  APICodable.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/04.
//

import Foundation

class ReportBoard: Codable{
    let mainImageUrl: String?
    let missingLocation: String?
    let id: Int?
    let money: Int?
    let missingLatitude: Double?
    let missingLongitude: Double?
    let missingTime: String?
    let userPhoneNumber: String
}

class FindBoard: Codable{
    let mainImageUrl: String?
    let missingLocation: String?
    let id: Int?
    let missingLatitude: Double?
    let missingLongitude: Double?
    let missingTime: String?
    let care: Bool
    let userPhoneNumber: String
}

//"mainImageUrl":"https://iospring.s3.ap-northeast-2.amazonaws.com/7c4cf621-1600-4043-8418-1826da262de2.png",
//"missingLocation":"서울광진구",
//"id":4,
//"money":1000,
//"missingLatitude":126.95125920012096,
//"missingLongitude":37.65504092130379,
//"missingTime":"2022-03-31 05:21:46 +0000"


class APIFinderBoardResponse<T: Codable> : Codable {
    var totalPage: Int?
    var finderBoardDTOS: T?
}

class APIFinderDetailResponse: Codable {
    let breed: String
    let color: String
    let missingTime: String
    let missingLocation: String
    let missingLatitude: Double
    let missingLongitude: Double
    let age: Int?
    let feature: String
    let disease: String
    let gender: String
    let mainImageUrl: String
    let id: Int
    let content: String
    let care: Bool
    let operation: Bool
}

class APIDetectBoardResponse<T: Codable> : Codable {
    var totalPage: Int?
    var detectBoardDTOList: T?
}

class APIDetectDetailResponse:Codable {
    let userPhoneNumber: String
    let breed: String
    let color: String
    let missingTime: String
    let missingLocation: String
    let age: Int?
    let feature: String
    let disease: String
    let gender: String
    let mainImageUrl: String
    let id: Int
    let money: Int?
    let content: String
    let operation: Bool
}

class GetCertificationNumber: Decodable{
    let needjoin: Bool
    let cernum: String
}

class PassCertification: Decodable{
    let id: Int
}

struct PutWithoutImage:Encodable{
    let breed: String
    let color: String
    let missingTime: String
    let missingLocation: String
    let feature: String
    let money: Int
    let gender: String
    let isOperation: Bool
    let disease: String
    let age: Int
    let missingLongitude: Double
    let missingLatitude: Double
}

