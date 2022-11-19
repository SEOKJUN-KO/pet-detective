//
//  ReportViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 3/19/22.
//

import Alamofire
import NMapsMap

enum ReportMode: String {
    case request = "requset"
    case find = "find"
    
    func toString() -> String {
        return rawValue
    }
}

class EmergencyRescueViewController: MapViewController, NMFMapViewTouchDelegate {
    
    let emergencyRescuePetInfoController = EmergencyRescuePetInfoController()
    var naverMap = MapView().naverMapView!
    var goldenAlarm: Alarm?
    var markers = [NMFMarker]()
    var getMarker: NMFMarker?
    var secondTimer: Timer?
    var reportMode: ReportMode?
    var timeGap = 0
    var count = 0
    var toBoardDetail: Int?
    var searchLatitude: Double?
    var searchLongitude: Double?
    
    @IBOutlet weak var changedSearchLocationButton: UIButton!
    @IBOutlet weak var rescueMapView: UIView!
    @IBOutlet weak var markerInfoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goldenTimeLabel: UILabel!
    @IBOutlet weak var addDetailLabel: UILabel!
    @IBOutlet weak var boardButton: UIButton!
    @IBOutlet weak var reportSegment: UISegmentedControl!
    
    override var isAuthorized: Bool? {
        didSet {
            updateUIFromMode(isAuthorized: isAuthorized, naverMapView: naverMap, nil, nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rescueMapView.addSubview(naverMap)
        
        naverMap.translatesAutoresizingMaskIntoConstraints = false
        naverMap.widthAnchor.constraint(equalTo: self.rescueMapView.widthAnchor, multiplier: 1).isActive = true
        naverMap.heightAnchor.constraint(equalTo: self.rescueMapView.heightAnchor, multiplier: 1).isActive = true
        naverMap.centerXAnchor.constraint(equalTo: self.rescueMapView.centerXAnchor).isActive = true
        naverMap.centerYAnchor.constraint(equalTo: self.rescueMapView.centerYAnchor).isActive = true
        
        setLocationManager()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(goldenTimeNotification(_:)),
            name: NSNotification.Name("NotiGoldenTimeAlarm"),
            object: nil
        )
        
        naverMap.mapView.addCameraDelegate(delegate: self)
        
        naverMap.mapView.touchDelegate = self
        
        boardButton.layer.cornerRadius = 6
        boardButton.tintColor = .white
        
        changedSearchLocationButton.layer.cornerRadius = 2
        changedSearchLocationButton.layer.shadowColor = UIColor.black.cgColor
        changedSearchLocationButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        changedSearchLocationButton.layer.shadowRadius = 1
        changedSearchLocationButton.layer.shadowOpacity = 0.4
    }
   
    override func viewWillAppear(_ animated: Bool) {
        if goldenAlarm == nil {
            print("ViewWillAppear - getControl")
            getControl(mode: reportMode)
        } else {
            print("ViewWillAppear - not getControl")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerQuit()
    }
    
    @objc func goldenTimeNotification(_ notification: Notification) {
        guard let alarm = notification.object as? Alarm else { return }
        goldenAlarm = alarm
        checkAlarm(alarm: goldenAlarm)
        //        goldenAlarm?.boardType == "의뢰" ? (reportMode = .request) : (reportMode = .find)
        getControl(mode: reportMode)
        print("goldenTimeNotification - getControl")
    }
    
    func getControl(mode: ReportMode?) {
        updateReportUI(reportMode)
        timerRun()
    }
    
    private func updateReportUI(_ mode: ReportMode?) {
        checkMode()
        deleteMarker()
        self.markerInfoView.isHidden = true
        self.boardButton.isHidden = true
        emergencyRescuePetInfoController.fetchedGoldenUserTimeInfo { (userGoldenTimePetInfo) in
            guard let userGoldenTimePetInfo = userGoldenTimePetInfo else { return }

            if mode == .find {
                print("find mode")
                if userGoldenTimePetInfo.userMissingPetLatitude == nil {
                    self.alertOk( title: "실종 신고한 이력이 없습니다.", message: "실종 신고한 이력이 없습니다.\n실종 신고한 애완동물과 같은 종의 동물이 지도에 표시됩니다.", viewController: self) // 목격신고한 유저 없으면
                    return
                }
                
                guard let findPets = userGoldenTimePetInfo.findPetInfos else {
                    return }
                self.updateMapUI(with: findPets)
                guard let userMissingPetLatitude = userGoldenTimePetInfo.userMissingPetLatitude else { return }
                guard let userMissingPetLongitude = userGoldenTimePetInfo.userMissingPetLongitude else { return }
                self.moveCameraFirstRun(self.naverMap, latitude: userMissingPetLatitude, longitude: userMissingPetLongitude)
                
            }
            else if mode == .request { // mode request 이거나 nil 일때
                print("request mode")
                guard let missingPets = userGoldenTimePetInfo.missingPetInfos else { return }
                self.updateMapUI(with: missingPets)
                guard let userLatitude = userGoldenTimePetInfo.userLatitude else { return }
                guard let userLongitude = userGoldenTimePetInfo.userLongitude else { return }
                self.moveCameraFirstRun(self.naverMap, latitude: userLatitude, longitude: userLongitude)
            }
        }
    }
    
    private func updateMapUI(with pets: [Any]) {
        // seguementcontrol 값 변경 되면 삭제후 새 마커 찍기
        // 신고한 글 없으면 경고창
        // 마커 존재 하면 삭제하고 실행
        print("updateMapUI")
        DispatchQueue.global(qos: .default).async { [self] in
            // 백그라운드 스레드 (오버레이 객체 생성)
            if let missingPets = pets as? [MissingPetInfo] {
                print("missingPet marker property")
                print("실종된 애완동물 개수 \(pets.count)")
                for missingPet in missingPets {
                    // 알림 모드(게시글 작성/골든타임) 타입(발견/보호) 게시판 아이디로 구문
                    // 알림 받음 > 화면이동 > 겟 요청 > 시간 지남 > 시간 지났다고 말해야함
                    guard let boardId = missingPet.boardId else { return }
                    guard let latitude = missingPet.latitude else { return }
                    guard let longitude = missingPet.longitude else { return }
                    guard let image = missingPet.imageString else { return }
                    guard let petImage = image.toImage() else { return }
                    guard let petImageCircleResize = petImage.circleReSize() else { return }
                    guard let money = missingPet.money else { return }
                    guard let missingTime = missingPet.time else { return }
                    
                    print("String type 실종 날짜 시간 \(missingTime)")
                    guard let currentDate = "YYYY-MM-dd HH:mm:ss".currentKorDate().stringToDate() else { return } // "yyyy-MM-dd HH:mm:ss" // yyyy-MM-dd HH:mm:ss
                    print("현재 날짜 시간 \(currentDate)")
                    guard let missingTime = missingTime.stringToDate() else { return }
                    print("Date type 실종 날짜 시간 \(missingTime)")
                    let remainTime = 10800 - Int(currentDate.timeIntervalSince(missingTime))
                    print("골든 타임 남은 시간(초) \(remainTime)")
                    
                    let marker = NMFMarker(position: NMGLatLng(lat: latitude, lng: longitude))
                    
                    marker.iconImage = NMFOverlayImage(image: petImageCircleResize)
                    
                    marker.userInfo = ["RemainTime": remainTime, "Money": money, "BoardId": boardId]
                    
                    markers.append(marker)
                    
                    print("실종 좌표 \(latitude) \(longitude)")
                    
                }

            }
            else if let findPets = pets as? [FindPetInfo] {
                print("findPet marker property")
                print("발견된 애완동물 개수 \(pets.count)")
                for findPet in findPets {
                    
                    guard let boardId = findPet.boardId else { return }
                    guard let latitude = findPet.latitude else { return }
                    guard let longitude = findPet.longitude else { return }
                    guard let image = findPet.imageString else { return }
                    guard let petImage = image.toImage() else { return }
                    guard let petImageCircleResize = petImage.circleReSize() else { return }
                    guard let findTime = findPet.time else { return }
                    guard let findLocation = findPet.location else { return }
                    
                    print("String type 발견 날짜 시간 \(findTime)")
                    guard let currentDate = "YYYY-MM-dd HH:mm:ss".currentKorDate().stringToDate() else { return } // "yyyy-MM-dd HH:mm:ss"
                    print("현재 날짜 시간 \(currentDate)")
                    guard let findTime = findTime.stringToDate() else { return }
                    print("Date type 발견 날짜 시간 \(findTime)")
        
                    let remainTime = 10800 - Int(currentDate.timeIntervalSince(findTime))
                    print("골든 타임 남은 시간(초) \(remainTime)")

                    let marker = NMFMarker(position: NMGLatLng(lat: latitude, lng: longitude))
                    
                    marker.iconImage = NMFOverlayImage(image: petImageCircleResize)
                    
                
                    marker.userInfo = ["RemainTime": remainTime, "FindLocation": findLocation, "BoardId": boardId]

                    markers.append(marker)
                    
                    print("마커 어팬드 \(markers.count)")
                    
                    print("목격 좌표 \(latitude) \(longitude)")
                }
            }
            DispatchQueue.main.async { [self] in
                // 메인 스레드 (오버레이 객체 맵에 올림)
                print("마커 개수\(markers.count)")
                for marker in markers {
                    
                    marker.mapView = self.naverMap.mapView
                    
                
                    let markerID = marker.userInfo["BoardId"] as? Int
                    
                    if goldenAlarm?.boardId == markerID  {
                        print("알람 마커 추가")
                        getMarker = marker
                        createMarkerInfoView(self.reportMode)
                    } else {
                        // 마커 초기값
                        if goldenAlarm == nil {
                            if toBoardDetail != nil {
                                if toBoardDetail == markerID {
                                    print("게시글 보기 후 toBoardID == markerID 표시")
                                    getMarker = marker
                                    createMarkerInfoView(self.reportMode)
                                    toBoardDetail = nil
                                }
                            }
                            else if marker == markers.first {
                                print("첫번째 마커 표시")
                                getMarker = marker
                                createMarkerInfoView(self.reportMode)
                            }
                        }
                    }
                    
                    marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                        print("마커 터치")
                        self.getMarker?.captionText = ""
                        self.getMarker = marker
                        self.createMarkerInfoView(self.reportMode)
                        return true
                    }
                    
                }
            }
        }
    }
    
    private func createMarkerInfoView(_ mode: ReportMode?) {
        if self.markerInfoView.isHidden == true {
            if let remainTime = getMarker?.userInfo["RemainTime"] as? Int {
                self.timeGap = remainTime
            }
            
            if mode == .request {
                if let money = getMarker?.userInfo["Money"] {
                    self.addDetailLabel.text = "💰 사례금 \(money)"
                    self.getMarker?.captionText = "잃어버린 위치"
                    self.getMarker?.captionColor = UIColor.red
                }
                self.titleLabel.text = "🚨 실종된 애완동물을 찾아주세요!"
                self.boardButton.setTitle("의뢰글 보기", for: .normal) // 버튼 이름 변경
            }
            else if mode == .find {
                if let findLocation = getMarker?.userInfo["FindLocation"] {
                    self.addDetailLabel.text = "📍 목격 장소 \(findLocation)"
                    self.getMarker?.captionText = "목격된 위치"
                    self.getMarker?.captionColor = UIColor.red
                }
                self.titleLabel.text = "🚨 목격된 같은 종의 애완동물"
                self.boardButton.setTitle("목격글 보기", for: .normal) // 버튼 이름 변경
            }
            self.markerInfoView.isHidden = false
            self.boardButton.isHidden = false
        }
        else {
            self.getMarker?.captionText = ""
            self.markerInfoView.isHidden = true
            self.boardButton.isHidden = true
        }
    }
    
    private func timerRun() {
        print("timerRun")
        timeGap = 0
        count = 0
        if let timer = secondTimer {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
            if !timer.isValid {
                // 1초마다 timerCallback함수를 호출하는 타이머
                secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        } else {
            // timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
            // 1초마다 timerCallback함수를 호출하는 타이머
            secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }
    
    private func timerQuit() {
        if let timer = secondTimer {
            if(timer.isValid){
                timer.invalidate()
            }
        }
    }
    

    @objc func timerCallback() {
//        print("timer call back") // 현재시간 - 실종시간
        
        
        if (timeGap - count) < -5 { // 시간 다되면 리 로드
            getControl(mode: reportMode)
        } else {
            goldenTimeLabel.text = "🛎 골든 타임 \((timeGap - count).hour)시간 \((timeGap - count).minute)분 \((timeGap - count).second)초"
        }

        count += 1
    }
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        self.getMarker?.captionText = ""
        markerInfoView.isHidden = true
        print("지도 탭")
    }
    
    func alertOk( title: String, message: String, viewController: UIViewController ) {

        let alert = UIAlertController( title: title, message: message, preferredStyle: UIAlertController.Style.alert )
        
        let okAction = UIAlertAction( title: "OK", style: .default ) { (action) in }
        alert.addAction(okAction)
        
        viewController.present( alert, animated: false, completion: nil )
    }
    
    
    func checkAlarm(alarm :Alarm?) {
        if "의뢰" == alarm?.boardType {
            print("넘어온 알림 boardId = \(goldenAlarm?.boardId)")
            reportMode = .request
        }
        else if "발견" == alarm?.boardType {
            print("넘어온 알림 boardId = \(goldenAlarm?.boardId)")
            reportMode = .find
        }
        else {
            print("알림 데이터 넘어오지 않음")
        }
    }
    
    func checkMode() {
        if reportMode == .request {
            reportSegment.selectedSegmentIndex = 0
        }
        else if reportMode == .find {
            reportSegment.selectedSegmentIndex = 1
        }
        else {
            reportMode = .request
            reportSegment.selectedSegmentIndex = 0
        }
    }
    
    func deleteMarker() {
        
        if markers != [] {
            for marker in markers {
                marker.mapView = nil
            }
            markers.removeAll()
        }
        
        print("삭제 후 마커개수 \(markers.count)")
    }
    
    
    @IBAction func switchMode(_ sender: Any) {
        print("Switch Mode")
        
        if reportSegment.selectedSegmentIndex == 0 {
            reportMode = .request
        } else if reportSegment.selectedSegmentIndex == 1 {
            reportMode = .find
        }
        getControl(mode: reportMode)
//        updateReportUI(reportMode)
    }

    @IBAction func viewBoardButtonTapped(_ sender: Any) {
        // 게시글 보기
        toBoardDetail = getMarker?.userInfo["BoardId"] as? Int
        if reportMode == .request {
            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportDetailViewController") as? ReportDetailViewController else { return }
            viewController.reportId = toBoardDetail
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if reportMode == .find {
            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectDetailViewController") as? DetectDetailViewController else { return }
            viewController.findId = toBoardDetail
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func changeSearchLocationButtonTapped(_ sender: Any) {
        guard let SMLVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionLocationViewController") as? SelectionLocationViewController else { return }
        SMLVC.reportBoardMode = .search
        SMLVC.delegate = self
        self.navigationController?.pushViewController(SMLVC, animated: true)
    }
}

extension String {
    func toImage() -> UIImage? {
        guard let url = URL(string: self) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
    }
    
    func currentKorDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: Date())
    }
    
    func stringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        return dateFormatter.string(from: Date())
    }
    
    func stringToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss +0000" // yyyy-MM-dd HH:mm:ss
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: self)
    }
}

extension Int {
  var hour: Int {
    self / 3600
  }
  var minute: Int {
    (self % 3600) / 60
  }
  var second: Int {
    (self % 3600) % 60
  }
}

extension UIImage {
    
    func circleReSize() -> UIImage? {
        let newWidth = 36
        let newHeight = 36
        let newImageRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)

        UIBezierPath(roundedRect: newImageRect, cornerRadius: 50).addClip()
        
        self.draw(in: newImageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension EmergencyRescueViewController: SelectionLocationProtocol {    
    func dataSend(location: String, latitude: Double, longitude: Double) {
        
        let url = "https://iospring.herokuapp.com/user/update-point"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let phoneNumber = UserDefaults.standard.object(forKey: "petUserPhoneN") as! String
        print("핸드폰 번호 \(phoneNumber)")
        
        
        // POST 로 보낼 정보
        let parameter = ["phoneNumber": phoneNumber, "loadAddress": location, "latitude": latitude, "longitude": longitude] as Dictionary

        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: parameter, options: [])
        } catch {
            print("http Body Error")
        }
        
        AF.request(request).responseString { (response) in
            switch response.result {
            case .success:
                print("PUT 성공")
                debugPrint(response)
            case let .failure(error):
                print(response)
                print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
}

