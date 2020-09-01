//
//  ZLGCalendarViewFlowLayout.swift
//  zhulogicgc
//
//  Created by 徐亚东 on 2019/6/18.
//  Copyright © 2019 zhulogicgc. All rights reserved.
//

import UIKit

class ZLGCalendarViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        self.scrollDirection = .horizontal
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let temp = super.layoutAttributesForElements(in: rect)
        for value in temp ?? [UICollectionViewLayoutAttributes](){
            value.frame = CGRect.init(x:value.frame.origin.x, y: 0, width: value.bounds.size.width, height: rect.height)
        }
        return temp
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let temp = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        return temp
    }
}
