//
//  SegueControlViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/17.
//

import UIKit

enum boardMode{
  // 의뢰
  case report
  // 보호 발견
  case find
}

class SegueControlViewController: UIViewController {
  
  // 의뢰 게시판 뷰
  @IBOutlet weak var reportView: UIView!
  // 보호 게시판 뷰
  @IBOutlet weak var protectView: UIView!
  var mode: boardMode = .report
  // 검색 필터 범위 [ 위치, 품종, 털색 ]
  var scope = "loc"
  
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //검색 컨트롤러가 표시될 때 배경 뷰를 가릴지 여부를 결정함
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "검색어를 입력하세요"
    searchController.searchBar.scopeButtonTitles = [ "위치", "품종", "색" ]
    // 키보드 리턴 키 타입을 설정 - 검색 아이콘으로 변경
    searchController.searchBar.returnKeyType = .search
    searchController.searchBar.delegate = self
    self.navigationItem.searchController = searchController
    self.navigationItem.hidesSearchBarWhenScrolling = true
    // 뷰 컨트롤러가 다른 뷰 컨트롤러를 표시할 때 프레젠테이션 스타일을 지정 가능
    definesPresentationContext = true
    
    protectView.alpha = 0
  }
  // 세그먼트로 뷰 변화
  @IBAction func switchViews(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      reportView.alpha = 1.0
      protectView.alpha = 0
      mode = .report
    } else if sender.selectedSegmentIndex == 1 {
      reportView.alpha = 0
      protectView.alpha = 1.0
      mode = .find
    }
  }
}

extension SegueControlViewController: UISearchBarDelegate {
  // MARK: - UISearchBar Delegate
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    let searchBar = searchController.searchBar
    let scopeString = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    if(scopeString == "위치"){
      self.scope = "loc"
    }
    else if(scopeString == "품종"){
      self.scope = "breed"
    }
    else{
      self.scope = "color"
    }
    searchController.searchBar.text = ""
  }
  // 검색어 입력 후 완료 동작
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    let objectdic:[String: String] = [ "search": searchBar.text!, "scope": scope ]
    if(mode == .report){
      NotificationCenter.default.post(name: NSNotification.Name("searchReport"), object: objectdic)
    }
    else{
      NotificationCenter.default.post(name: NSNotification.Name("searchFind"), object: objectdic)
    }
  }
  
  // 검색 중 취소 버튼 클릭
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    if(mode == .report){
      NotificationCenter.default.post(name: NSNotification.Name("searchReportCancle"), object: nil)
    }
    else{
      NotificationCenter.default.post(name: NSNotification.Name("searchFindCancle"), object: nil)
    }
  }
}
