//
//  AppDelegate.swift
//  PetDetective
//
//  Created by Junseo Park on 3/19/22.
//

import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var alarms = [Alarm]() {
        didSet {
            self.saveTasks()
        }
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self // 아래 extension 참조
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 알림, 뱃지, 사운드 옵션 사용하겠다
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, error in // 알림에 대한 허락을 받겠다
            if let error = error {
                print("ERROR|Request Notificattion Authorization : \(error)")
            }
        }
        application.registerForRemoteNotifications() // 디바이스 토큰 요청
        
        // UserDefault에서 불러오기
        self.loadTasks()
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("디바이스 토큰: \(deviceTokenString)")
        let userDefaults = UserDefaults.standard
        userDefaults.set(deviceTokenString, forKey: "petDeviceToken")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "WarningPush")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Alarm 기능
    

    
    func saveTasks() {
        let data = self.alarms.map {
            [
                "alarmMode": $0.alarmMode,
                "boardType": $0.boardType,
                "boardId": $0.boardId
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "petAlarm")
    }
    
        func loadTasks() {
            let userDefaults = UserDefaults.standard
            guard let data = userDefaults.object(forKey: "petAlarm") as? [[String: Any]] else { return }
            self.alarms = data.compactMap {
                guard let alarmMode =  $0["alarmMode"] as? String else { return nil }
                guard let boardType = $0["boardType"] as? String else { return nil }
                guard let boardId = $0["boardId"] as? Int else { return nil }
                return Alarm(alarmMode: alarmMode, boardType: boardType, boardId: boardId)
            }
            print(self.alarms)
        }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 원격으로 받은 노티피케이션의 디스플레이의 형태를 지정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .badge, .sound]) // 리스트, 배너, 뱃지, 사운드를 모두 사용하는 형태
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let aps = response.notification.request.content.userInfo["aps"] as? NSDictionary {
            print(aps)
            if let alert = aps["alert"] as? NSDictionary {
                if let summaryArg = alert["summary-arg"] as? NSString {
                    let summaryStr = summaryArg as String
                    let dict = convertToDictionary(text: summaryStr)
//                    print(dict)
                    guard let mode = dict!["mode"] as? String else { return }
                    guard let type = dict!["type"] as? String else { return }
                    guard let boardId = dict!["boardId"] as? String else { return }
                    print(mode)
                    print(type)
                    print(boardId)
                    
                    if(mode == "게시글 작성"){
                        if(type == "의뢰"){
                            let alarm = Alarm(alarmMode: "게시글 작성", boardType: "의뢰", boardId: Int(boardId)!)
                            alarms.append(alarm)
                            NotificationCenter.default.post(name: NSNotification.Name("newReport"), object: boardId)
                        }
                        else if(type == "보관"){
                            let alarm = Alarm(alarmMode: "게시글 작성", boardType: "보호", boardId: Int(boardId)!)
                            alarms.append(alarm)
                            NotificationCenter.default.post(name: NSNotification.Name("newDetect"), object: boardId)
                        }
                        else{
                            let alarm = Alarm(alarmMode: "게시글 작성", boardType: "발견", boardId: Int(boardId)!)
                            alarms.append(alarm)
                            NotificationCenter.default.post(name: NSNotification.Name("newDetect"), object: boardId)
                        }
                    }
                    else if(mode == "골든타임"){
                        if(type == "의뢰"){
                            let alarm = Alarm(alarmMode: "골든타임", boardType: "의뢰", boardId: Int(boardId)!)
                            alarms.append(alarm)
                            NotificationCenter.default.post(name: NSNotification.Name("newReportGolden"), object: alarm)
                        }
                        else if(type == "보관"){
                            let alarm = Alarm(alarmMode: "골든타임", boardType: "보호", boardId: Int(boardId)!)
                            alarms.append(alarm)
                            NotificationCenter.default.post(name: NSNotification.Name("newDetectGolden"), object: alarm)
                        }
                        else{
                            let alarm = Alarm(alarmMode: "골든타임", boardType: "발견", boardId: Int(boardId)!)
                            alarms.append(alarm)
                            NotificationCenter.default.post(name: NSNotification.Name("newDetectGolden"), object: alarm)
                        }
                    }
                 }
            }
        }
    }
    
}


