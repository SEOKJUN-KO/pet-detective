//
//  EmergencyRecuePetInfoController.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/04/07.
//

import Foundation

// URL session으로 api 연동
// 추후 alamofire로 변경 
struct EmergencyRescuePetInfoController {
    func fetchedGoldenUserTimeInfo(completion: @escaping (UserGoldenTime?) -> Void) {
        // http는 info.plist > app transport security setting > allow arbitray loads 
        let url = URL(string: "https://iospring.herokuapp.com/goldentime")!
        
//        let userId = 74 // interim
//
//        let phoneNumber = UserDefaults.standard.object(forKey: "petUserPhoneN") as! String
//
//        let query: [String: String] = [
//            "userId": "\(userId)"
//        ]
        
//        guard let url = baseUrl.withQueries(query) else {
//            print("Unalbe to build URL")
//            return
//        }
        
        
        let taskObject = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            if let data = data, let userGoldenTimePetInfo = try? jsonDecoder.decode(UserGoldenTime.self, from: data) {
                // 응답 처리 로직
                print("Data was returned and data was properly decoded")
                completion(userGoldenTimePetInfo) // 함수가 끝나고 나면 호출
            } else {
                print("Either no data was returned, or data was not properly decoded")
                completion(nil)
                return
            }
            
        }
        
        taskObject.resume()
    }
    
}
