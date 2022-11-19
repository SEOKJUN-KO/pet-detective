//
//  NaverMapView.swift
//  PetDetective
//
//  Created by Junseo Park on 2022/04/08.
//

import UIKit
import NMapsMap

class MapView: UIView {
    
//    let xibName = "MapView"
    
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    var mapView: NMFMapView {
        return naverMapView.mapView
    }
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var setLocationButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadXib()
        setLocationButton.layer.cornerRadius = 6
        setLocationButton.tintColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadXib()
    }
    
//    private func loadXib() {
//        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
//        view.frame = self.bounds
//        self.addSubview(view)
//    }
    
    
    private func loadXib() {
        let identifier = String(describing: type(of: self))
        let nibs = Bundle.main.loadNibNamed(identifier, owner: self, options: nil)

        guard let customView = nibs?.first as? UIView else { return }
        customView.frame = self.bounds
        self.addSubview(customView)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
