//
//  ViewController.swift
//  ZLGCalendar
//
//  Created by 徐亚东 on 2020/9/1.
//  Copyright © 2020 xuyadong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate lazy var vCalendarView:ZLGCalendarView = {
        let temp = ZLGCalendarView()
        temp.backgroundColor = .white
        temp.frame = CGRect.init(x: 0, y:100, width: 414, height: 400)
        temp.startDate = ZLGDateTool().getLastYearFromDate(ZLGDateTool().getCurrentDate())
        temp.endDate = ZLGDateTool().getCurrentDate()
        temp.selectedDate = ZLGDateTool().getCurrentDate()
        temp.layer.shadowColor = UIColor.black.cgColor
        temp.layer.shadowOpacity = 0.05
        temp.layer.shadowOffset = .init(width: 0, height: 1)
        weak var weakSelf = self
        
        temp.updateSize = {(size)->Void in
            
        }
        weak var weakTemp = temp
        temp.updateMonth = {()->Void in

        }
        temp.updateDay = {(date)->Void in
            
        }
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.vCalendarView.width)
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(self.vCalendarView)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.vCalendarView.width = UIScreen.main.bounds.size.width
        print(self.vCalendarView.width)
    }
}

