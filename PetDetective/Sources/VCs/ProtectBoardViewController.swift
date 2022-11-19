//  ProtectBoardViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/17.
//

import UIKit

class ProtectBoardViewController: UIViewController {
//
//    @IBOutlet weak var collectionView: UICollectionView!
//    var totalPage = 3
//    var currentPage = 1
//    @IBOutlet weak var reportWriteBtn: UIButton!
//    private var refreshControl = UIRefreshControl()
//
//    private var boardList = [ReportBoard]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureCollectionView()
//        fetchData(page: 1)
//        self.collectionView.refreshControl = refreshControl
//        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(goToDetailNotification(_:)),
//            name: NSNotification.Name("newReport"),
//            object: nil
//        )
//    }
//
//    @objc func goToDetailNotification(_ notification: Notification){
//        print("받기 완료")
//        guard let id = notification.object else { return }
//        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportDetailViewController") as? ReportDetailViewController else { return }
//        guard let reportId = id as? String else { return }
//        print("변환 완료")
//        print(reportId)
//        viewController.reportId = Int(reportId)
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }
//
//    private func configureCollectionView() {
//        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
//        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        self.collectionView.delegate = self  // 하단 extension 참조
//        self.collectionView.dataSource = self // 하단 extension 참조
//        self.reportWriteBtn.layer.borderWidth = 1
//        self.reportWriteBtn.frame.size = CGSize(width: 300, height: 50)
//        self.reportWriteBtn.frame.origin = CGPoint(x: self.view.frame.width/2 - self.reportWriteBtn.frame.width/2, y: self.view.frame.height - 225)
//        self.reportWriteBtn.layer.cornerRadius = 8
//    }
//
//    private func fetchData(page: Int){
//        guard let url = URL(string: "https://iospring.herokuapp.com/detect?page=\(page)") else {
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if(error != nil){
//                    print(error.debugDescription)
//                    return
//                }
//                else if( data != nil ){
//                    do{
//                        let decodedData = try JSONDecoder().decode(APIDetectBoardResponse<[ReportBoard]>.self, from: data!)
//                        self.totalPage = decodedData.totalPage ?? 1
//                        self.boardList.append(contentsOf: decodedData.detectBoardDTOList!)
////                        print("report Board count = \(self.boardList.count)")
////                        for b in self.boardList{
////                            print(b.id)
////                        }
//                        self.collectionView.reloadData()
//                    }
//                    catch{
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
//        task.resume()
//    }
//    @objc func refresh(){
//        self.boardList.removeAll()
//        self.collectionView.reloadData() // Reload하여 뷰를 비워줍니다.
//    }
//}
//extension ReportBoardViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.boardList.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportBoardCell", for: indexPath) as? ReportBoardCell else { return UICollectionViewCell() }
//        let url = URL(string: boardList[indexPath.row].mainImageUrl!)
////        let data = try? Data(contentsOf: url!)
//        DispatchQueue.main.async {
////            cell.petImg.image = UIImage(data: data!)
//        }
//        cell.petInfo.text = boardList[indexPath.row].missingLocation!
////        cell.date.text = self.dateToString(date: report.date) // date->String
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if currentPage < totalPage && indexPath.row == self.boardList.count - 1 {
//            currentPage += 1
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.fetchData(page: self.currentPage)
//            }
//        }
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if (refreshControl.isRefreshing) {
//            self.refreshControl.endRefreshing()
//            self.currentPage = 1
//            fetchData(page: self.currentPage)
//        }
//    }
//}
//
//extension ProtectBoardViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // 즐겨찾기 한 일기의 셀의 크기 지정
//        return CGSize(width: (UIScreen.main.bounds.width)/2 - 20, height: 200)
//    }
//}
//
//extension ProtectBoardViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportDetailViewController") as? ReportDetailViewController else { return }
//        let reportId = self.boardList[indexPath.row].id
//        viewController.reportId = reportId
//        print(reportId)
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }
}
