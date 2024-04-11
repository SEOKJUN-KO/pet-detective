//
//  DetectDetailViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/17.
//

import UIKit

class DetectDetailViewController: UIViewController {
  
  @IBOutlet weak var petImageView: UIImageView!
  @IBOutlet weak var careStatus: UILabel!
  @IBOutlet weak var breedLabel: UILabel!
  @IBOutlet weak var furColorLabel: UILabel!
  @IBOutlet weak var findDateLabel: UILabel!
  @IBOutlet weak var findLocationLabel: UILabel!
  @IBOutlet weak var featureLabel: UILabel!
  @IBOutlet weak var sexLabel: UILabel!
  @IBOutlet weak var operationLabel: UILabel!
  @IBOutlet weak var etcTextView: UITextView!
  @IBOutlet weak var myPostStackBtn: UIStackView!
  
  var findId: Int?
  var posterPhoneN: String?
  var viewerPhoneN: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // 정보 불러오기
    getInfo(id: findId!)
    // 수정하기를 통해 글을 수정했을 때,수정된 정보를 다시 받아오기 위함
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(reGetInfo(_:)),
      name: NSNotification.Name("postFind"),
      object: nil
    )
  }
  
  @objc func reGetInfo(_ notification: Notification) {
    getInfo(id: self.findId!)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    // 글쓴이가 본인인지 확인하여, 삭제, 수정 권한을 줌
    let userDefaults = UserDefaults.standard
    guard let data = userDefaults.object(forKey: "petUserPhoneN") as? String else { return }
    self.viewerPhoneN = data
    if(self.posterPhoneN != self.viewerPhoneN){
      self.myPostStackBtn.isHidden = true
    }
  }
  
  // 상세 발견/보호 게시글 페이지 정보 불러오기
  // 에러 핸들링을 하지 않은게 아쉽다, 현재 페이지에서 다시 불러오기 버튼을 만들면 좋을 것 같다.
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
            let care = decodedData.care
            if(care == true){
              self.careStatus.text = "보호 중"
            }
            else{
              self.careStatus.text = "발견"
            }
            self.breedLabel.text = decodedData.breed
            self.furColorLabel.text = decodedData.color
            self.findDateLabel.text = "오늘"
            self.findLocationLabel.text = decodedData.missingLocation
            self.sexLabel.text = decodedData.gender
            let operation = decodedData.operation
            if(operation == true){
              self.operationLabel.text = "유"
            }
            else{
              self.operationLabel.text = "무"
            }
            self.featureLabel.text = decodedData.feature
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
  // 수정하기 페이지로 진입
  @IBAction func editBtn(_ sender: UIButton) {
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectWriteViewController") as? DetectWriteViewController else { return }
    viewController.detectEdictorMode = .edit
    viewController.findId = self.findId!
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  // 발견/보호 게시글 삭제
  @IBAction func removeBtn(_ sender: UIButton) {
    guard let url = URL(string: "https://iospring.herokuapp.com/finder/\(self.findId!)") else {
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if(error != nil){
          print(error.debugDescription)
          return
        }
        else if( data != nil ){
          self.navigationController?.popViewController(animated: true)
        }
      }
    }
    task.resume()
  }
  // NotificationCenter 옵저버 제거
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
