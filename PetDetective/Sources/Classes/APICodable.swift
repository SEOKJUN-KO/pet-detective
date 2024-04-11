//
//  APICodable.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/04.
//

import Foundation

// 왜 class로 코더블을 했을까
// 단순히 변수만 저장하고 있기 때문에, struct든 class든 성능차이는 크게 나지 않을 것 같음
// 다만 복사가 되는 경우, 참조 값을 사용할 것인지, 새 변수를 사용할 것인지 고려해볼 부분인 것 같고
// 값의 불변성이 높고 공유 가능성이 낮고 상속이 필요하지 않기 때문에, 일반적으로 사용하는 struct를 사용했어도 좋았을 것 같다.
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
    // FindBoard를 담는 배열 형태가 명확함으로 Generic으로 꼭 사용할 필요는 없었을 듯
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
