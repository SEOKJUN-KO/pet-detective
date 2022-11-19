//
//  EmergencyResquePetInfo.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/04/07.
//

import Foundation

struct MissingPetInfo: Codable, Equatable {
    let boardId: Int?
    let imageString: String?
    let time: String?
    let latitude: Double?
    let longitude: Double?
    let location: String?
    let money: Int?
    let distance: Double?
    
    // key 대칭
    enum Codingkeys: String, CodingKey {
        case boardId
        case imageString = "mainImageUrl"
        case time = "missingTime"
        case latitude = "missingLatitude"
        case longitude = "missingLongitude"
        case location = "missingLocation"
        case money
        case distance
    }

    // JSON파일 Swift 오브젝트로 변환 (decode) 할때 실패할수 있는 함수 있므로 throws init 필요 (중간에 개입 할수 잇게 함)
    // 변환시 KeyedDecodingContainer 중간단계 결과물
    init(from decoder: Decoder) throws {
        // valueContainer: 중간단계 값,
        let valueContainer = try decoder.container(keyedBy: Codingkeys.self) // enum 타입을 넣어줌
        self.boardId = try? valueContainer.decode(Int.self, forKey: Codingkeys.boardId)
        self.imageString = try? valueContainer.decode(String.self, forKey: Codingkeys.imageString)
        self.time = try? valueContainer.decode(String.self, forKey: Codingkeys.time)
        self.latitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.latitude)
        self.longitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.longitude)
        self.location = try? valueContainer.decode(String.self, forKey: Codingkeys.location)
        self.money = try? valueContainer.decode(Int.self, forKey: Codingkeys.money)
        self.distance = try? valueContainer.decode(Double.self, forKey: Codingkeys.distance)
    }
    
}

struct FindPetInfo: Codable, Equatable {
    let boardId: Int?
    let imageString: String?
    let time: String?
    let latitude: Double?
    let longitude: Double?
    let location: String?
    let distance: Double?
    
    // key 대칭
    enum Codingkeys: String, CodingKey {
        case boardId = "boardId"
        case imageString = "mainImageUrl"
        case time = "findTime"
        case latitude = "findLatitude"
        case longitude = "findLongitude"
        case location = "findLocation"
        case distance
    }

    // JSON파일 Swift 오브젝트로 변환 (decode) 할때 실패할수 있는 함수 있므로 throws init 필요 (중간에 개입 할수 잇게 함)
    // 변환시 KeyedDecodingContainer 중간단계 결과물
    init(from decoder: Decoder) throws {
        // valueContainer: 중간단계 값,
        let valueContainer = try decoder.container(keyedBy: Codingkeys.self) // enum 타입을 넣어줌
        self.boardId = try? valueContainer.decode(Int.self, forKey: Codingkeys.boardId)
        self.imageString = try? valueContainer.decode(String.self, forKey: Codingkeys.imageString)
        self.time = try? valueContainer.decode(String.self, forKey: Codingkeys.time)
        self.latitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.latitude)
        self.longitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.longitude)
        self.location = try? valueContainer.decode(String.self, forKey: Codingkeys.location)
        self.distance = try? valueContainer.decode(Double.self, forKey: Codingkeys.distance)
    }
    
}

struct UserGoldenTime:Codable {
    let userLatitude: Double? // 사용자의 탐색 위도
    let userLongitude: Double?  // 사용자의 탐색 경도
    let userMissingPetLatitude: Double? // 사용자의 실종견 위도
    let userMissingPetLongitude: Double? // 사용자의 실종견 경도
    let findPetInfos: [FindPetInfo]?
    let missingPetInfos: [MissingPetInfo]?
    
    enum Codingkeys: String, CodingKey {
        case userLatitude
        case userLongitude
        case userMissingPetLatitude = "petLatitude"
        case userMissingPetLongitude = "petLongitude"
        case findPetInfos = "findRequestDto"
        case missingPetInfos = "detectiveRequestDtos"
    }
    
    // JSON파일 Swift 오브젝트로 변환 (decode) 할때 실패할수 있는 함수 있므로 throws init 필요 (중간에 개입 할수 잇게 함)
    // 변환시 KeyedDecodingContainer 중간단계 결과물
    init(from decoder: Decoder) throws {
        // valueContainer: 중간단계 값,
        let valueContainer = try decoder.container(keyedBy: Codingkeys.self) // enum 타입을 넣어줌
        self.userLatitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.userLatitude)
        self.userLongitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.userLongitude)
        self.userMissingPetLatitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.userMissingPetLatitude)
        self.userMissingPetLongitude = try? valueContainer.decode(Double.self, forKey: Codingkeys.userMissingPetLongitude)
        self.findPetInfos = try? valueContainer.decode([FindPetInfo].self, forKey: Codingkeys.findPetInfos)
        self.missingPetInfos = try? valueContainer.decode([MissingPetInfo].self, forKey: Codingkeys.missingPetInfos)
    }
}
