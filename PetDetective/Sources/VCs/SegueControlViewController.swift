//
//  SegueControlViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/17.
//

import UIKit

enum boardMode{
    case report
    case find
}

class SegueControlViewController: UIViewController {

    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var protectView: UIView!
    var mode: boardMode = .report
    var scope = "loc"
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색어를 입력하세요"
        searchController.searchBar.scopeButtonTitles = [ "위치", "품종", "색" ]
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        protectView.alpha = 0
        // Do any additional setup after loading the view.
    }

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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let objectdic:[String: String] = [ "search": searchBar.text!, "scope": scope ]
        if(mode == .report){
            NotificationCenter.default.post(name: NSNotification.Name("searchReport"), object: objectdic)
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name("searchFind"), object: objectdic)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if(mode == .report){
            NotificationCenter.default.post(name: NSNotification.Name("searchReportCancle"), object: nil)
        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name("searchFindCancle"), object: nil)
        }
    }
}
