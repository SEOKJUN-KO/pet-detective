//
//  AlarmBoardViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/27.
//

import UIKit
// 알람 모음
class AlarmBoardViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var alarms = [Alarm]() {
    didSet {
      self.saveTasks()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 알람 테이블 셀 등록
    let nibName = UINib(nibName: "AlarmCell", bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: "AlarmCell")
    self.tableView.dataSource = self // 하단 참조
    self.tableView.delegate = self // 하단 참조
    self.tableView.refreshControl = UIRefreshControl()
    self.tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    
    // userDefaults의 데이터 불러오기
    self.loadTasks()
    
    refreshData()
  }
  
  @objc private func refreshData(){
    loadTasks()
    tableView.reloadData()
  }
  
  func saveTasks() {
    let data = self.alarms.map {
      [
        "alarmMode": $0.alarmMode,
        "boardType": $0.boardType,
        "boardId": $0.boardId
      ]
    }
    let userDefaults = UserDefaults.standard
    userDefaults.set(data, forKey: "petAlarm")
  }
  
  func loadTasks() {
    // userdefault 512KB
    // 한글 문자 배열을 저장 -> CoreData를 썼으면 좋았을 것 같다
    let userDefaults = UserDefaults.standard
    guard let data = userDefaults.object(forKey: "petAlarm") as? [[String: Any]] else { return }
    self.alarms = data.compactMap {
      guard let alarmMode =  $0["alarmMode"] as? String else { return nil }
      guard let boardType = $0["boardType"] as? String else { return nil }
      guard let boardId = $0["boardId"] as? Int else { return nil }
      return Alarm(alarmMode: alarmMode, boardType: boardType, boardId: boardId)
    }
    self.tableView.refreshControl?.endRefreshing()
  }
}

extension AlarmBoardViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 행의 갯수 지정, 필수 기능 함수
    return self.alarms.count
  }
  // 셀 그리는 함수
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // 필수 기능 함수
    // 셀 재사용
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as? AlarmCell else { return UITableViewCell() }
    let alarm = self.alarms[indexPath.row]
    cell.alarmTitle.text = alarm.alarmMode
    if( alarm.alarmMode == "게시글 작성"){
      if( alarm.boardType == "의뢰"){
        cell.alarmBody.text = "새로운 의뢰가 들어왔어요!"
      }
      else if ( alarm.boardType == "보호" ){
        cell.alarmBody.text = "반려견과 비슷한 친구가 보호 중이에요!"
      }
      else if ( alarm.boardType == "발견" ){
        cell.alarmBody.text = "반려견과 비슷한 친구가 제보가 되었어요!"
      }
    }
    else if(alarm.alarmMode == "골든타임"){
      if( alarm.boardType == "의뢰"){
        cell.alarmBody.text = "\(alarm.boardType) 제한시간 내에 강아지를 찾아주세요!"
      }
      else if ( alarm.boardType == "보호" ){
        cell.alarmBody.text = "\(alarm.boardType) 최근 비슷한 강아지가 보호되고 있어요!"
      }
      else if ( alarm.boardType == "발견" ){
        cell.alarmBody.text = "\(alarm.boardType) 최근 비슷한 친구가 제보가 되었어요!"
      }
    }
    
    return cell
  }
  // 셀 옮기기
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  // 편집모드에서 - 아이콘을 클릭했을 시 또는 스와이프 레프트 시, 해당 정보 삭제
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    self.alarms.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic) // tableView에 적용
  }
}

extension AlarmBoardViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //셀이 선택 되었을 때, 해당 모드에 맞는 페이지로 이동
    let alarm = self.alarms[indexPath.row]
    if( alarm.alarmMode == "게시글 작성"){
      // 의뢰 게시글
      if( alarm.boardType == "의뢰"){
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportDetailViewController") as? ReportDetailViewController else { return }
        viewController.reportId = alarm.boardId
        viewController.posterPhoneN = "0000000000"
        self.navigationController?.pushViewController(viewController, animated: true)
      }
      else{
        // "발견 / 보호 게시글"
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetectDetailViewController") as? DetectDetailViewController else { return }
        viewController.findId = alarm.boardId
        viewController.posterPhoneN = "0000000000"
        self.navigationController?.pushViewController(viewController, animated: true)
      }
    }
    else if(alarm.alarmMode == "골든타임"){
      // 골든타임 탭으로 이동
      NotificationCenter.default.post(name: NSNotification.Name("NotiGoldenTimeAlrm"), object: alarm)
      self.tabBarController?.selectedIndex = 1
    }
  }
}
