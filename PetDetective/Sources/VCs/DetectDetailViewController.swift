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
    var findId: Int?
    var posterPhoneN: String?
    var viewerPhoneN: String = ""
    @IBOutlet weak var myPostStackBtn: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo(id: findId!)
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
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "petUserPhoneN") as? String else { return }
        self.viewerPhoneN = data
        if(self.posterPhoneN != self.viewerPhoneN){
            self.myPostStackBtn.isHidden = true
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
    
    @IBAction func editBtn(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectWriteViewController") as? DetectWriteViewController else { return }
        viewController.detectEdictorMode = .edit
        viewController.findId = self.findId!
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
