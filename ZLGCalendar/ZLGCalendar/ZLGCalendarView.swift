//
//  ZLGCalendarView.swift
//  zhulogicgc
//
//  Created by 徐亚东 on 2019/6/13.
//  Copyright © 2019 zhulogicgc. All rights reserved.
//

import UIKit

private let headHeight:CGFloat = 90
private let bottomHeight : CGFloat = 30
private let Width_Screen = UIScreen.main.bounds.size.width

private let UIColor_333333    =    UIColor.init(named: "333333")
private let UIColor_A0A0A0    =    UIColor.init(named: "A0A0A0")

private let Font_system18:UIFont! = UIFont.init(name: "PingFangSC-Regular", size: 18)
private let Font_system12:UIFont! = UIFont.init(name: "PingFangSC-Regular", size: 12)

enum ZLGCalendarStyle : String{
    case mStyleOfMonth = "显示月历"
    case mStyleOfWeek = "显示周历"
}

class ZLGCalendarView: UIView {
    
    var updateMonth = {()->Void in}//月份变化
    var updateDay = {(_ updateDate:Date)->Void in}//日期更新
    var updateSize = {(_ size:CGSize)->Void in}//高度更新

    //设置显示的样式
    var mStyle = ZLGCalendarStyle.mStyleOfWeek{
        didSet{
            if self.mStyle == .mStyleOfWeek{
                self.actionExtend(extend: false)
            }else{
                self.actionExtend(extend: true)
            }
        }
    }
    ///有产出的日期
    var mOutputDates:[Date] = [Date](){
        didSet{
            
        }
    }
//    ///将有产出的日期按月份拆分成自动
//    var mOutputDatesOfDic = [String:[Date]]()
    
    /// 格式(1970/1/1)
    var startDate:Date? {
        didSet{
            self.dataSourceManager.startDate = self.startDate
            self.reloadData()
        }
    }
    
    /// 格式(1970/1/1)
    var endDate:Date?{
        didSet{
            self.dataSourceManager.endDate = self.endDate
            self.reloadData()
        }
    }

    /// 格式(1970-1-1)
    var selectedDate:Date?{
        didSet{
//            if self.selectedDate != nil{
//                if self.mStyle == .mStyleOfWeek{
//                    let index = self.dataSourceManager.getIndexOfDatasourceOfWeeks(date: self.selectedDate!)
//                    self.collectionView.contentOffset = CGPoint.init(x:self.collectionView.width * CGFloat(index), y: 0)
//                }else{
//                    let index = self.dataSourceManager.getIndexOfDatasourceOfMonths(date: self.selectedDate!)
//                    self.collectionView.contentOffset = CGPoint.init(x:self.collectionView.width * CGFloat(index), y: 0)
//                }
//            }
        }
    }
//    var selectDateAccuracyToMonth:String = ""
    //当前显示的月份
     var currentDate = Date(){
        didSet{
            self.titleDate = self.dateTool.getDateToStr(self.currentDate, { (year, month, day) -> String in
                return "\(year)/\(month)"
            })
        }
    }
    
    fileprivate var titleDate :String!{
        didSet{
            let temp = self.vHeadView.viewWithTag(1000) as! UILabel
            temp.text = self.titleDate
        }
    }
    fileprivate var firstBool = false
    fileprivate let dataSourceManager = ZLGCalendarDatasoruceManager()
    
    fileprivate let cellID = "ZLGCalendarCell"
    fileprivate let Hgap : CGFloat = 20
    fileprivate let cellSize = CGSize.init(width: Width_Screen, height: 220)
    
    fileprivate let dateTool = ZLGDateTool()
    fileprivate let mWeekSort : [ZLGWeek] = [.Sunday,.Monday,.Tuesday,.Wednesday,.Thursday,.Friday,.Saturday]
    fileprivate var weekNames = [String]()
    
    fileprivate lazy var vHeadView: UIView = {
        let temp = UIView()
        
        self.weekNames = self.mWeekSort.map{$0.rawValue}
        
        let dateLabel = UILabel()
        dateLabel.setAttribute(title: "", titleColor: UIColor_333333, font: Font_system18, backgroundColor: nil)
        dateLabel.text = self.dateTool.getDateOfYearAndMonthWithConnectSymbols(self.dateTool.getCurrentDate(), ["/"])
        dateLabel.tag = 1000
        
        let leftBtn = UIButton.init(type: .custom)
        leftBtn.setImage(UIImage.init(named: "left红"), for: .normal)
        leftBtn.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
        
        let rightBtn = UIButton.init(type: .custom)
        rightBtn.setImage(UIImage.init(named: "right红"), for: .normal)
        rightBtn.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
        
        let itemSize :CGSize  = CGSize.init(width: Width_Screen/CGFloat(self.weekNames.count), height:headHeight/2)
        var tempLab : UILabel?
        for weekName in self.weekNames{
            let weekLab = UILabel()
            weekLab.textColor = UIColor_A0A0A0
            weekLab.font = Font_system12
            weekLab.textAlignment = NSTextAlignment.center
            weekLab.text = weekName
            temp.addSubview(weekLab)
            if tempLab == nil{
                weekLab.snp.makeConstraints({ (make) in
                    make.left.equalToSuperview()
                    make.top.equalToSuperview().offset(headHeight/2)
                    make.size.equalTo(itemSize)
                })
            }else{
                weekLab.snp.makeConstraints({ (make) in
                    make.left.equalTo(tempLab!.snp_right)
                    make.top.equalToSuperview().offset(headHeight/2)
                    make.size.equalTo(itemSize)
                })
            }
            tempLab = weekLab
        }
        
        temp.addSubview(dateLabel)
        temp.addSubview(leftBtn)
        temp.addSubview(rightBtn)
        
        dateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(headHeight/2)
            make.top.equalToSuperview()
        }
        
        let btnSize = CGSize.init(width: 40, height: 40)
        let tempGap : CGFloat = 56
        leftBtn.snp.makeConstraints({ (make) in
            make.right.equalTo(dateLabel.snp_left).offset(-tempGap)
            make.centerY.equalTo(dateLabel)
            make.size.equalTo(btnSize)
        })
        
        rightBtn.snp.makeConstraints({ (make) in
            make.left.equalTo(dateLabel.snp_right).offset(tempGap)
            make.centerY.equalTo(dateLabel)
            make.size.equalTo(btnSize)
        })
        
        return temp
    }()
    
    fileprivate lazy var flowLayout: ZLGCalendarViewFlowLayout = {
        let flowLayout = ZLGCalendarViewFlowLayout.init()
        flowLayout.itemSize = self.cellSize
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }()
    fileprivate lazy var collectionView:UICollectionView = {
        let collectionview = UICollectionView.init(frame: .zero, collectionViewLayout: self.flowLayout)
        collectionview.register(.init(nibName: "ZLGcalendarCollectionCell", bundle: nil), forCellWithReuseIdentifier: cellID)
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.isPagingEnabled = true
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.backgroundColor = .white
        return collectionview
    }()
    fileprivate lazy var vBottom: UIView = {
        let temp = UIView()
        temp.backgroundColor = .white
        temp.frame = CGRect.init(x: 0, y: 0, width: Width_Screen, height: bottomHeight)
        
        let imageView = UIImageView()
        imageView.tag = 100
        imageView.image = UIImage.init(named: "下拉")
        temp.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        temp.addTarget(self, #selector(bottomAction))
        
        return temp
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.vHeadView)//头部视图
        self.addSubview(self.collectionView)
        self.addSubview(self.vBottom)
    
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.vHeadView.frame = CGRect.init(x: 0, y: 0, width: Width_Screen, height: headHeight)
        self.collectionView.frame = CGRect.init(x: 0, y: self.vHeadView.maxY, width: Width_Screen, height: self.height - headHeight - self.vBottom.height)
        self.vBottom.frame = CGRect.init(x: self.vBottom.minX, y: self.collectionView.maxY, width: self.vBottom.width, height: self.vBottom.height)
        if !self.firstBool {
            self.firstBool = true
            if self.selectedDate != nil{
                if self.mStyle == .mStyleOfWeek{
                    let index = self.dataSourceManager.getIndexOfDatasourceOfWeeks(date: self.selectedDate!)
                    self.collectionView.contentOffset = CGPoint.init(x:self.collectionView.width * CGFloat(index), y: 0)
                }else{
                    let index = self.dataSourceManager.getIndexOfDatasourceOfMonths(date: self.selectedDate!)
                    self.collectionView.contentOffset = CGPoint.init(x:self.collectionView.width * CGFloat(index), y: 0)
                }
            }
        }
    }
    
    /// 将日历重置到当前选中的日期处
    func resetToSelectDate(){
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func createDateView(_ dayText:String)->ZLGCalendarItemsView{
        let temp = ZLGCalendarItemsView()
        return temp
    }
    
//    private func updateDataSource(_ last:Bool){
//        let firstDate = self.dataSource.first!
//        let lastDate = self.dataSource.last!
//        if last{
//            self.dataSource.removeLast()
//            self.dataSource.insert(self.dateTool.getLastMonthFromDate(firstDate), at: 0)
//        }else{
//            self.dataSource.removeFirst()
//            self.dataSource.append(self.dateTool.getNextMonthFromDate(lastDate))
//        }
//    }
}
// MARK:- functions
extension ZLGCalendarView{
    
    func reloadData(){
        self.collectionView.reloadData()
    }
    
    @objc fileprivate func bottomAction(){
        if self.mStyle == .mStyleOfWeek{
            self.mStyle = .mStyleOfMonth
        }else{
            self.mStyle = .mStyleOfWeek
        }
        self.reloadData()
        //处理月到周 周到月的切换
        if self.mStyle == .mStyleOfWeek{//月到周的切换
            if self.selectedDate != nil {//有选中的日期
                if self.dateTool.compareDateIsTheSameAccurateToMonth(self.currentDate, self.selectedDate!){//如果当前选中的日期正好在当期显示的月 则切换时显示到选中的那一周
                   let index = self.dataSourceManager.getIndexOfDatasourceOfWeeks(date: self.selectedDate!)
                    self.collectionView.contentOffset = CGPoint.init(x:self.collectionView.width * CGFloat(index), y: 0)
                }else{//当前显示的月份的第一周
                    let index = self.dataSourceManager.getIndexOfDatasourceOfWeeks(date: self.dateTool.getAccurateDateOfDayByDate(date: self.currentDate, day: 1) ?? Date())
                    self.collectionView.contentOffset = CGPoint.init(x:self.collectionView.width * CGFloat(index), y: 0)
                }
            }else{
                let index = self.dataSourceManager.getIndexOfDatasourceOfWeeks(date: self.dateTool.getAccurateDateOfDayByDate(date: self.currentDate, day: 1) ?? Date())
                self.collectionView.contentOffset = CGPoint.init(x:self.collectionView.width * CGFloat(index), y: 0)
            }
        }else{//周到月的切换
            let index = self.dataSourceManager.getIndexOfDatasourceOfMonths(date: self.currentDate)
            self.collectionView.contentOffset = CGPoint.init(x:self.collectionView.width * CGFloat(index), y: 0)
        }
        
    }
    @objc fileprivate  func leftAction(){
        if self.collectionView.contentOffset.x > 0 {
//            self.collectionView.contentOffset = CGPoint.init(x: self.collectionView.contentOffset.x - self.collectionView.width, y: self.collectionView.contentOffset.y)
            self.collectionView.setContentOffset(.init(x: self.collectionView.contentOffset.x - self.collectionView.width, y: self.collectionView.contentOffset.y), animated: false)
            self.collectionView.delegate?.scrollViewDidEndDecelerating?(self.collectionView)
        }
    }
    
    @objc fileprivate  func rightAction(){
        if self.collectionView.contentOffset.x < self.collectionView.contentSize.width - self.collectionView.width{
//            self.collectionView.contentOffset = CGPoint.init(x: self.collectionView.contentOffset.x + self.collectionView.width, y: self.collectionView.contentOffset.y)
            self.collectionView.setContentOffset(.init(x: self.collectionView.contentOffset.x + self.collectionView.width, y: self.collectionView.contentOffset.y), animated: false)
            self.collectionView.delegate?.scrollViewDidEndDecelerating?(self.collectionView)
        }
    }
    
    fileprivate func actionExtend(extend:Bool){
        guard let imageV = self.vBottom.viewWithTag(100) else {
            return
        }
        imageV.transform = extend ? .init(rotationAngle: .pi) : .identity
    }
}

extension ZLGCalendarView:UICollectionViewDataSource,UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.mStyle == .mStyleOfMonth{
           return self.dataSourceManager.mMangers.count
        }else{
            var tempCount = 0
            for value in self.dataSourceManager.mMangers{
                tempCount += value.mDataSourceOfWeeks.count
            }
           return tempCount
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ZLGcalendarCollectionCell
        weak var weakSelf = self
        cell.vCalendarItemViews.updataSize = {(size)->Void in
                weakSelf?.collectionView.height = size.height
                weakSelf?.height = headHeight + size.height + self.vBottom.height
                weakSelf?.updateSize(CGSize.init(width: Width_Screen, height: weakSelf?.height ?? 0))
        }
        cell.vCalendarItemViews.updateDate = {(date:Date)->Void in
                weakSelf?.selectedDate = date
        }
            cell.vCalendarItemViews.mWeekSort = self.mWeekSort
            cell.vCalendarItemViews.mOutputDates = self.mOutputDates
            cell.vCalendarItemViews.mSelectDate = self.selectedDate
        
        if self.mStyle == .mStyleOfMonth{
            cell.vCalendarItemViews.mMonthDate = self.dataSourceManager.mMangers[indexPath.row].mDataSourceOfMonth[10]
            cell.vCalendarItemViews.mDateSource = self.dataSourceManager.mMangers[indexPath.row].mDataSourceOfMonth
        }else{
            let newDatasource = self.dataSourceManager.mMangers.flatMap{$0.mDataSourceOfWeeks}
            
            var tempCount = 0
            var tempIndex = 0
            for (index,value) in self.dataSourceManager.mMangers.enumerated(){
                tempCount += value.mDataSourceOfWeeks.count
                if indexPath.row < tempCount{
                    tempIndex = index
                    break
                }
            }
            cell.vCalendarItemViews.mMonthDate = self.dataSourceManager.mMangers[tempIndex].mDataSourceOfMonth[10]
            cell.vCalendarItemViews.mDateSource = newDatasource[indexPath.row]
        }
            return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                let offsetIndex = scrollView.contentOffset.x/Width_Screen .rounded(.towardZero)
        if self.mStyle == .mStyleOfMonth {
            //取10是因为月份列表的第十个一定是当期月份的日期
            if Int(offsetIndex) < 0 ||  Int(offsetIndex) >= self.dataSourceManager.mMangers.count{
                return
            }
            self.currentDate = self.dataSourceManager.mMangers[Int(offsetIndex)].mDataSourceOfMonth[10]
        }else{
            var tempCount = 0
            var tempIndex = 0
            for (index,value) in self.dataSourceManager.mMangers.enumerated(){
                tempCount += value.mDataSourceOfWeeks.count
                if Int(offsetIndex) < tempCount{
                    tempIndex = index
                    break
                }
            }
            if tempIndex < 0 ||  tempIndex >= self.dataSourceManager.mMangers.count{
                return
            }
            self.currentDate = self.dataSourceManager.mMangers[tempIndex].mDataSourceOfMonth[10]
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _ = scrollView.contentOffset.x/Width_Screen .rounded(.towardZero)
        if self.mStyle == .mStyleOfMonth{//月份的话需要重新刷新下 因为高度可能是不一样的
//            self.reloadData()
        }else{
        
        }
        self.updateMonth()
    }
}

/// ZLGCalendarItemsView
class ZLGCalendarItemsView: UIView {
    var updataSize = {(_ size:CGSize)->Void in}
    var updateDate = {(_ date:Date)->Void in}
    var lastClickItem:ZLGCalendarItemView?
    
    var mStyle = ZLGCalendarStyle.mStyleOfWeek
    
    private var itemViews = [UIView]()
    private let dateTool = ZLGDateTool()
    private let cellSize = CGSize.init(width: Width_Screen, height: 220)
    
    var mDateSource = [Date](){
        didSet{
            self.createItemViews()
        }
    }//列表日期数据源
    //通过设置一个月份创建月日历
    var mMonthDate:Date?{
        didSet{
        }
    }
    //选中的日期
    var mSelectDate:Date?
    //要标记的日期
    var mOutputDates:[Date] = [Date](){
        didSet{
 
        }
    }
    
    fileprivate var mMonthDays = 0 //一个月的具体天数
    fileprivate var mStrOfFirstDay = "" //月份的第一天日期字符串 ：year/month/day
    fileprivate var mStrOfLastDay = "" //月份的最后一天日期字符串 ：year/month/day
    fileprivate var mWeekInfoOfFirstDay = ZLGWeek.Monday//月份的第一天是星期几
    fileprivate var mWeekInfoOfLastDay = ZLGWeek.Monday//月份的最后一天是星期几
    
    //获取当前日期上个月的实际天（显示月份日历时要将第一行不足一行的用上个月的日期补齐）
    fileprivate var mLastMonthDays = 0
    
    fileprivate var mLastMonth = Date()//上个月的日期
    fileprivate var mNextMonth = Date()//下个月的日期
    fileprivate var mWeekSort : [ZLGWeek] = [ZLGWeek]()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func createItemViews(){
//        for value in self.itemViews{value.removeFromSuperview()}
//        self.itemViews.removeAll()
                let maxRow = 7 //一行显示7个
        //        var maxColumn = 5 //列表的行数(默认5行，不同月份的列表排列行数不一样，每个月是28-31天 故一行显示七个最少4行，最多6行)
        //        maxColumn = self.mDateSource.count/maxRow + (self.mDateSource.count%maxRow == 0 ? 0:1)
        let itemSize = CGSize.init(width: cellSize.width / CGFloat(maxRow), height: cellSize.width / CGFloat(maxRow))
        if self.itemViews.count == 0{
            for index in 0..<42{
                let itemView = ZLGCalendarItemView()
                itemView.frame = CGRect.init(x: CGFloat((index) % maxRow ) * itemSize.width, y: CGFloat((index)/maxRow) * itemSize.height, width: itemSize.width, height: itemSize.height)
                self.itemViews.append(itemView)
                self.addSubview(itemView)
            }
        }
        for (index,dateValue) in self.mDateSource.enumerated(){
            let itemView  = self.itemViews[index] as! ZLGCalendarItemView
            itemView.isHidden = false
            itemView.mDate = dateValue
            itemView.vLab.text = String(self.dateTool.getDateInfo(dateValue).day!)
            weak var weakSelf = self
            itemView.mStatus = .mNormal
            if  !self.dateTool.compareDateIsTheSameAccurateToMonth(self.mMonthDate!, dateValue){
                 itemView.mStatus = .mCanNotSelected
             }else if self.mSelectDate != nil {
                 if self.dateTool.compareDateIsTheSameAccurateToDay(self.mSelectDate!, itemView.mDate!){
                     itemView.mStatus = .mSelected
                     self.lastClickItem = itemView
                 }
             }
            // 这样处理很卡 放在异步线程里面
            DispatchQueue.global().async {
                if self.mOutputDates.contains(where: { (date) -> Bool in
                     return self.dateTool.compareDateIsTheSameAccurateToDay(date, itemView.mDate!)
                 }){
                    if itemView.mStatus == .mNormal{
                        DispatchQueue.main.async {
                           itemView.mStatus = .mHaveOutPut
                        }
                    }else if itemView.mStatus == .mCanNotSelected{
                        DispatchQueue.main.async {
                           itemView.mStatus = .mCanNotSelectedHaveOutput
                        }
                    }
                 }
            }
            itemView.mClickBack = {(_ item:ZLGCalendarItemView)->Void in
                guard weakSelf != nil else{
                    return
                }
                if weakSelf?.lastClickItem != nil{
                    var status = ZLGCalendarItemViewStatus.mNormal
                    if weakSelf!.mOutputDates.contains(where: { (date) -> Bool in
                        return weakSelf!.dateTool.compareDateIsTheSameAccurateToDay(date, weakSelf!.lastClickItem!.mDate!)
                     }){
                        status = .mHaveOutPut
                     }
                    weakSelf?.lastClickItem?.mStatus = status
                }
                item.mStatus = .mSelected
                weakSelf?.lastClickItem = item
                weakSelf?.updateDate(item.mDate!)
            }
        }
        for index in self.mDateSource.count..<42{
            let itemView  = self.itemViews[index] as! ZLGCalendarItemView
            itemView.isHidden = true
        }
        guard self.itemViews.count != 0 else{
            return
        }
//        self.updataSize(CGSize.init(width: cellSize.width,height:self.itemViews.last!.maxY))
        self.updataSize(CGSize.init(width: cellSize.width,height:self.itemViews[self.mDateSource.count - 1].maxY))
//        self.updataSize(CGSize.init(width: cellSize.width,height:self.itemViews.last!.maxY))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView{
    var minX: CGFloat {
        
        return self.frame.origin.x
        
    }
    
    // 获取view右边的坐标
    
    var maxX: CGFloat {
        
        return self.frame.origin.x + self.frame.size.width
        
    }
    
    // 获取view上边的坐标
    
    var minY: CGFloat {
        
        return self.frame.origin.y
        
    }
    
    // 获取view下边的坐标
    
    var maxY: CGFloat {
        
        return self.frame.origin.y + self.frame.size.height
        
    }
    
    // 获取view的x轴的中心点
    
    var centerX: CGFloat {
        
        return self.center.x
        
    }
    
    // 获取view的y轴的中心点
    
    var centerY: CGFloat {
        
        return self.center.y
        
    }
    
    // 获取view的宽度
    
    var width: CGFloat {
        
        get{
            return self.frame.size.width
        }
        set{
            self.frame = CGRect.init(x: self.minX, y: self.minY, width: newValue, height: self.height)
        }
    }
    
    // 获取view的高度
    
    var height: CGFloat {
        
        get{
            return self.frame.size.height
        }
        set{
            self.frame = CGRect.init(x: self.minX, y: self.minY, width: self.width, height: newValue)
        }
    }
    
    // 获取view的size
    
    var size: CGSize {
        
        return self.frame.size
        
    }
    /// 扩展UIView添加单击事件
    ///
    /// - Parameters:
    ///   - target: target
    ///   - action: action
    func addTarget(_ target:Any,_ action:Selector){
        let tap = UITapGestureRecognizer()
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
        tap.addTarget(target, action: action)
    }
}

extension UILabel{
    func setAttribute(title: String?, titleColor: UIColor?, font: UIFont?, backgroundColor: UIColor?) {
        
        if backgroundColor != nil {
            self.backgroundColor = backgroundColor
        }
        
        if title != nil
        {
            self.text = title
        }
        
        if titleColor != nil
        {
            self.textColor = titleColor
        }
        
        if font != nil
        {
            self.font = font
        }
        
    }
}
