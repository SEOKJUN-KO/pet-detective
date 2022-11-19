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
    
    private func loadDeviceToken(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "petDeviceToken") as? String else { return }
        self.deviceToken = data
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        guard let SMLVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionLocationViewController") as? SelectionLocationViewController else { return }
        SMLVC.reportBoardMode = .search
        SMLVC.delegate = self
        self.navigationController?.pushViewController(SMLVC, animated: true)
    }
    
    @IBAction func authenticationBtn(_ sender: UIButton) {
        self.phoneNumber = cellphoneTextField.text!
        self.view.endEditing(true)
        self.cellphoneTextField.text = ""
        self.cellphoneTextField.placeholder = "인증번호 입력"
        self.authBtn.isHidden = true
        self.sendAuthBtn.isHidden = false
        self.reGetPNBtn.isHidden = false
        let userDefaults = UserDefaults.standard
        userDefaults.set(phoneNumber, forKey: "petUserPhoneN")
        
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

    
    @IBAction func secondAuthFunc(_ sender: UIButton) {
        self.view.endEditing(true)
        if(self.cernum == cellphoneTextField.text!){
            self.sendAuthBtn.isHidden = true
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
                transitionToService()
            }
        }
        else{
            self.cellphoneTextField.text = ""
            self.cellphoneTextField.placeholder = "인증번호가 틀렸습니다."
        }
        
    }
    @IBAction func reGetPN(_ sender: UIButton) {
        self.authBtn.isHidden = false
        self.sendAuthBtn.isHidden = true
        self.reGetPNBtn.isHidden = true
        self.cernum = "-1"
        self.phoneNumber = "-1"
    }
    
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
                debugPrint(response)
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
    
    
    private func transitionToService(){
        let ServiceViewController = storyboard?.instantiateViewController(withIdentifier: "ServiceTabBarController") as? UITabBarController
        
        view.window?.rootViewController = ServiceViewController
        view.window?.makeKeyAndVisible()
    }
}

extension LoginViewController: SelectionLocationProtocol {
    func dataSend(location: String, latitude: Double, longitude: Double) {
        self.locationTextField.text = location
        self.latitude = latitude
        self.longitude = longitude
    }
}
