//
//  LoginViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/05/02.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
  
  @IBOutlet weak var cellphoneTextField: UITextField!
  private var phoneNumber: String = ""
  @IBOutlet weak var authBtn: UIButton!
  private var cernum: String = "-1"
  @IBOutlet weak var sendAuthBtn: UIButton!
  @IBOutlet weak var emailTextField: UITextField!
  private var email:String = ""
  @IBOutlet weak var locationTextField: UITextField!
  private var longitude: Double = 0.0
  private var latitude: Double = 0.0
  private var address: String = "서울"
  @IBOutlet weak var getLocBtn: UIButton!
  @IBOutlet weak var submitBtn: UIButton!
  @IBOutlet weak var cancleBtn: UIButton!
  @IBOutlet weak var reGetPNBtn: UIButton!
  
  var needjoin: Bool = true
  private var deviceToken: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    cellphoneTextField.keyboardType = .numberPad
    loadDeviceToken()
  }
  
  // 회원가입 여부 체크 용 - 핸드폰 번호, 푸쉬 알림 용 - 디바이스 토큰
  private func loadDeviceToken(){
    let userDefaults = UserDefaults.standard
    guard let data = userDefaults.object(forKey: "petDeviceToken") as? String else { return }
    self.deviceToken = data
  }
  // 위치 서비스를 위한 위치 정보 받기 용 - 다른 팀원 코드
  @IBAction func locationButtonTapped(_ sender: Any) {
    guard let SMLVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionLocationViewController") as? SelectionLocationViewController else { return }
    SMLVC.reportBoardMode = .search
    SMLVC.delegate = self
    self.navigationController?.pushViewController(SMLVC, animated: true)
  }
  
  // 핸드폰 번호 입력 후 데이터 전송 후 인증번호 입력 작동으로 넘어가기
  @IBAction func authenticationBtn(_ sender: UIButton) {
    self.phoneNumber = cellphoneTextField.text!
    self.view.endEditing(true)
    // 핸드폰 번호 받는 필드를 인증 번호 받는 것으로 다시 활용
    self.cellphoneTextField.text = ""
    self.cellphoneTextField.placeholder = "인증번호 입력"
    self.authBtn.isHidden = true
    self.sendAuthBtn.isHidden = false
    self.reGetPNBtn.isHidden = false
    // 나중에 게시글 등에서 지속적으로 사용
    let userDefaults = UserDefaults.standard
    userDefaults.set(phoneNumber, forKey: "petUserPhoneN")
    
    // 문자 전송
    let url = "https://iospring.herokuapp.com/check/sendSMS"
    
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 10
    
    let params = ["phoneNumber":"\(self.phoneNumber)", "deviceToken":"\(self.deviceToken)"] as Dictionary
    
    do {
      try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
    } catch {
      print("http Body Error")
    }
    // 핸드폰 번호와 디바이스 토큰을 post로 보내면 인증번호와 회원가입이 필요한지 반환해줌
    // 지금보면 문제 상황에 대한 화면처리를 해주지 않은게 아쉬움
    AF.request(request)
      .validate(statusCode: 200..<500)
      .responseData { response in
        switch response.result {
        case .success:
          if let data = response.data {
            do{
              debugPrint(response)
              let decodedData = try JSONDecoder().decode(GetCertificationNumber.self, from: data)
              print(decodedData.cernum)
              self.cernum = decodedData.cernum
              self.needjoin = decodedData.needjoin
            } catch {
              print(error)
            }
          }
        case let .failure(error):
          print(error)
        }
      }
  }
  
  // 인증번호 확인용 버튼
  @IBAction func secondAuthFunc(_ sender: UIButton) {
    self.view.endEditing(true)
    if(self.cernum == cellphoneTextField.text!){
      self.sendAuthBtn.isHidden = true
      // 회원가입이 필요하다면, 이메일과 위치 정보를 추가로 입력 받음
      // locationTextField를 disabled 했으면 좋았을 것 같음
      if ( self.needjoin == true){
        self.cellphoneTextField.text = ""
        emailTextField.isHidden = false
        locationTextField.isHidden = false
        cellphoneTextField.isHidden = true
        getLocBtn.isHidden = false
        submitBtn.isHidden = false
        cancleBtn.isHidden = false
        reGetPNBtn.isHidden = true
      }
      else{
        // 회원가입이 이미 이루어졌다면, 서비스 페이지로 넘어감
        transitionToService()
      }
    }
    else{
      self.cellphoneTextField.text = ""
      self.cellphoneTextField.placeholder = "인증번호가 틀렸습니다."
    }
    
  }
  // 인증 번호를 받고 취소버튼을 눌렀을 때,
  @IBAction func reGetPN(_ sender: UIButton) {
    self.authBtn.isHidden = false
    self.sendAuthBtn.isHidden = true
    self.reGetPNBtn.isHidden = true
    self.cernum = "-1"
    self.phoneNumber = "-1"
  }
  // 회원가입
  @IBAction func submitInfo(_ sender: UIButton) {
    
    self.email = self.emailTextField.text!
    
    let url = "https://iospring.herokuapp.com/join"
    
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 10
    
    let params = ["phoneNumber":"\(self.phoneNumber)", "email":"\(self.email)", "loadAddress":"\(self.address)", "latitude": "\(self.latitude)", "longitude":"\(self.longitude)", "deviceToken":"\(self.deviceToken)"] as Dictionary
    
    do {
      try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
    } catch {
      print("http Body Error")
    }
    
    AF.request(request)
      .validate(statusCode: 200..<500)
      .responseData { response in
        switch response.result {
        case .success:
          guard let data = response.data else { return }
          guard let id = String(data: data, encoding: String.Encoding.utf8) as String? else { return }
          let userDefaults = UserDefaults.standard
          userDefaults.set(id, forKey: "petUserId")
          self.transitionToService()
        case let .failure(error):
          print(error)
        }
      }
  }
  
  // 인증 처음으로 돌아가기
  @IBAction func cancleAll(_ sender: UIButton) {
    self.cellphoneTextField.isHidden = false
    self.authBtn.isHidden = false
    self.emailTextField.isHidden = true
    self.locationTextField.isHidden = true
    self.getLocBtn.isHidden = true
    self.cancleBtn.isHidden = true
    self.submitBtn.isHidden = true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  // 인증 완료 시, 서비스 화면으로 이동
  // 루트 뷰를 아예 바꿔버리는 동작을 했는데
  // 변수들이 weak로 선언되어있고 이 코드가 실행되는 상황은 네비게이션 스택에 뷰가 쌓이지 않고 다른 참조도 하고 있지 않기에
  // 메모리 관련 처리를 추가적으로 하지는 않음
  // 그래도 추가 개발과 예외상황을 고려하여, 처리하면 좋을 듯
  private func transitionToService(){
    let ServiceViewController = storyboard?.instantiateViewController(withIdentifier: "ServiceTabBarController") as? UITabBarController
    
    view.window?.rootViewController = ServiceViewController
    view.window?.makeKeyAndVisible()
  }
}
// 팀원 작성
extension LoginViewController: SelectionLocationProtocol {
  func dataSend(location: String, latitude: Double, longitude: Double) {
    self.locationTextField.text = location
    self.latitude = latitude
    self.longitude = longitude
  }
}
