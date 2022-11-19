//
//  ReportDetailViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/03/23.
//

import UIKit
import Alamofire

enum ReportEditorMode{
    case new
    //    case edit(IndexPath, Report)
    case edit
}

class ReportWriteViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var report: Report?
    var indexPath: IndexPath?
    var reportId: Int?
    var pet: Pet?
    var petId: Int?
    var boardId: Int?
    var userId: Int?
    var imagePickedFlag = 0
    var posterPhoneN: String?
    var viewerPhoneN: String = ""
    var latitude: Double?
    var longitude: Double?
    @IBOutlet weak var petImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var furColorTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    private var reportDate: Date?
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var featureTextField: UITextField!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var sexSegControl: UISegmentedControl!
    @IBOutlet weak var neuteringSegControl: UISegmentedControl!
    @IBOutlet weak var diseaseTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var etcTextView: UITextView!
    @IBOutlet weak var confirmBtn: UIBarButtonItem!
    @IBOutlet weak var locationButton: UIButton!
    var reportEditMode: ReportEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner.isHidden = true
        self.configureImg()
        self.configureDatePicker()
        self.configureTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(self.reportEditMode == .edit){
            self.getInfo(id: self.reportId!)
        }
    }
    
    private func configureTextField(){
        self.breedTextField.delegate = self
        self.furColorTextField.delegate = self
        self.locationTextField.delegate = self
        self.dateTextField.delegate = self
        self.ageTextField.delegate = self
        self.featureTextField.delegate = self
        self.moneyTextField.delegate = self
        self.diseaseTextField.delegate = self
        self.ageTextField.delegate = self
        self.moneyTextField.keyboardType = .numberPad
        self.ageTextField.keyboardType = .numberPad
    }
    
    private func configureImg(){
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
        self.imagePicker.allowsEditing = true // 수정 가능 여부
        self.imagePicker.delegate = self // picker delegate
        self.petImageView.layer.borderWidth = 1
        self.petImageView.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func configureDatePicker(){
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.addTarget(self, action: #selector(dateChange(datePikcer:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        dateTextField.inputView = datePicker
        dateTextField.text = formatDate(date: Date())
        reportDate = Date()
    }
    
    private func configureEditMode(){
        switch self.reportEditMode {
        case .new:
            break
        case .edit:
            self.getInfo(id: self.reportId!)
            break
        }
    }
    
    @IBAction func tabConfirmBtn(_ sender: UIBarButtonItem) {
        guard let breed = self.breedTextField.text else { return }
        guard let color = self.furColorTextField.text else { return }
        guard let date = self.dateTextField.text else { return }
        guard let location = self.locationTextField.text else { return }
        guard let money = self.moneyTextField.text else { return }
        guard let feature = self.featureTextField.text else { return }
        guard let latitude = latitude else { return }
        guard let longitude = longitude else { return }
        let sexArray = ["남", "여", "모름"]
        let sex = sexArray[self.sexSegControl.selectedSegmentIndex]
        let operationArray = ["유", "무", "모름"]
        let operation = operationArray[self.neuteringSegControl.selectedSegmentIndex]
        guard let disease = self.diseaseTextField.text else { return }
        let ageStr = self.ageTextField.text ?? "0"
        guard let age = Int(ageStr) else { return }
        guard let etc = self.etcTextView.text else { return }
        print("등록")
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        postInfo(breed: breed, color: color, date: date, location: location, money: money, sex: sex, operation: operation, disease: disease, age: age, content: etc, missingLongitude: String(longitude), missingLatitude:
                    String(latitude), feature: feature)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func getInfo(id: Int){
        print("get info for edit")
        guard let url = URL(string: "https://iospring.herokuapp.com/detect/\(id)") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if(error != nil){
                    print(error.debugDescription)
                    return
                }
                else if( data != nil ){
                    do{
                        let decodedData = try JSONDecoder().decode(APIDetectDetailResponse.self, from: data!)
                        let url = URL(string: decodedData.mainImageUrl)
                        let data = try? Data(contentsOf: url!)
                        self.posterPhoneN = decodedData.userPhoneNumber
                        self.petImageView.image = UIImage(data: data!)
                        self.breedTextField.text = decodedData.breed
                        self.furColorTextField.text = decodedData.color
                        self.dateTextField.text = decodedData.missingTime
                        self.locationTextField.text = decodedData.missingLocation
                        if( decodedData.gender == "남" ){
                            self.sexSegControl.selectedSegmentIndex = 0
                        }
                        else if( decodedData.gender == "여" ) {
                            self.sexSegControl.selectedSegmentIndex = 1
                        }
                        else{
                            self.sexSegControl.selectedSegmentIndex = 2
                        }
                        
                        let operation = decodedData.operation
                        if(operation == true){
                            self.neuteringSegControl.selectedSegmentIndex = 0
                        }
                        else if(operation == false){
                            self.neuteringSegControl.selectedSegmentIndex = 1
                        }
                        else{
                            self.neuteringSegControl.selectedSegmentIndex = 2
                        }
                        self.featureTextField.text = decodedData.feature
                        let money = decodedData.money ?? 0
                        self.moneyTextField.text = String(money)
                        self.diseaseTextField.text = decodedData.disease
                        let age = decodedData.age ?? -1
                        self.ageTextField.text = String(age)
                        self.etcTextView.text = decodedData.content
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func postInfo(breed: String, color: String, date: String, location: String, money:String?, sex: String, operation: String, disease: String?, age: Int?, content: String?, missingLongitude: String, missingLatitude: String, feature: String?){
        
        if(self.reportEditMode == .edit && self.imagePickedFlag == 0){
            let url = "https://iospring.herokuapp.com/detect/\(self.reportId!)"
            var operationBool: String
            if(operation == "유"){
                operationBool = "true"
            }
            else if(operation == "무"){
                operationBool = "false"
            }
            else{
                operationBool = "null"
            }
            AF.upload(multipartFormData: {multipartFormData in
                multipartFormData.append("\(breed)".data(using: String.Encoding.utf8)!, withName: "breed")
                multipartFormData.append("\(color)".data(using: String.Encoding.utf8)!, withName: "color")
                multipartFormData.append("\(date)".data(using: String.Encoding.utf8)!, withName: "missingTime")
                multipartFormData.append("\(location)".data(using: String.Encoding.utf8)!, withName: "missingLocation")
                if let unwrapFeature = feature {
                    multipartFormData.append("\(unwrapFeature)".data(using: String.Encoding.utf8)!, withName: "feature")
                }
                if let unwrapEtc = content{
                    multipartFormData.append("\(unwrapEtc)".data(using: String.Encoding.utf8)!, withName: "content")
                }
                if let unwrapMoney = money {
                    multipartFormData.append("\(unwrapMoney)".data(using: .utf8)!, withName: "money")
                }
                multipartFormData.append("\(sex)".data(using: String.Encoding.utf8)!, withName: "gender")
                multipartFormData.append(operationBool.data(using: .utf8)!, withName: "isOperation")
                if let unwrapDisease = disease {
                    multipartFormData.append("\(unwrapDisease)".data(using: String.Encoding.utf8)!, withName: "disease")
                }
                if let unwrapAge = age {
                    multipartFormData.append("\(unwrapAge)".data(using: String.Encoding.utf8)!, withName: "age")
                }
                multipartFormData.append("\(missingLongitude)".data(using: String.Encoding.utf8)!, withName: "missingLongitude")
                multipartFormData.append("\(missingLatitude)".data(using: String.Encoding.utf8)!, withName: "missingLatitude")
            }, to: url, method: .put)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success:
                    debugPrint(response)
                    NotificationCenter.default.post(name: NSNotification.Name("postReport"), object: nil)
                    self.spinner.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    print(error)
                }
            }
        }
        else if( self.reportEditMode == .edit && self.imagePickedFlag == 1 ){
            let url = "https://iospring.herokuapp.com/detect/\(self.reportId!)"
            
            var operationBool: String
            if(operation == "유"){
                operationBool = "true"
            }
            else if(operation == "무"){
                operationBool = "false"
            }
            else{
                operationBool = "null"
            }
            AF.upload(multipartFormData: {multipartFormData in
                let imageData: Data? = self.petImageView.image?.pngData()!
                multipartFormData.append(imageData!, withName: "file", fileName: "testImage.png", mimeType: "image/png")
                multipartFormData.append("\(breed)".data(using: String.Encoding.utf8)!, withName: "breed")
                multipartFormData.append("\(color)".data(using: String.Encoding.utf8)!, withName: "color")
                multipartFormData.append("\(date)".data(using: String.Encoding.utf8)!, withName: "missingTime")
                multipartFormData.append("\(location)".data(using: String.Encoding.utf8)!, withName: "missingLocation")
                if let unwrapFeature = feature {
                    multipartFormData.append("\(unwrapFeature)".data(using: String.Encoding.utf8)!, withName: "feature")
                }
                if let unwrapEtc = content{
                    multipartFormData.append("\(unwrapEtc)".data(using: String.Encoding.utf8)!, withName: "content")
                }
                if let unwrapMoney = money {
                    multipartFormData.append("\(unwrapMoney)".data(using: .utf8)!, withName: "money")
                }
                multipartFormData.append("\(sex)".data(using: String.Encoding.utf8)!, withName: "gender")
                multipartFormData.append(operationBool.data(using: .utf8)!, withName: "isOperation")
                if let unwrapDisease = disease {
                    multipartFormData.append("\(unwrapDisease)".data(using: String.Encoding.utf8)!, withName: "disease")
                }
                if let unwrapAge = age {
                    multipartFormData.append("\(unwrapAge)".data(using: String.Encoding.utf8)!, withName: "age")
                }
                multipartFormData.append("\(missingLongitude)".data(using: String.Encoding.utf8)!, withName: "missingLongitude")
                multipartFormData.append("\(missingLatitude)".data(using: String.Encoding.utf8)!, withName: "missingLatitude")
            }, to: url, method: .put)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success:
                    debugPrint(response)
                    NotificationCenter.default.post(name: NSNotification.Name("postReport"), object: nil)
                    self.spinner.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    print(error)
                }
            }
        }
        else if(self.reportEditMode == .new){
            let url = "https://iospring.herokuapp.com/detect"
            var operationBool: String
            if(operation == "유"){
                operationBool = "true"
            }
            else if(operation == "무"){
                operationBool = "false"
            }
            else{
                operationBool = "null"
            }
            AF.upload(multipartFormData: {multipartFormData in
                let imageData: Data? = self.petImageView.image?.pngData()!
                multipartFormData.append(imageData!, withName: "file", fileName: "testImage.png", mimeType: "image/png")
                multipartFormData.append("\(breed)".data(using: String.Encoding.utf8)!, withName: "breed")
                multipartFormData.append("\(color)".data(using: String.Encoding.utf8)!, withName: "color")
                multipartFormData.append("\(date)".data(using: String.Encoding.utf8)!, withName: "missingTime")
                multipartFormData.append("\(location)".data(using: String.Encoding.utf8)!, withName: "missingLocation")
                if let unwrapFeature = feature {
                    multipartFormData.append("\(unwrapFeature)".data(using: String.Encoding.utf8)!, withName: "feature")
                }
                if let unwrapEtc = content{
                    multipartFormData.append("\(unwrapEtc)".data(using: String.Encoding.utf8)!, withName: "content")
                }
                if let unwrapMoney = money {
                    multipartFormData.append("\(unwrapMoney)".data(using: .utf8)!, withName: "money")
                }
                multipartFormData.append("\(sex)".data(using: String.Encoding.utf8)!, withName: "gender")
                multipartFormData.append(operationBool.data(using: .utf8)!, withName: "isOperation")
                if let unwrapDisease = disease {
                    multipartFormData.append("\(unwrapDisease)".data(using: String.Encoding.utf8)!, withName: "disease")
                }
                if let unwrapAge = age {
                    multipartFormData.append("\(unwrapAge)".data(using: String.Encoding.utf8)!, withName: "age")
                }
                multipartFormData.append("\(missingLongitude)".data(using: String.Encoding.utf8)!, withName: "missingLongitude")
                multipartFormData.append("\(missingLatitude)".data(using: String.Encoding.utf8)!, withName: "missingLatitude")
            }, to: url, method: .post)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success:
                    debugPrint(response)
                    self.spinner.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    
    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    @objc func dateChange(datePikcer: UIDatePicker){
        dateTextField.text = formatDate(date: datePikcer.date)
        self.reportDate = datePikcer.date
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        print("위치 설정 버튼 클릭")
        guard let SMLVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionLocationViewController") as? SelectionLocationViewController else { return }
        SMLVC.reportBoardMode = .request
        SMLVC.delegate = self
        self.navigationController?.pushViewController(SMLVC, animated: true)
    }

    
    @IBAction func pickImg(_ sender: UIButton) {
        self.present(self.imagePicker, animated: true)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension ReportWriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage? = nil // update 할 이미지
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 원본 이미지가 있을 경우
        }
        let resizedImg = resizeImage(image: newImage!, targetSize: CGSize(width: 224.0, height: 224.0))
        self.petImageView.image = resizedImg // 받아온 이미지를 update
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
        self.imagePickedFlag = 1
    }
}

extension ReportWriteViewController: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ReportWriteViewController: SelectionLocationProtocol {
    func dataSend(location: String, latitude: Double, longitude: Double) {
        self.locationTextField.text = location
        self.latitude = latitude
        self.longitude = longitude
    }
}
