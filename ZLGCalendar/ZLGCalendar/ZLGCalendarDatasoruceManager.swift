//
//  ZLGCalendarDatasoruceManager.swift
//  zhulogicPro
//
//  Created by 徐亚东 on 2019/10/18.
//  Copyright © 2019 zhulogicPro. All rights reserved.
//

import UIKit

/// 用来处理日历数据的类
class ZLGCalendarDatasoruceManager: NSObject {
    
    /// 格式(1970/1/1)
    var startDate:Date? {
        didSet{
            self.createDataSource()
        }
    }
    
    /// 格式(1970/1/1)
    var endDate:Date?{
        didSet{
            self.createDataSource()
        }
    }
    
    var mMangers = [ZLGCalendarDatasoruceMonthManage]()
    /// 处理日期的工具类
    fileprivate let dateTool = ZLGDateTool()
    
    override init() {
        super.init()
    }
    
    fileprivate func createDataSource(){
        //如果有起始日期和结束日期创建数据源
        if self.startDate != nil && self.endDate != nil{
            var tempDate = startDate!
            var tempManagers = [ZLGCalendarDatasoruceMonthManage]()
            while !self.dateTool.compareDateIsTheSameAccurateToMonth(tempDate, self.endDate!) {
                let tempManager = ZLGCalendarDatasoruceMonthManage()
                tempManager.mMonthDate = tempDate
                tempManagers.append(tempManager)
                tempDate = self.dateTool.getNextMonthFromDate(tempDate)
            }
            let tempManager = ZLGCalendarDatasoruceMonthManage()
            tempManager.mMonthDate = tempDate
            tempManagers.append(tempManager)
            self.mMangers = tempManagers
        }
    }
    
    /// 根据一个日期返回该日期在月数据源中的下标
    /// - Parameter date: Date
    func getIndexOfDatasourceOfMonths(date:Date)->Int{
        var index = 0
        for (tempIndex,manage) in self.mMangers.enumerated() where self.dateTool.compareDateIsTheSameAccurateToMonth(manage.mMonthDate!, date){
            index = tempIndex
        }
        return index
    }
    
    /// 根据一个日期返回该日期在周数据源中的下标
    /// - Parameter date: Date
    func getIndexOfDatasourceOfWeeks(date:Date)->Int{
        let monthIndex = self.getIndexOfDatasourceOfMonths(date: date)
        var newIndex = 0
        for (index,manage) in self.mMangers.enumerated(){
            if index < monthIndex{
                newIndex += manage.mDataSourceOfWeeks.count
            }
        }
        let monthManger = self.mMangers[monthIndex]
        for (index,value) in monthManger.mDataSourceOfWeeks.enumerated() where self.dateTool.compareDateIsTheSameAccurateToMonth(monthManger.mMonthDate!, date) && value.contains(where: { (tempDate) -> Bool in
            return self.dateTool.compareDateIsTheSameAccurateToDay(tempDate, date)
        }){
            newIndex += index
            break
        }
        return newIndex
    }
}

//处理月份的类
class ZLGCalendarDatasoruceMonthManage: NSObject{
    
    var mDataSourceOfMonth = [Date]()//一个月的月历数据源
    var mDataSourceOfWeeks =  [[Date]]()//一个月的周历数据源
    
    //周的排列顺序 以星期天开始
    var mWeekSort : [ZLGWeek] = [.Sunday,.Monday,.Tuesday,.Wednesday,.Thursday,.Friday,.Saturday]
    
    /// 处理日期的工具类
    fileprivate let dateTool = ZLGDateTool()

    fileprivate var mMonthDays = 0 //一个月的具体天数
    fileprivate var mStrOfFirstDay = "" //月份的第一天日期字符串 ：year/month/day
    fileprivate var mStrOfLastDay = "" //月份的最后一天日期字符串 ：year/month/day
    fileprivate var mWeekInfoOfFirstDay = ZLGWeek.Monday//月份的第一天是星期几
    fileprivate var mWeekInfoOfLastDay = ZLGWeek.Monday//月份的最后一天是星期几
    
    //获取当前日期上个月的实际天（显示月份日历时要将第一行不足一行的用上个月的日期补齐）
    fileprivate var mLastMonthDays = 0
    
    fileprivate var mLastMonth = Date()//上个月的日期
    fileprivate var mNextMonth = Date()//下个月的日期
    
    //通过设置一个月份创建月日历相关数据
    var mMonthDate:Date?{
        didSet{
            guard self.mMonthDate != nil else {
                return
            }
            //一些必要的数据准备
            self.prepare()
            //创建月历列表数据源
            self.createDataSourceOfMonth()
            //创建周历列表数据源
            self.createDataSourceOfWeeks()
        }
    }
    
    fileprivate func prepare(){
        guard let tempDate = self.mMonthDate else {
            return
        }
        //清空之前的月历数据源
        self.mDataSourceOfMonth.removeAll()
        //清空之前的周历数据源
        self.mDataSourceOfWeeks.removeAll()
        
        //获取当前月份的实际天数
        self.mMonthDays = self.dateTool.getNumberOfDaysInMonth(tempDate)
        //获取上个月的同一天日期
        self.mLastMonth = self.dateTool.getLastMonthFromDate(tempDate)
        //获取下个月的同一天日期
        self.mNextMonth = self.dateTool.getNextMonthFromDate(tempDate)
        
        //获取当前月份上个月的实际天数
        self.mLastMonthDays = self.dateTool.getNumberOfDaysInMonth(self.mLastMonth)
        //获取当前月份的第一天
        self.mStrOfFirstDay = "\(String(self.dateTool.getDateInfo(tempDate).year!))" + "/" + "\(String(self.dateTool.getDateInfo(tempDate).month!))" + "/" + "1"
        //获取当前月份的最后一天
        self.mStrOfLastDay = "\(String(self.dateTool.getDateInfo(tempDate).year!))" + "/" + "\(String(self.dateTool.getDateInfo(tempDate).month!))" + "/" + "\(self.mMonthDays)"
        //获取当前月份的第一天是星期几
        self.mWeekInfoOfFirstDay = self.dateTool.getDateInfoOfWeekday(self.dateTool.strToDate(mStrOfFirstDay, .YYMMDD)!)
        //获取当前月份的最后一天是星期几
        self.mWeekInfoOfLastDay = self.dateTool.getDateInfoOfWeekday(self.dateTool.strToDate(mStrOfLastDay, .YYMMDD)!)
    }
    
    /// 创建月历的日期数据源
    fileprivate func createDataSourceOfMonth(){
        let maxRow = 7 //一行显示7个
//        var maxColumn = 5 //列表的行数(默认5行，不同月份的列表排列行数不一样，每个月是28-31天 故一行显示七个最少4行，最多6行)

        var listDays = [Date]()
        
        let anchorFirst = self.mWeekSort.firstIndex(of: self.mWeekInfoOfFirstDay)//获取当前月份第一天在星期排列中的下标
        let anchorLast = self.mWeekSort.firstIndex(of: self.mWeekInfoOfLastDay)//获取当前月份最后一天在星期排列中的下标
        let firstList =  Array(1...self.mLastMonthDays).suffix(anchorFirst ?? 0)
        let lastList = Array(1...7).prefix(maxRow - 1 - (anchorLast ?? 0))
        
        let lastComponts = self.dateTool.getDateInfo(self.mLastMonth)
        let currentCOmponts = self.dateTool.getDateInfo(self.mMonthDate!)
        let NextComponts = self.dateTool.getDateInfo(self.mNextMonth)
        listDays.append(contentsOf: firstList.map({ (day) -> Date in
            return self.dateTool.strToDate("\(lastComponts.year!)/\(lastComponts.month!)/\(day)", .YYMMDD)!
        }))
        listDays.append(contentsOf: Array(1...self.mMonthDays).map({ (day) -> Date in
            return self.dateTool.strToDate("\(currentCOmponts.year!)/\(currentCOmponts.month!)/\(day)", .YYMMDD)!
        }))
        listDays.append(contentsOf: lastList.map({ (day) -> Date in
            return self.dateTool.strToDate("\(NextComponts.year!)/\(NextComponts.month!)/\(day)", .YYMMDD)!
        }))
        self.mDataSourceOfMonth = listDays
    }
    
    /// 创建一个月的所有周历的日期数据源
    fileprivate func createDataSourceOfWeeks(){
//        let weeks = stride(from: 0, to: self.mDataSourceOfMonth.count, by: 7)

        
        self.mDataSourceOfWeeks.removeAll()
        for _ in 0..<(self.mDataSourceOfMonth.count/7 + (self.mDataSourceOfMonth.count%7 == 0 ? 0:1)){
            self.mDataSourceOfWeeks.append([Date]())
        }
        var weekIndex = 0
        for (index,date) in self.mDataSourceOfMonth.enumerated(){
            if index/7 == weekIndex{
                self.mDataSourceOfWeeks[weekIndex].append(date)
            }else{
                weekIndex += 1
                self.mDataSourceOfWeeks[weekIndex].append(date)
            }
        }
//        var tempNullIndex = 0
//        for (index,value) in self.mDataSourceOfWeeks.enumerated() where value.count == 0{
//            tempNullIndex = index
//            break
//        }
//        self.mDataSourceOfWeeks.remo
//        print(self.mDataSourceOfWeeks)
    }
}
