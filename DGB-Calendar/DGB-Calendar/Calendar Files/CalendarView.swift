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
  var events: [Event]?
  var todaysEvents: [Event] = []
  var selectedDate: String?
  var event: Event?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Pulling from Core Data
    if events == nil {
      loadNSData()
    }
    
    //Setting up Calendar
    if selectedDate == nil {
      calendarView.scrollToDate( todaysDate, animateScroll: false )
      calendarView.selectDates([ todaysDate ])
    } else {
      calendarView.scrollToDate(formatter.date(from: selectedDate!)!, animateScroll: false )
      calendarView.selectDates([formatter.date(from: selectedDate!)!])
    }
    calendarView.minimumLineSpacing = 0
    calendarView.minimumInteritemSpacing = 0
    calendarView.scrollDirection = .vertical
    
    calendarView.visibleDates { dateSegment in
      self.setupCalendarView(dateSegment: dateSegment)
    }
    
    //Setting up Events Table
    eventsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    self.eventsTableView.reloadData()
  }
  
  @IBAction func todayButton(_ sender: Any) {
    calendarView.scrollToDate(todaysDate)
    calendarView.selectDates([todaysDate])
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
    cell.eventDotView.isHidden = !(events?.contains { $0.date == formatter.string(from: cellState.date)})!
  }
  
  //Fetching todaysEvents from Events Array, sorting by Time and outputting to Events Table
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getEventsByDate()
  }
  
  //Passing variables between ViewControllers
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addEventSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let addEventVC = destinationNavController.topViewController as? AddEventViewController {
        addEventVC.newEvent = true
        addEventVC.eventDate = selectedDate
        addEventVC.events = events!
      }
    }
    if segue.identifier == "viewEventSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let viewEventVC = destinationNavController.topViewController as? ViewInfoViewController {
        viewEventVC.eventDate = selectedDate
        viewEventVC.event = event!
      }
    }
  }
  
  // Only do this once on viewDidLoad, output to array, and access that array for EventTable
  func loadNSData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")

    do {
      events = try managedContext.fetch(fetchRequest) as! [Event]
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
  
  func getEventsByDate() {
    todaysEvents = []
    for allEvents in events! {
      if allEvents.date == selectedDate {
        todaysEvents.append(allEvents)
      }
    }
    todaysEvents.sort(by: { $0.time! < $1.time! })
  }
  
  // Functions for NavBar
  @IBAction func doneViewingInfo(_ segue: UIStoryboardSegue) {
    loadNSData()
    getEventsByDate()
    calendarView.reloadData()
    eventsTableView.reloadData()
  }
  @IBAction func doneSavingEvent(_ segue: UIStoryboardSegue) {
    loadNSData()
    getEventsByDate()
    calendarView.reloadData()
    eventsTableView.reloadData()
  }
}

extension CalendarView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
  func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    formatter.dateFormat = "yyyy MM dd"
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
    selectedDate = formatter.string(from: date)
    
    getEventsByDate()
    
    eventsTableView.reloadData()
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
    cell.textLabel?.text = event.value(forKeyPath: "eventClientName") as? String
    cell.detailTextLabel?.text = event.value(forKeyPath: "time") as? String
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    event = todaysEvents[indexPath.row] as Event
    self.performSegue(withIdentifier: "viewEventSegue", sender: self)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let eventToRemove = todaysEvents[indexPath.row] as? Event, editingStyle == .delete else {
      return
    }
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    managedContext.delete(eventToRemove)
    do {
      try managedContext.save()
      getEventsByDate()
      eventsTableView.reloadData()
      calendarView.reloadData()
    } catch let error as NSError {
      print("Deleting error: \(error), \(error.userInfo)")
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





