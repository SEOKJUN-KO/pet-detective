//
//  DetectWriteViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/17.
//

import UIKit
import Alamofire


enum DetectEditorMode{
    case new
    case edit
}

class DetectWriteViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    var reportEditMode: DetectEditorMode = .new
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var breedTextField: UITextField!
    @IBOutlet weak var furColorTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var protectSegControl: UISegmentedControl!
    @IBOutlet weak var featureTextField: UITextField!
    @IBOutlet weak var sexSegControl: UISegmentedControl!
    @IBOutlet weak var neuteringSegControl: UISegmentedControl!
    @IBOutlet weak var etcTextView: UITextView!
    private var findDate: Date?
    var find: Find?
//    var indexPath: IndexPath?
    var findId: Int?
//    var userId: Int?
    var imagePickedFlag = 0
    var latitude: Double?
    var longitude: Double?
//    var posterPhoneN = String?
    
    var detectEdictorMode: DetectEditorMode = .new
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImg()
        configureDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(self.detectEdictorMode)
        if( self.detectEdictorMode == .edit){
            getInfo(id: findId!)
        }
    }
    
    private func configureTextField(){
        self.breedTextField.delegate = self
        self.furColorTextField.delegate = self
        self.locationTextField.delegate = self
        self.dateTextField.delegate = self
        self.featureTextField.delegate = self
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
        findDate = Date()
    }
    
    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    @objc func dateChange(datePikcer: UIDatePicker){
        dateTextField.text = formatDate(date: datePikcer.date)
        
        self.findDate = datePikcer.date
    }
    
    @IBAction func pickImage(_ sender: UIButton) {
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
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        guard let SMLVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectionLocationViewController") as? SelectionLocationViewController else { return }
        SMLVC.reportBoardMode = .find
        SMLVC.delegate = self
        self.navigationController?.pushViewController(SMLVC, animated: true)
    }
    
    @IBAction func submitBtn(_ sender: UIBarButtonItem) {
        let breed = self.breedTextField.text ?? ""
        let color = self.furColorTextField.text ?? ""
        let date = self.dateTextField.text ?? ""
        let location = self.locationTextField.text ?? ""
        let careSeg = self.protectSegControl.selectedSegmentIndex
        let latitude = self.latitude ?? 0.0
        let longitude = self.longitude ?? 0.0
        var care = "false"
        if(careSeg == 1){
            care = "true"
        }
        let feature = self.featureTextField.text ?? ""
        let sexSeg = self.sexSegControl.selectedSegmentIndex
        var sex = "남"
        if(sexSeg == 0){
            sex = "남"
        }
        else if(sexSeg == 1){
            sex = "여"
        }
        else{
            sex = "모름"
        }
        let operationSeg = self.neuteringSegControl.selectedSegmentIndex
        var neutering = "true"
        if(operationSeg == 0){
            neutering = "true"
        }
        else if(operationSeg == 1){
            neutering = "false"
        }
        else{
            neutering = "null"
        }
        let content = self.etcTextView.text ?? ""
        postInfo(breed: breed, color: color, date: date, location: location, care: care, sex: sex, operation: neutering, disease: "", feature: feature, missingLongitude: String(longitude), missingLatitude: String(latitude), content: content)
    }
    private func postInfo(breed: String, color: String, date: String, location: String, care: String, sex: String, operation: String, disease: String?, feature: String, missingLongitude: String, missingLatitude: String, content: String){
        if(self.detectEdictorMode == .edit && self.imagePickedFlag == 0){
            let url = "https://iospring.herokuapp.com/finder/\(self.findId!)"
            AF.upload(multipartFormData: {multipartFormData in
                multipartFormData.append("\(breed)".data(using: String.Encoding.utf8)!, withName: "breed")
                multipartFormData.append("\(color)".data(using: String.Encoding.utf8)!, withName: "color")
                multipartFormData.append("\(date)".data(using: String.Encoding.utf8)!, withName: "missingTime")
                multipartFormData.append("\(location)".data(using: String.Encoding.utf8)!, withName: "missingLocation")
                multipartFormData.append("\(missingLongitude)".data(using: String.Encoding.utf8)!, withName: "missingLongitude")
                multipartFormData.append("\(missingLatitude)".data(using: String.Encoding.utf8)!, withName: "missingLatitude")
                multipartFormData.append("2".data(using: String.Encoding.utf8)!, withName: "age")
                multipartFormData.append(feature.data(using: String.Encoding.utf8)!, withName: "feature")
                multipartFormData.append("".data(using: String.Encoding.utf8)!, withName: "disease")
                multipartFormData.append("\(sex)".data(using: String.Encoding.utf8)!, withName: "gender")
                multipartFormData.append(content.data(using: String.Encoding.utf8)!, withName: "content")
                multipartFormData.append(care.data(using: String.Encoding.utf8)!, withName: "care")
                multipartFormData.append(operation.data(using: .utf8)!, withName: "operation")
            }, to: url, method: .put)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success:
                    debugPrint(response)
                    NotificationCenter.default.post(name: NSNotification.Name("postFind"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    print(error)
                }
            }
        }
        else if( self.detectEdictorMode == .edit && self.imagePickedFlag == 1 ){
            let url = "https://iospring.herokuapp.com/finder/\(self.findId!)"
            AF.upload(multipartFormData: {multipartFormData in
                let imageData: Data? = self.petImageView.image?.pngData()!
                multipartFormData.append(imageData!, withName: "file", fileName: "testImage.png", mimeType: "image/png")
                multipartFormData.append("\(breed)".data(using: String.Encoding.utf8)!, withName: "breed")
                multipartFormData.append("\(color)".data(using: String.Encoding.utf8)!, withName: "color")
                multipartFormData.append("\(date)".data(using: String.Encoding.utf8)!, withName: "missingTime")
                multipartFormData.append("\(location)".data(using: String.Encoding.utf8)!, withName: "missingLocation")
                multipartFormData.append("\(missingLongitude)".data(using: String.Encoding.utf8)!, withName: "missingLongitude")
                multipartFormData.append("\(missingLatitude)".data(using: String.Encoding.utf8)!, withName: "missingLatitude")
                multipartFormData.append("2".data(using: String.Encoding.utf8)!, withName: "age")
                multipartFormData.append(feature.data(using: String.Encoding.utf8)!, withName: "feature")
                multipartFormData.append("".data(using: String.Encoding.utf8)!, withName: "disease")
                multipartFormData.append("\(sex)".data(using: String.Encoding.utf8)!, withName: "gender")
                multipartFormData.append(content.data(using: String.Encoding.utf8)!, withName: "content")
                multipartFormData.append(care.data(using: String.Encoding.utf8)!, withName: "care")
                multipartFormData.append(operation.data(using: .utf8)!, withName: "operation")
            }, to: url, method: .put)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success:
                    debugPrint(response)
                    NotificationCenter.default.post(name: NSNotification.Name("postFind"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    print(error)
                }
            }
        }
        else if(self.detectEdictorMode == .new){
            
            let url = "https://iospring.herokuapp.com/finder"
            AF.upload(multipartFormData: {multipartFormData in
                let imageData: Data? = self.petImageView.image?.pngData()!
                multipartFormData.append(imageData!, withName: "file", fileName: "testImage.png", mimeType: "image/png")
                multipartFormData.append("\(breed)".data(using: String.Encoding.utf8)!, withName: "breed")
                multipartFormData.append("\(color)".data(using: String.Encoding.utf8)!, withName: "color")
                multipartFormData.append("\(date)".data(using: String.Encoding.utf8)!, withName: "missingTime")
                multipartFormData.append("\(location)".data(using: String.Encoding.utf8)!, withName: "missingLocation")
                multipartFormData.append("\(missingLongitude)".data(using: String.Encoding.utf8)!, withName: "missingLongitude")
                multipartFormData.append("\(missingLatitude)".data(using: String.Encoding.utf8)!, withName: "missingLatitude")
                multipartFormData.append("2".data(using: String.Encoding.utf8)!, withName: "age")
                multipartFormData.append(feature.data(using: String.Encoding.utf8)!, withName: "feature")
                multipartFormData.append("".data(using: String.Encoding.utf8)!, withName: "disease")
                multipartFormData.append("\(sex)".data(using: String.Encoding.utf8)!, withName: "gender")
                multipartFormData.append(content.data(using: String.Encoding.utf8)!, withName: "content")
                multipartFormData.append(care.data(using: String.Encoding.utf8)!, withName: "care")
                multipartFormData.append(operation.data(using: .utf8)!, withName: "operation")
            }, to: url, method: .post)
            .validate(statusCode: 200..<500)
            .responseData { response in
                switch response.result {
                case .success:
                    debugPrint(response)
                    self.navigationController?.popViewController(animated: true)
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    private func getInfo(id: Int){
        guard let url = URL(string: "https://iospring.herokuapp.com/finder/\(id)") else {
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
                        let decodedData = try JSONDecoder().decode(APIFinderDetailResponse.self, from: data!)
                        let url = URL(string: decodedData.mainImageUrl)
                        let data = try? Data(contentsOf: url!)
                        self.petImageView.image = UIImage(data: data!)
                        self.breedTextField.text = decodedData.breed
                        self.furColorTextField.text = decodedData.color
                        self.dateTextField.text = decodedData.missingTime
                        self.locationTextField.text = decodedData.missingLocation
                        let care = decodedData.care
                        if(care == true){
                            self.protectSegControl.selectedSegmentIndex = 0
                        }
                        else{
                            self.protectSegControl.selectedSegmentIndex = 1
                        }
                        let sex = decodedData.gender
                        if(sex == "남"){
                            self.sexSegControl.selectedSegmentIndex = 0
                        }else if(sex == "여"){
                            self.sexSegControl.selectedSegmentIndex = 1
                        }else{
                            self.sexSegControl.selectedSegmentIndex = 2
                        }
                        let operation = decodedData.operation
                        if(operation == true){
                            self.neuteringSegControl.selectedSegmentIndex = 0
                        }
                        else if(operation == false){
                            self.neuteringSegControl.selectedSegmentIndex = 0
                        }
                        else{
                            self.neuteringSegControl.selectedSegmentIndex = 0
                        }
                        self.featureTextField.text = decodedData.feature
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
}

extension DetectWriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        let url1 = "https://iospring-teachable.herokuapp.com/breed"
        
        AF.upload(multipartFormData: {multipartFormData in
            let imageData: Data? = self.petImageView.image?.pngData()!
            multipartFormData.append(imageData!, withName: "uploadFile", fileName: "testImage.png", mimeType: "image/png")
        }, to: url1, method: .post)
        .validate(statusCode: 200..<500)
        .responseData { response in
            switch response.result {
            case .success:
                guard let data = response.data else {return}
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([Prediction].self, from: data)
                    self.breedTextField.text = json[0].prediction
                }
                catch {
                    print("error!\(error)")
                }
            case let .failure(error):
                print(error)
            }
        }
        
        let url2 = "https://iospring-teachable.herokuapp.com/color"
        
        AF.upload(multipartFormData: {multipartFormData in
            let imageData: Data? = self.petImageView.image?.pngData()!
            multipartFormData.append(imageData!, withName: "uploadFile", fileName: "testImage.png", mimeType: "image/png")
        }, to: url2, method: .post)
        .validate(statusCode: 200..<500)
        .responseData { response in
            switch response.result {
            case .success:
                guard let data = response.data else {return}
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([Prediction].self, from: data)
                    self.furColorTextField.text = json[0].prediction
                }
                catch {
                    print("error!\(error)")
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}

extension DetectWriteViewController: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

extension DetectWriteViewController: SelectionLocationProtocol {
    func dataSend(location: String, latitude: Double, longitude: Double) {
        self.locationTextField.text = location
        self.latitude = latitude
        self.longitude = longitude
    }
}
