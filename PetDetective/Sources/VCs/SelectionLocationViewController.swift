//
//  SelectionMssingLocationViewController.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/03/25.
//

import NMapsMap

enum ReportBoardMode {
    case request
    case find
    case search
}

protocol SelectionLocationProtocol {
    func dataSend(location: String, latitude: Double, longitude: Double)
}

class SelectionLocationViewController: MapViewController {
    
    let customMapView = MapView()
    var reportBoardMode: ReportBoardMode?
    var delegate: SelectionLocationProtocol?
    var missingLatitude: Double?   // 위도
    var missingLongtitude: Double? // 경도
    var missingAddress: String? {
        didSet {
            customMapView.addressLabel.text = missingAddress
        }
    }
    
    @IBOutlet weak var nofiForPinLabel: UILabel!
    @IBOutlet weak var locationPointLabel: UILabel!
    @IBOutlet weak var missingMapView: UIView!
    
    @IBOutlet weak var pointImageView: UIImageView!
    
    override var isAuthorized: Bool? {
        didSet {
            updateUIFromMode(isAuthorized: isAuthorized, naverMapView: customMapView.naverMapView, customMapView.addressLabel, customMapView.setLocationButton)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.missingMapView.addSubview(customMapView)
        
        customMapView.translatesAutoresizingMaskIntoConstraints = false
        customMapView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        customMapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        customMapView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        customMapView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        setLocationManager()
        
        updateReportModeUI()
        
        customMapView.mapView.addCameraDelegate(delegate: self)
        
        customMapView.setLocationButton.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        
    }
    
    func updateReportModeUI() {
        
        if reportBoardMode == .request {
            customMapView.setLocationButton.setTitle("실종 위치 설정", for: .normal)
            
            locationPointLabel.text = "실종"
            
            customMapView.setLocationButton.backgroundColor = .systemRed
            
            pointImageView.image = UIImage(named: "MissingPoint")
            
            nofiForPinLabel.text = "실종 위치로 부터 3km 이내의 탐정단들에게 알림이 갑니다."
        }
        else if reportBoardMode == .find {
            customMapView.setLocationButton.setTitle("발견 위치 설정", for: .normal)
            
            locationPointLabel.text = "발견"
            
            customMapView.setLocationButton.backgroundColor = .systemRed
            
            pointImageView.image = UIImage(named: "MissingPoint")
            
            nofiForPinLabel.text = "목격 위치로 3km 이내의 실종 견주들에게 알림이 갑니다."
        }
        else if reportBoardMode == .search {
            customMapView.setLocationButton.setTitle("탐색 위치 설정", for: .normal)
            
            locationPointLabel.text = "탐색 위치"
            
            customMapView.setLocationButton.backgroundColor = .systemGreen
            
            pointImageView.image = UIImage(named: "SearchPoint")
            
            nofiForPinLabel.text = "탐색 위치로부터 3km 이내의 실종견애 대한 알림이 옵니다."
        }
    }
    
    @objc func buttonTapped(button: UIButton) {
        guard let location = customMapView.addressLabel.text else { return }
        guard let latitude = missingLatitude else { return }
        guard let longitude = missingLongtitude else { return }
        delegate?.dataSend(location: location, latitude: latitude, longitude: longitude)
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectionLocationViewController {
    // 카메라 움직임 종료시 실행
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        
        let cameraPosition = mapView.cameraPosition // 카메라 현재 위치 (지도 중앙 좌표)
        let centerLat = cameraPosition.target.lat
        let centerLng = cameraPosition.target.lng
        
        // 좌표 주소 변환
        // 위도 경도 주소 저장
        findAddress(lat: centerLat, long: centerLng, completion: { (centerAddress) in
            if let centerAddress = centerAddress {
                self.missingLatitude = centerLat
                self.missingLongtitude = centerLng
                self.missingAddress = centerAddress
                print("실종 (카메라 중앙) 좌표 \(centerLat), \(centerLng), \(centerAddress)")
            }
        })
    }
    
    //    // 카메라 이동 함수 cameraIsChangingByReason
    //    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
    //
    ////        let cameraPosition = NMFCameraPosition() // 카메라 위치 객체 생성
    //        print("빠른 이동")
    //        let cameraPosition = mapView.cameraPosition // 카메라 현재위치
    //
    ////        let x = self.mapView.frame.width / 2
    ////        let y = self.mapView.frame.height / 2
    ////
    ////        let projection = mapView.projection // 카메라 투영
    ////        let coord = projection.latlng(from: CGPoint(x: x, y: y)) // 0.5, 0.5
    //
    //    }
        
    //    func mapViewRegionIsChanging(_ mapView: NMFMapView, byReason reason: Int) {
    //        print("카메라 변경 - reason: \(reason)")
    //
    //        let cameraPosition = NMFCameraPosition() // 카메라 위치 객체 생성
    //
    //        let centerLat = cameraPosition.target.lat
    //        let centerLng = cameraPosition.target.lng
    //
    //        let marker = NMFMarker()
    //        marker.position = NMGLatLng(lat: centerLat, lng: centerLng)
    //        marker.mapView = mapView
    //        print("중앙 좌표 \(centerLat), \(centerLng)")
    //    }
}



