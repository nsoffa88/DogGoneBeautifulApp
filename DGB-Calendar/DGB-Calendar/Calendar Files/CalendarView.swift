//
//  CalendarView.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/16/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData
import CloudKit

class CalendarView: UIViewController {
  @IBOutlet weak var calendarView: JTAppleCalendarView!
  @IBOutlet weak var year: UILabel!
  @IBOutlet weak var month: UILabel!
  @IBOutlet weak var todayButton: UIButton!
  @IBOutlet weak var eventsTableView: UITableView!
  
  let formatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = Calendar.current.timeZone
    dateFormatter.locale = Calendar.current.locale
    dateFormatter.dateFormat = "yyyy MM dd"
    return dateFormatter
  }()
  
  let todaysDate = Date()
  var eventRecords: [CKRecord]?
  var todaysEvents: [CKRecord] = []
  var selectedDate: String?
  var eventRecord: CKRecord?
  
  var clientRecords: [CKRecord]?
  var todaysClientsRecords = [CKRecord]()
  var clientRecord: CKRecord?
  var dogRecords: [CKRecord]?
  var loaded: Int = 0
  
  let database = CKContainer.default().privateCloudDatabase
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    queryDatabase()
  }
  
  func setUpCalendar() {
    calendarView.minimumLineSpacing = 0
    calendarView.minimumInteritemSpacing = 0
    calendarView.scrollDirection = .vertical
    
    calendarView.visibleDates { dateSegment in
      self.setupCalendarView(dateSegment: dateSegment)
    }
    
    //Setting up Events Table
    eventsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "detailCell")
    self.eventsTableView.reloadData()
  }
  
  @IBAction func todayButton(_ sender: Any) {
    formatter.dateFormat = "yyyy MM dd"
    calendarView.selectDates([todaysDate])
    calendarView.scrollToDate(todaysDate)
    selectedDate = formatter.string(from: todaysDate)
  }
  
  func setupCalendarView(dateSegment: DateSegmentInfo) {
    guard let date = dateSegment.monthDates.first?.date else { return }
    formatter.dateFormat = "MMMM"
    month.text = "  " + formatter.string(from: date)
    
    formatter.dateFormat = "yyyy"
    year.text = "  " + formatter.string(from: date)
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
      cell.dateLabel.textColor = UIColor.white
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
    if eventRecords == nil {
      cell.eventDotView.isHidden = true
    } else {
      cell.eventDotView.isHidden = !(eventRecords?.contains { $0.value(forKey: "Date") as! String == formatter.string(from: cellState.date)})!
    }
  }
  
  //Fetching todaysEvents from Events Array, sorting by Time and outputting to Events Table
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    getEventsByDate()
//  }
  
  //Passing variables between ViewControllers
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addEventSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let addEventVC = destinationNavController.topViewController as? AddEventViewController {
        addEventVC.newEvent = true
        addEventVC.eventDate = selectedDate
        addEventVC.eventRecords = eventRecords!
        addEventVC.todaysEventRecords = todaysEvents
        addEventVC.dogRecords = dogRecords!
        addEventVC.clientRecords = clientRecords!
      }
    }
    if segue.identifier == "viewEventSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let viewEventVC = destinationNavController.topViewController as? ViewInfoViewController {
        viewEventVC.eventDate = selectedDate
        viewEventVC.eventRecord = eventRecord!
        viewEventVC.clientRecord = clientRecord!
        viewEventVC.dogRecords = dogRecords
        viewEventVC.clientRecords = clientRecords
      }
    }
  }
  
  func queryDatabase() {
    let eventQuery = CKQuery(recordType: "Event", predicate: NSPredicate(value: true))
    eventQuery.sortDescriptors = [NSSortDescriptor(key: "Date", ascending: true)]
    database.perform(eventQuery, inZoneWith: nil) { (records, error) in
      if error == nil {
        self.eventRecords = records!
      } else {
        print(error)
      }
      if self.loaded == 2 {
        DispatchQueue.main.async {
          self.setUpCalendar()
          self.calendarView.reloadData()
          self.eventsTableView.reloadData()
          self.todayButton(self)
        }
      } else {
        self.loaded = self.loaded + 1
      }
    }
    
    let clientQuery = CKQuery(recordType: "Client", predicate: NSPredicate(value: true))
    clientQuery.sortDescriptors = [NSSortDescriptor(key: "Name", ascending: true)]
    database.perform(clientQuery, inZoneWith: nil) { (records, error) in
      if error == nil {
        self.clientRecords = records!
      } else {
        print(error)
      }
      if self.loaded == 2 {
        DispatchQueue.main.async {
          self.setUpCalendar()
          self.calendarView.reloadData()
          self.eventsTableView.reloadData()
          self.todayButton(self)
        }
      } else {
        self.loaded = self.loaded + 1
      }
    }
    
    let dogQuery = CKQuery(recordType: "Dog", predicate: NSPredicate(value: true))
    database.perform(dogQuery, inZoneWith: nil) { (records, error) in
      if error == nil {
        self.dogRecords = records!
      } else {
        print(error)
      }
      if self.loaded == 2 {
        DispatchQueue.main.async {
          self.setUpCalendar()
          self.calendarView.reloadData()
          self.eventsTableView.reloadData()
          self.todayButton(self)
        }
      } else {
        self.loaded = self.loaded + 1
      }
    }
  }
  
  func getEventsByDate() {
    todaysEvents = []
    todaysClientsRecords = []
    for allEvents in eventRecords! {
      if allEvents.value(forKey: "Date") as! String == selectedDate {
        todaysEvents.append(allEvents)
        let clientReference = allEvents.value(forKey: "ClientReference") as! CKReference
        for record in clientRecords! {
          if clientReference.recordID.recordName == record.recordID.recordName {
            todaysClientsRecords.append(record)
          }
        } 
      }
    }
    todaysEvents.sort(by: { $1.value(forKey: "Time") as! String > $0.value(forKey: "Time") as! String })
    DispatchQueue.main.async {
      self.eventsTableView.reloadData()
    }
  }
  
  // Functions for NavBar
  @IBAction func doneViewingInfo(_ segue: UIStoryboardSegue) {
    getEventsByDate()
    DispatchQueue.main.async {
      self.calendarView.reloadData()
      self.eventsTableView.reloadData()
    }
  }
  @IBAction func doneSavingEvent(_ segue: UIStoryboardSegue) {
    getEventsByDate()
    print(todaysEvents)
    DispatchQueue.main.async {
      self.calendarView.reloadData()
      self.eventsTableView.reloadData()
    }
  }
}

extension CalendarView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
  func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    formatter.dateFormat = "yyyy MM dd"
    let startDate = formatter.date(from: "2017 01 01")!
    let endDate = formatter.date(from: "2050 12 31")!
    
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
    selectedDate = formatter.string(from: date)
    
    if eventRecords != nil {
      getEventsByDate()
    }
    
    cell?.bounce()
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    configureCell(cell: cell, cellState: cellState)
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    setupCalendarView(dateSegment: visibleDates)
  }
}

extension CalendarView: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todaysEvents.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let event = todaysEvents[indexPath.row]
    let cell = eventsTableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
    let clientReference = event.value(forKey: "ClientReference") as! CKReference
    var clientRecord: CKRecord?
    for record in clientRecords! {
      if clientReference.recordID.recordName == record.recordID.recordName {
        clientRecord = record
        todaysClientsRecords.append(record)
      }
    }
    cell.textLabel?.text = clientRecord?.value(forKey: "Name") as? String
    cell.detailTextLabel?.text = event.value(forKey: "Time") as? String
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    eventRecord = todaysEvents[indexPath.row]
    clientRecord = todaysClientsRecords[indexPath.row]
    self.performSegue(withIdentifier: "viewEventSegue", sender: self)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let eventIDToRemove = todaysEvents[indexPath.row].recordID
    
    database.delete(withRecordID: eventIDToRemove) { (records, error) in
      if error == nil {
        self.todaysEvents.remove(at: indexPath.row)
        for (index, event) in (self.eventRecords?.enumerated())! {
          if event.recordID.recordName == eventIDToRemove.recordName {
            self.eventRecords?.remove(at: index)
          }
        }
      } else {
        print(error)
      }
      DispatchQueue.main.async {
        
        self.eventsTableView.reloadData()
      }
    }
  }
}

extension UIView {
  func bounce() {
    self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    UIView.animate(
      withDuration: 0.5,
      delay: 0, usingSpringWithDamping: 0.3,
      initialSpringVelocity: 0.1,
      options: UIViewAnimationOptions.beginFromCurrentState,
      animations: {
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
    })
  }
}





