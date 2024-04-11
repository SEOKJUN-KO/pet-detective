//
//  DetectBoardViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/17.
//

import UIKit

class DetectBoardViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  // 무한스크롤 용도
  var totalPage = 3
  var currentPage = 1
  // 검색 용도
  var searchCurrentPage = 1
  var searchTotalPage = 1
  var searchFlag = 0
  var category = ""
  var condition = ""
  // 발견하기 글쓰기
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
    // 알림 생성 확인
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
  
  @objc func goToDetailNotification(_ notification: Notification){
    // [ 실종된 반려견 정보와 유사한 정보 업로드 알림 선택 시 ]
    guard let boardId = notification.object else { return }
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectDetailViewController") as? DetectDetailViewController else { return }
    guard let strBoardId = boardId as? String else { return }
    // viewWillApear에서 비교문에서 posterPhoneN가 바로 사용되기 때문에 값을 미리 준 것 같음
    // 지금이라면 if let으로 처리할 듯
    viewController.findId = Int(strBoardId)
    viewController.posterPhoneN = "00000000000"
    // 발견 게시글로 이동
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  @objc func searchPostNotification(_ notification: Notification){
    // [ 검색어 입력 + 검색 동작 ]
    guard let objectdic = notification.object as? [String:String] else { return }
    self.boardList.removeAll()
    collectionView.reloadData()
    self.searchFlag = 1
    self.searchCurrentPage = 1
    self.category = objectdic["scope"]!
    self.condition = objectdic["search"]!
    // 검색 api -> 뷰의 따로 함수로 빼두기 보단, class로 api 관련 함수 모아둘 듯
    fetchSearchedData(category: self.category, condition: self.condition, page: self.searchCurrentPage)
  }
  
  @objc func searchCancleNotification(_ notification: Notification){
    // [ 검색 취소 ]
    self.searchFlag = 0
    self.currentPage = 1
    // 검색 동작을 실행 했는지 체크하고, 지울 듯
    self.boardList.removeAll()
    self.collectionView.reloadData()
    fetchData(page: self.currentPage)
  }
  // 카테고리 + 검색어로 데이터 받기
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
  
  // 기본 데이터 불러오기
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
  // 데이터에 해당하는 셀 어떻게 그릴 것인지
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // 셀을 재사용
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FinderCell", for: indexPath) as? FinderCell else { return UICollectionViewCell() }
    let url = URL(string: boardList[indexPath.row].mainImageUrl!)
    let data = try? Data(contentsOf: url!)
    DispatchQueue.main.async {
      cell.petImg.image = UIImage(data: data!)
    }
    cell.petLocation.text = boardList[indexPath.row].missingLocation!
    let care = boardList[indexPath.row].care
    // 삼항연산자 써도 좋았을 것 같다
    if(care == true){
      cell.careOption.text = "보호 중"
    }
    else{
      cell.careOption.text = "발견"
    }
    return cell
  }
  
  // 콜렉션 뷰가 셀을 표시하기 직전에 호출됩니다.
  // 마지막 셀을 부를 때, 함수 호출
  // 로드하고 있는지 체크하지 않은 점이 아쉽다
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
  // 스크롤로 하단에 닿았을 때 -> 새로고침
  // 하단도 가능하다는 것을 몰랐음
  // func scrollViewWillEndDragging로 상단 방향만 가능하게
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
    return CGSize(width: (UIScreen.main.bounds.width)/2 - 20, height: 320)
  }
}

extension DetectBoardViewController: UICollectionViewDelegate {
  // 콜렉션 뷰에서 셀이 선택되었을 때 호출
  // 발견 상세 글 보기
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectDetailViewController") as? DetectDetailViewController else { return }
    let findId = self.boardList[indexPath.row].id
    let posterPhoneN = self.boardList[indexPath.row].userPhoneNumber
    // 지금이라면 데이터를 하나씩 지정하기보단, FindBoard를 바로 활용할 듯
    viewController.findId = findId!
    viewController.posterPhoneN = posterPhoneN
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}
