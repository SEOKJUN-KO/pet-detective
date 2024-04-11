//
//  ReportBoardViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/03/23.
//

import UIKit

class ReportBoardViewController: UIViewController {
  
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
  // 신고하기
  @IBOutlet weak var reportWriteBtn: UIButton!
  
  private var refreshControl = UIRefreshControl()
  private var boardList = [ReportBoard]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // 사용할 셀 등록
    let nibName = UINib(nibName: "ReportCell", bundle: nil)
    collectionView.register(nibName, forCellWithReuseIdentifier: "ReportCell")
    // collectionView 설정 적용
    configureCollectionView()
    
    // 데이터 불러오기
    fetchData(page: 1)
    self.collectionView.refreshControl = refreshControl
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    // 알림 생성 확인
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(goToDetailNotification(_:)),
      name: NSNotification.Name("newReport"),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(searchPostNotification(_:)),
      name: NSNotification.Name("searchReport"),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(searchCancleNotification(_:)),
      name: NSNotification.Name("searchReportCancle"),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(goldenTimeReportNotification(_:)),
      name: NSNotification.Name("newReportGolden"),
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(goldenTimeDetectNotification(_:)),
      name: NSNotification.Name("newDetectGolden"),
      object: nil
    )
  }
  
  // 코드를 너무 세분화 한 것 같은데, 지금 보면 재사용 할 듯 싶음
  @objc func goldenTimeReportNotification(_ notification: Notification) {
    
    // 외부에서 푸시노티 [골든타임-신고] 탭 했을 때
    guard let alarm = notification.object as? Alarm else { return } // 게시판 아이디: alarm.boardId
    
    // 루트뷰까지 팝
    self.navigationController?.popToRootViewController(animated: true)
    
    // 알림 동작과 뷰 동작을 엮기 위해 사용했음
    NotificationCenter.default.post(name: NSNotification.Name("NotiGoldenTimeAlarm"), object: alarm)
    
    // 골든타임 탭으로 이동
    self.tabBarController?.selectedIndex = 1
  }
  
  @objc func goldenTimeDetectNotification(_ notification: Notification) {
    
    // 외부에서 푸시노티 [골든타임-발견] 탭 했을 때
    guard let alarm = notification.object as? Alarm else { return } // 게시판 아이디: \(alarm.boardId)
    
    // "루트뷰까지 팝"
    self.navigationController?.popToRootViewController(animated: true)
    NotificationCenter.default.post(name: NSNotification.Name("NotiGoldenTimeAlarm"), object: alarm)
    // 골든타임 탭으로 이동
    self.tabBarController?.selectedIndex = 1
  }
  
  @objc func goToDetailNotification(_ notification: Notification){
    // [ 실종이 된 반려견과 가까운 거리에 있는 사람들에게 알림이 감 -> 클릭 ]
    guard let boardId = notification.object else { return }
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportDetailViewController") as? ReportDetailViewController else { return }
    guard let reportId = boardId as? String else { return }
    // 실종 게시글로 이동
    viewController.reportId = Int(reportId)
    // viewWillApear에서 비교문에서 posterPhoneN가 바로 사용되기 때문에 값을 미리 준 것 같음
    // 지금이라면 if let으로 처리할 듯
    viewController.posterPhoneN = "00000000000"
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
    // 검색 api
    fetchSearchedData(category: self.category, condition: self.condition, page: self.searchCurrentPage)
  }
  
  @objc func searchCancleNotification(_ notification: Notification){
    // [ 검색 취소 ]
    self.searchFlag = 0
    self.currentPage = 1
    self.boardList.removeAll()
    self.collectionView.reloadData()
    fetchData(page: self.currentPage)
  }
  // 카테고리 + 검색어로 데이터 받기
  private func fetchSearchedData(category: String, condition: String, page: Int){
    let urlString = "https://iospring.herokuapp.com/detect/search?category=\(category)&condition=\(condition)&page=\(page)"
    let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    guard let url = URL(string: encodedString) else {
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    // URLSession가 multipartFormData 지원하는 것을 몰랐음 -> multipartFormData 사용 시 AF 사용
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if(error != nil){
          print(error.debugDescription)
          return
        }
        else if( data != nil ){
          do{
            let decodedData = try JSONDecoder().decode(APIDetectBoardResponse<[ReportBoard]>.self, from: data!)
            self.searchTotalPage = decodedData.totalPage ?? 1
            self.boardList.append(contentsOf: decodedData.detectBoardDTOList!)
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
    //FlowLayout을 적용
    self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    self.collectionView.delegate = self  // 하단 extension 참조
    self.collectionView.dataSource = self // 하단 extension 참조
    self.reportWriteBtn.layer.cornerRadius = 6
  }
  
  // 기본 데이터 불러오기
  private func fetchData(page: Int){
    guard let url = URL(string: "https://iospring.herokuapp.com/detect?page=\(page)") else {
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    // [weak self] 쓸 듯, 데이터 처리는 global에서 동작시키고,
    // 뷰를 그릴 때 main으로 할 듯
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if(error != nil){
          print(error.debugDescription)
          return
        }
        else if( data != nil ){
          do{
            let decodedData = try JSONDecoder().decode(APIDetectBoardResponse<[ReportBoard]>.self, from: data!)
            self.totalPage = decodedData.totalPage ?? 1
            self.boardList.append(contentsOf: decodedData.detectBoardDTOList!)
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
extension ReportBoardViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.boardList.count
  }
  // 데이터에 해당하는 셀 어떻게 그릴 것인지
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // 셀을 재사용
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportCell", for: indexPath) as? ReportCell else { return UICollectionViewCell() }
    let url = URL(string: boardList[indexPath.row].mainImageUrl!)
    let data = try? Data(contentsOf: url!)
    // main sync로 한다면, 앱이 작업 처리를 끝낼 때까지 멈출 수 있음
    DispatchQueue.main.async {
      cell.petImg.image = UIImage(data: data!)
    }
    cell.petLocation.text = boardList[indexPath.row].missingLocation!
    cell.money.text = String(boardList[indexPath.row].money!) ?? "0"
    return cell
  }
  // 콜렉션 뷰가 셀을 표시하기 직전에 호출
  // 마지막 셀을 부를 때, 함수 호출
  // 로드하고 있는지 체크하지 않은 점이 아쉬움
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
  // func scrollViewWillEndDragging로 상단 방향만 가능하게 바꾸는게 좋을 것 같음
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

extension ReportBoardViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (UIScreen.main.bounds.width)/2 - 20, height: 320)
  }
}

extension ReportBoardViewController: UICollectionViewDelegate {
  // 콜렉션 뷰에서 셀이 선택되었을 때 호출
  // 신고 상세 글 보기
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportDetailViewController") as? ReportDetailViewController else { return }
    let reportId = self.boardList[indexPath.row].id
    let posterPhoneN = self.boardList[indexPath.row].userPhoneNumber
    // 지금이라면 데이터를 하나씩 지정하기보단, ReportBoard를 바로 활용할 듯
    viewController.reportId = reportId
    viewController.posterPhoneN = posterPhoneN
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}
