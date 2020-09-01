//
//  ZLGDateTool.swift
//  zhulogicgc
//
//  Created by 徐亚东 on 2019/6/15.
//  Copyright © 2019 zhulogicgc. All rights reserved.
//

import UIKit

/// 解析时间的格式
///
/// - YYMMDDHHMMSS: 年月日时分秒
/// - YYMMDD: 年月日
/// - HHMMSS: 时分秒
enum ZLGDateFormatStr :String{
    case YYMMDDHHMMSS = "yyyy-MM-dd-HH-mm-ss"
    case YYMMDD = "yyyy-MM-dd"
    case HHMMSS = "HH-mm-ss"
}

enum ZLGWeek:String{
    case Monday = "Mon"
    case Tuesday = "Tues"
    case Wednesday = "Wed"
    case Thursday = "Thur"
    case Friday = "Fri"
    case Saturday = "Sat"
    case Sunday = "Sun"
}

class ZLGDateTool: NSObject {
    
    /// 时区 默认已设置为北京时间 Asia/Shanghai
    var timeZone:TimeZone? = TimeZone.init(identifier: "Asia/Shanghai")
//    var timeZone:TimeZone{
//        guard let temp = TimeZone.init(identifier: "Asia/Shanghai") else { return TimeZone.current }
//        return temp
//    }
    lazy var formatter : DateFormatter = {
        let temp = DateFormatter.init()
        temp.timeZone = self.timeZone
        temp.setLocalizedDateFormatFromTemplate(ZLGDateFormatStr.YYMMDDHHMMSS.rawValue)
        return temp
    }()
    
    /// 获取当前的Date
    ///
    /// - Returns: date
    func getCurrentDate() -> Date {
        let temp = Date.init()
        return temp
    }

    /// 返回当前时间的年月日(eg: 2019/06/15)
    ///
    /// - Returns: 年月日
    func getCurrentYearMonthDay() -> String {
        let temp = self.DateToStr(self.getCurrentDate())
        let newTemp = temp.split(separator: " ")
        guard newTemp.count > 0 else{return ""}
        return String(newTemp.first!)
    }
    
    /// 返回当前时间的时分秒(24小时制)(eg: 18:14:12)
    ///
    /// - Returns: 时分秒
    func getCurrentHourMinuteSecond() -> String {
        let temp = self.DateToStr(self.getCurrentDate())
        let newTemp = temp.split(separator: " ")
        guard newTemp.count > 1 else{return ""}
        return String(newTemp.last!)
    }
    
    /// 将Date数据转换成年月日时分秒字符串
    ///
    /// - Parameter date: Date
    /// - Returns: 年月日时分秒
    func DateToStr(_ date:Date) -> String {//Asia/Shanghai yyyyMMddHHmmss
        let tempStr = formatter.string(from: date)
        return tempStr
    }
    
    /// 将字符串转为Date(默认使用YYMMDDHHMMSS格式)
    ///
    /// - Parameter dateStr: 字符串(eg: "2019-5-13 13:21:36")
    /// - Returns: Date
    func strToDate(_ dateStr:String) ->Date?{
        return self.strToDate(dateStr, .YYMMDDHHMMSS)
    }
    
    /// 将字符串将字符串转为Date(需要指定转换格式)
    ///
    /// - Parameters:
    ///   - dateStr: datestr
    ///   - formatStr: 格式
    /// - Returns: date
    func strToDate(_ dateStr:String,_ formatStr:ZLGDateFormatStr) -> Date? {
        self.formatter.setLocalizedDateFormatFromTemplate(formatStr.rawValue)
        guard let date = self.formatter.date(from: dateStr) else {
            return Date()
        }
        return date
    }
    
    /// 根据date获取当月的天数
    ///
    /// - Parameter date: date
    /// - Returns: 有多少天
    func getNumberOfDaysInMonth(_ date:Date) -> Int {
        let calendar = Calendar.init(identifier: .gregorian)
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }
    
    /// 获取日期的相关信息
    ///
    /// - Parameter date: date
    /// - Returns: DateComponents
    func getDateInfo(_ date:Date) -> DateComponents {
        let calendar = Calendar.init(identifier: .gregorian)
        let components = calendar.dateComponents(in: self.timeZone!, from: date)
        return components
    }
    
    func getDateOfYearAndMonth(_ date:Date) -> String {
        return self.getDateOfYearAndMonthWithConnectSymbols(date,nil)
    }
    
    func getDateOfYearAndMonthWithConnectSymbols(_ date:Date,_ connectSymbols:[String]?) -> String {
        let temp = self.getDateInfo(date)
        guard let symbols = connectSymbols else{
            return "\(String(temp.year!))年\(String(temp.month!))月"
        }
        var tempStr = ""
        if symbols.count == 1{
           tempStr = "\(String(temp.year!))\(symbols.first!)\(String(temp.month!))"
        }else if symbols.count == 2{
           tempStr = "\(String(temp.year!))\(symbols.first!)\(String(temp.month!))\(symbols.last!)"
        }
        return tempStr
    }
    
    /// Date转年月日
    ///
    /// - Parameter date: date
    func DateToStrOfYearMonthAndDay(date:Date)->String{
        let temp = self.getDateToStr(date) { (year, month, day) -> String in
            return year + "/" + month + "/" + day
        }
        return temp
    }
    func getDateToStr(_ date:Date,_ dateInfon:((_ year:String,_ month:String,_ day:String) -> String)) ->String{
        let info = self.getDateInfo(date)
        let tempStr = dateInfon(String(info.year!),String(info.month!),String(info.day!))
        return tempStr
    }
    
    /// 根据具体的日期获取当天星期几
    ///
    /// - Parameter date: date
    /// - Returns: ZLGWeek
    func getDateInfoOfWeekday(_ date:Date) -> ZLGWeek {
        let components = self.getDateInfo(date)
        var weekDay = ZLGWeek.Monday
        switch components.weekday {
        case 1:
            weekDay = ZLGWeek.Sunday
        case 2:
            weekDay = ZLGWeek.Monday
        case 3:
            weekDay = ZLGWeek.Tuesday
        case 4:
            weekDay = ZLGWeek.Wednesday
        case 5:
            weekDay = ZLGWeek.Thursday
        case 6:
            weekDay = ZLGWeek.Friday
        case 7:
            weekDay = ZLGWeek.Saturday
        default:
            break
        }
        return weekDay
    }
    
   /// 获取一个日期相邻的日期
   ///
   /// - Parameters:
   ///   - date: date
    ///   - format: eg:year,month,day
   ///   - close: last or next date
   /// - Returns: newdate
   private func getCloseDate(_ date:Date,yearOrMonthOrDay format:String,lastOrNext close:String) -> Date {
        let componts = self.getDateInfo(date)
        var year = componts.year!
        var month = componts.month!
        var day = componts.day!
        var last = true
        switch close {
        case "last":
            last = true
        case "next":
            last = false
        default:
            fatalError("请输入正确的字符串")
        }
    
        switch format {
        case "year":
            year -= last ? 1:-1
        case "month":
            month -= last ? 1:-1
            if month == 0{
                month = 12
                year -= 1
            }else if month == 13{
                month = 1
                year += 1
            }
        case "day":
            day -= last ? 1:-1
            return date.addingTimeInterval(last ? 1:-1 * 60 * 60 * 24)
        default:
            fatalError("请传入正确的字符串")
        }

        let newDateStr = "\(year)" + "/" + "\(month)" + "/" + "\(1)"
        let days = self.getNumberOfDaysInMonth(self.strToDate(newDateStr, .YYMMDD)!)
        if day > days{
            day = days
        }
        return self.strToDate("\(year)" + "/" + "\(month)" + "/" + "\(day)", .YYMMDD)!
    }
    
    /// 根据一个日期获取该月指定某天的日期
    /// - Parameter date: Date
    func getAccurateDateOfDayByDate(date:Date,day:Int)->Date?{
        let dateCom = self.getDateInfo(date)
        let tempDate = self.strToDate("\(dateCom.year!)-\(dateCom.month!)-\(day)", .YYMMDD)
        return tempDate
    }
    
    /// 获取一个日期上一年
    ///
    /// - Parameter date: date
    /// - Returns: date
    func getLastYearFromDate(_ date:Date) -> Date {
        let newDate = self.getCloseDate(date, yearOrMonthOrDay: "year", lastOrNext: "last")
        return newDate
    }
    
    /// 获取一个日期下一年
    ///
    /// - Parameter date: date
    /// - Returns: date
    func getNextYearFromDate(_ date:Date) -> Date {
        let newDate = self.getCloseDate(date, yearOrMonthOrDay: "year", lastOrNext: "next")
        return newDate
    }
    
    /// 获取一个日期的上个月 如果没有31号则变为30号
    ///
    /// - Parameter date: date
    /// - Returns: date
    func getLastMonthFromDate(_ date:Date) -> Date{
       let newDate = self.getCloseDate(date, yearOrMonthOrDay: "month", lastOrNext: "last")
        return newDate
    }
    
    /// 获取一个日期的下个月
    ///
    /// - Parameter date: date
    /// - Returns: date
    func getNextMonthFromDate(_ date:Date) -> Date{
       let newDate =  self.getCloseDate(date, yearOrMonthOrDay: "month", lastOrNext: "next")
        return newDate
    }
    
    /// 获取一个日期的上一天
    ///
    /// - Parameter date: date
    /// - Returns: date
    func getLastDayFromDate(_ date:Date) -> Date {
        let newDate = self.getCloseDate(date, yearOrMonthOrDay: "day", lastOrNext: "last")
        return newDate
    }
    
    /// 获取一个日期的下一天
    ///
    /// - Parameter date: date
    /// - Returns: date
    func getNextDayFromDate(_ date:Date) -> Date {
        let newDate = self.getCloseDate(date, yearOrMonthOrDay: "day", lastOrNext: "next")
        return newDate
    }
    
    /// 比较两个日期是否一样
    ///
    /// - Parameters:
    ///   - dateOne: date
    ///   - dateTwo: date
    ///   - condition: year or month or day
    /// - Returns: Bool
    func compareDate(_ dateOne:Date,_ dateTwo:Date,_ condition:String) -> Bool {
        var temp = false
        let infoOne = self.getDateInfo(dateOne)
        let infoTwo = self.getDateInfo(dateTwo)
        switch condition {
        case "year":
            temp = (infoOne.year == infoTwo.year)
        case "month":
            temp = (infoOne.year == infoTwo.year && infoOne.month == infoTwo.month)
        case "day":
            temp = (infoOne.year == infoTwo.year && infoOne.month == infoTwo.month && infoOne.day == infoTwo.day)
        default:
            fatalError("输入正确的字符")
        }
        return temp
    }
    
    /// 比较两个日期是否一样(精确到年)
    ///
    /// - Parameters:
    ///   - dateOne: date
    ///   - dateTwo: date
    /// - Returns: Bool
    func compareDateIsTheSameAccurateToYear(_ dateOne:Date,_ dateTwo:Date)->Bool{
        return self.compareDate(dateOne, dateTwo, "year")
    }
    
    /// 比较两个日期是否一样(精确到月)
    ///
    /// - Parameters:
    ///   - dateOne: date
    ///   - dateTwo: date
    /// - Returns: Bool
    func compareDateIsTheSameAccurateToMonth(_ dateOne:Date,_ dateTwo:Date)->Bool{
        return self.compareDate(dateOne, dateTwo, "month")
    }
    
    /// 比较两个日期是否一样(精确到天)
    ///
    /// - Parameters:
    ///   - dateOne: date
    ///   - dateTwo: date
    /// - Returns: Bool
    func compareDateIsTheSameAccurateToDay(_ dateOne:Date,_ dateTwo:Date)->Bool{
        return self.compareDate(dateOne, dateTwo, "day")
    }
    
    /// 判断A日期是不是大于B日期
    ///
    /// - Parameters:
    ///   - dateOne: dateOne description
    ///   - dateTwo: dateTwo description
    /// - Returns: Bool
    func compareDateAisLargeThanDateBAccurateToDay(dateOne:Date,dateTwo:Date) -> Bool {
        var temp = false
        let infoOne = self.getDateInfo(dateOne)
        let infoTwo = self.getDateInfo(dateTwo)
        if infoOne.year! > infoTwo.year!{
            temp = true
        }else{
            if infoOne.year == infoTwo.year{
                if infoOne.month! > infoTwo.month!{
                    return true
                }else{
                    if infoOne.month == infoTwo.month{
                        if infoOne.day! > infoTwo.day!{
                            return true
                        }else{
                            return false
                        }
                    }else{
                        return false
                    }
                }
            }else{
                return false
            }
        }
        return temp
    }
    
    /// 判断A日期是不是小于B日期
    ///
    /// - Parameters:
    ///   - dateOne: dateOne description
    ///   - dateTwo: dateTwo description
    /// - Returns: Bool
    func compareDateAisSmallThanDateBAccurateToDay(dateOne:Date,dateTwo:Date) -> Bool {
        var temp = false
        let infoOne = self.getDateInfo(dateOne)
        let infoTwo = self.getDateInfo(dateTwo)
        if infoOne.year! < infoTwo.year!{
            temp = true
        }else{
            if infoOne.year == infoTwo.year{
                if infoOne.month! < infoTwo.month!{
                    return true
                }else{
                    if infoOne.month == infoTwo.month{
                        if infoOne.day! < infoTwo.day!{
                            return true
                        }else{
                            return false
                        }
                    }else{
                        return false
                    }
                }
            }else{
                return false
            }
        }
        return temp
    }
}
