//
//  ZLGcalendarCollectionCell.swift
//  zhulogicgc
//
//  Created by 徐亚东 on 2019/6/15.
//  Copyright © 2019 zhulogicgc. All rights reserved.
//

import UIKit
import SnapKit
class ZLGcalendarCollectionCell: UICollectionViewCell {
    lazy var vCalendarItemViews: ZLGCalendarItemsView = {
        let temp = ZLGCalendarItemsView()
        return temp
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(self.vCalendarItemViews)
        self.vCalendarItemViews.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }

}
