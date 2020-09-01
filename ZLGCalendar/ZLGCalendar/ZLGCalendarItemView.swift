//
//  ZLGCalendarItemView.swift
//  zhulogicgc
//
//  Created by 徐亚东 on 2019/6/17.
//  Copyright © 2019 zhulogicgc. All rights reserved.
//

import UIKit

private let UIColor_313131    =    UIColor.init(red: 49/255.0, green: 49/255.0, blue: 49/255.0, alpha: 1)
private let UIColor_A0A0A0    =    UIColor.init(red: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
private let UIColor_F1F1F1 = UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
/// item的样式
///
/// - mNormal: 正常状态
/// - mHaveOutPut: 有产出的状态
/// - mSelected: 选中的状态
/// - mCanNotSelected: 不可选状态
/// - mCanNotSelectedHaveOutput: 不可选状态但是有产出
 enum ZLGCalendarItemViewStatus{
    case mNormal
    case mHaveOutPut
    case mSelected
    case mCanNotSelected
    case mCanNotSelectedHaveOutput
}
class ZLGCalendarItemView: UIView {
    var mDate : Date?
    var mClickBack = {(_ item:ZLGCalendarItemView)->Void in}
    private let labSize = CGSize.init(width: 40, height: 40)
    private let pointSize = CGSize.init(width: 4, height: 4)
    
    var mStatus = ZLGCalendarItemViewStatus.mNormal {
        didSet{
            self.isUserInteractionEnabled = true
            switch self.mStatus {
            case .mNormal:
                self.vLab.backgroundColor = .white
                self.vPoint.backgroundColor = .white
                self.vLab.textColor = UIColor_313131
                self.vLab.font = .systemFont(ofSize: 14)
            case .mHaveOutPut:
                self.vLab.backgroundColor = .white
                self.vPoint.backgroundColor = .red
                self.vLab.textColor = UIColor_313131
                self.vLab.font = .systemFont(ofSize: 14)
            case .mSelected:
                self.vLab.backgroundColor = .red
                self.vPoint.backgroundColor = .red
                self.vLab.textColor = .white
                self.vLab.font = .systemFont(ofSize: 14)
            case .mCanNotSelected:
                self.vLab.backgroundColor = .white
                self.vPoint.backgroundColor = .white
                self.vLab.textColor = UIColor_A0A0A0
                self.isUserInteractionEnabled = false
                self.vLab.font = .systemFont(ofSize: 14)
            case .mCanNotSelectedHaveOutput:
                self.vLab.backgroundColor = .white
                self.vPoint.backgroundColor = .red
                self.vLab.textColor = UIColor_A0A0A0
                self.isUserInteractionEnabled = false
                self.vLab.font = .systemFont(ofSize: 14)
            }
        }
    }
   lazy var vLab : UILabel = {
        let temp = UILabel()
        temp.textColor = UIColor_F1F1F1
        temp.font = .systemFont(ofSize: 14)
        temp.textAlignment = .center
        temp.layer.cornerRadius = self.labSize.width/2
        temp.layer.masksToBounds = true
        return  temp
    }()
    lazy var vPoint : UIImageView = {
        let temp = UIImageView()
        temp.layer.cornerRadius = self.pointSize.width/2
        temp.layer.masksToBounds = true
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(self.vLab)
        self.addSubview(self.vPoint)
        self.addTarget(self, #selector(clickAction(_:)))
        
        self.vLab.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(self.labSize)
        }
        self.vPoint.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.size.equalTo(self.pointSize)
            make.centerX.equalToSuperview()
        }
        
    }
    
    @objc func clickAction(_ tap:UITapGestureRecognizer){
        let temp = tap.view as? ZLGCalendarItemView
        if temp != nil{
            self.mClickBack(temp!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
