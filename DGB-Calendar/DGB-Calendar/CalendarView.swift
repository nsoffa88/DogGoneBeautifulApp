//
//  CalendarView.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/16/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarView: UIViewController {
  @IBOutlet weak var calendarView: JTAppleCalendarView!
  @IBOutlet weak var year: UILabel!
  @IBOutlet weak var month: UILabel!
  
  let formatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = Calendar.current.timeZone
    dateFormatter.locale = Calendar.current.locale
    dateFormatter.dateFormat = "yyyy MM dd"
    return dateFormatter
  }()
  
  let todaysDate = Date()
  
    var eventsFromTheServer: [String: String] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        let serverObjects = self.getServerEvents()
        for (date, event) in serverObjects {
            let stringDate = self.formatter.string(from: date)
            self.eventsFromTheServer[stringDate] = event
        }
        
        DispatchQueue.main.async {
            self.calendarView.reloadData()
        }
    }
    calendarView.scrollToDate( Date(), animateScroll: false )
    calendarView.selectDates([ Date() ])
    calendarView.minimumLineSpacing = 0
    calendarView.minimumInteritemSpacing = 0
    
    calendarView.visibleDates { dateSegment in
      self.setupCalendarView(dateSegment: dateSegment)
    }
  }
  
  func setupCalendarView(dateSegment: DateSegmentInfo) {
    guard let date = dateSegment.monthDates.first?.date else { return }
    formatter.dateFormat = "MMM"
    month.text = formatter.string(from: date)
    
    formatter.dateFormat = "yyyy"
    year.text = formatter.string(from: date)
  }
  
  func configureCell(cell: JTAppleCell?, cellState: CellState) {
    guard let myCustomCell = cell as? CustomCell else { return }
    
    cellTextColor(cell: myCustomCell, cellState: cellState)
    cellVisibility(cell: myCustomCell, cellState: cellState)
    cellSelection(cell: myCustomCell, cellState: cellState)
    cellEvents(cell: myCustomCell, cellState: cellState)
  }
  
  func cellTextColor(cell: CustomCell, cellState: CellState) {
    formatter.dateFormat = "yyyy MM dd"
    let todaysDateString = formatter.string(from: todaysDate)
    let monthDateString = formatter.string(from: cellState.date)
    
    if todaysDateString == monthDateString {
      cell.dateLabel.textColor = UIColor.blue
    } else {
      cell.dateLabel.textColor = UIColor.black
    }
  }
  
  func cellVisibility(cell: CustomCell, cellState: CellState) {
    cell.isHidden = cellState.dateBelongsTo == .thisMonth ? false : true
  }
  
  func cellSelection(cell: CustomCell, cellState: CellState) {
    cell.selectedView.isHidden = cellState.isSelected ? false : true
  }
  
  func cellEvents(cell: CustomCell, cellState: CellState) {
    cell.eventDotView.isHidden = !eventsFromTheServer.contains { $0.key == formatter.string(from: cellState.date)}
  }
}

extension CalendarView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
  func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    let startDate = formatter.date(from: "2017 01 01")!
    let endDate = formatter.date(from: "2017 12 31")!
    
    let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
    return parameters
  }
  
  func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
    cell.dateLabel.text = cellState.text
    configureCell(cell: cell, cellState: cellState)
    return cell
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    configureCell(cell: cell, cellState: cellState)
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    configureCell(cell: cell, cellState: cellState)
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    setupCalendarView(dateSegment: visibleDates)
  }
  
  func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
    let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "header", for: indexPath) as! CalendarHeader
    return header
  }
  
  func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
    return MonthSize(defaultSize: 50)
  }
}

extension CalendarView {
  func getServerEvents() -> [Date:String] {
    formatter.dateFormat = "yyyy MM dd"
    
    return[
      formatter.date(from: "2017 10 12")!: "Happy Birthday!",
      formatter.date(from: "2017 10 10")!: "Whaaaaat!",
      formatter.date(from: "2017 10 01")!: "A!",
      formatter.date(from: "2017 10 15")!: "B!",
      formatter.date(from: "2017 10 27")!: "C!",
    ]
  }
}


















