//
//  DetectBoardViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/17.
//

import UIKit

class DetectBoardViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var totalPage = 3
    var currentPage = 1
    
    var searchCurrentPage = 1
    var searchTotalPage = 1
    var searchFlag = 0
    var category = ""
    var condition = ""
    
    @IBOutlet weak var writeBtn: UIButton!
    private var refreshControl = UIRefreshControl()
    
    private var boardList = [FindBoard]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "FinderCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "FinderCell")
        
        configureCollectionView()
        
        self.collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        fetchData(page: 1)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(goToDetailNotification(_:)),
            name: NSNotification.Name("newDetect"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(searchPostNotification(_:)),
            name: NSNotification.Name("searchFind"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(searchCancleNotification(_:)),
            name: NSNotification.Name("searchFindCancle"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @objc func goToDetailNotification(_ notification: Notification){
        print("받기 완료")
        guard let boardId = notification.object else { return }
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectDetailViewController") as? DetectDetailViewController else { return }
        guard let strBoardId = boardId as? String else { return }
        viewController.findId = Int(strBoardId)
        viewController.posterPhoneN = "00000000000"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func searchPostNotification(_ notification: Notification){
        guard let objectdic = notification.object as? [String:String] else { return }
        self.boardList.removeAll()
        collectionView.reloadData()
        self.searchFlag = 1
        self.searchCurrentPage = 1
        self.category = objectdic["scope"]!
        self.condition = objectdic["search"]!
        fetchSearchedData(category: self.category, condition: self.condition, page: self.searchCurrentPage)
    }
    
    @objc func searchCancleNotification(_ notification: Notification){
        self.searchFlag = 0
        self.currentPage = 1
        self.boardList.removeAll()
        self.collectionView.reloadData()
        fetchData(page: self.currentPage)
    }
    
    private func fetchSearchedData(category: String, condition: String, page: Int){
        let urlString = "https://iospring.herokuapp.com/finder/search?category=\(category)&condition=\(condition)&page=\(page)"
        let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: encodedString) else {
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
                        let decodedData = try JSONDecoder().decode(APIFinderBoardResponse<[FindBoard]>.self, from: data!)
                        self.searchTotalPage = decodedData.totalPage ?? 1
                        self.boardList.append(contentsOf: decodedData.finderBoardDTOS!)
                        self.collectionView.reloadData()
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        self.collectionView.delegate = self  // 하단 extension 참조
        self.collectionView.dataSource = self // 하단 extension 참조
        self.writeBtn.layer.cornerRadius = 6
    }
    
    private func fetchData(page: Int){
        guard let url = URL(string: "https://iospring.herokuapp.com/finder?page=\(page)") else {
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
                        let decodedData = try JSONDecoder().decode(APIFinderBoardResponse<[FindBoard]>.self, from: data!)
                        self.totalPage = decodedData.totalPage ?? 1
                        self.boardList.append(contentsOf: decodedData.finderBoardDTOS!)
                        print("find Board count = \(self.boardList.count)")
//                        for b in self.boardList{
//                            print(b.id)
//                        }
                        self.collectionView.reloadData()
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
    @objc func refresh(){
        self.boardList.removeAll()
        self.collectionView.reloadData() // Reload하여 뷰를 비워줍니다.
    }
}
extension DetectBoardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.boardList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FinderCell", for: indexPath) as? FinderCell else { return UICollectionViewCell() }
        let url = URL(string: boardList[indexPath.row].mainImageUrl!)
        let data = try? Data(contentsOf: url!)
        DispatchQueue.main.async {
            cell.petImg.image = UIImage(data: data!)
        }
        cell.petLocation.text = boardList[indexPath.row].missingLocation!
        let care = boardList[indexPath.row].care
        if(care == true){
            cell.careOption.text = "보호 중"
        }
        else{
            cell.careOption.text = "발견"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if(self.searchFlag == 0){
            if currentPage < totalPage && indexPath.row == self.boardList.count - 1 {
                self.currentPage += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.fetchData(page: self.currentPage)
                }
            }
        }
        else{
            if searchCurrentPage < searchTotalPage && indexPath.row == self.boardList.count - 1 {
                self.searchCurrentPage += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.fetchSearchedData(category: self.category, condition: self.condition, page: self.searchCurrentPage)
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (refreshControl.isRefreshing) {
            self.refreshControl.endRefreshing()

            if(self.searchFlag == 0){
                self.currentPage = 1
                fetchData(page: self.currentPage)
            }
            else{
                self.searchCurrentPage = 1
                fetchSearchedData(category: self.category, condition: self.condition, page: self.searchCurrentPage)
            }
            
        }
    }
}

extension DetectBoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 즐겨찾기 한 일기의 셀의 크기 지정
        return CGSize(width: (UIScreen.main.bounds.width)/2 - 20, height: 320)
    }
}

extension DetectBoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectDetailViewController") as? DetectDetailViewController else { return }
        let findId = self.boardList[indexPath.row].id
        let posterPhoneN = self.boardList[indexPath.row].userPhoneNumber
        viewController.findId = findId!
        viewController.posterPhoneN = posterPhoneN
//        print(posterPhoneN)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
