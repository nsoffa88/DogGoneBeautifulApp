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
  @IBOutlet weak var addEventButton: UIButton!
  
  let formatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = Calendar.current.timeZone
    dateFormatter.locale = Calendar.current.locale
    dateFormatter.dateFormat = "yyyy MM dd"
    return dateFormatter
  }()
  
  let todaysDate = Date()
  var events: [NSManagedObject] = []
  var selectedDate: String?
  
  var eventsFromTheServer: [String: String] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Event Designation from fake Server, purely for Event Dot pop up, will replace with CoreData
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
    
    //Setting up Calendar
    if selectedDate == nil {
      calendarView.scrollToDate( Date(), animateScroll: false )
      calendarView.selectDates([ Date() ])
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
    //print(events)
    self.eventsTableView.reloadData()
  }
  
  @IBAction func todayButton(_ sender: Any) {
    calendarView.scrollToDate(Date())
    calendarView.selectDates([Date()])
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
    //Will replace with CoreData
    cell.eventDotView.isHidden = !eventsFromTheServer.contains { $0.key == formatter.string(from: cellState.date)}
  }
  
  //Fetching Events from CoreData, sorting by Time and outputting to Events Table
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    loadNSData()
  }
  
  //Changing Button Label on Event Adding View Controller
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addEventSegue" {
      if let eventVC = segue.destination as? AddEventViewController {
        eventVC.buttonInfoObject = "Add Event"
        eventVC.eventDate = selectedDate
      }
    }
    if segue.identifier == "editEventSegue" {
      if let eventVC = segue.destination as? AddEventViewController {
        eventVC.buttonInfoObject = "Edit Event"
      }
    }
  }
  
  @IBAction func addEventSegue(_ sender: Any) {
    self.performSegue(withIdentifier: "addEventSegue", sender: self)
  }
  
  func loadNSData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
    
    let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    if selectedDate == nil {
      selectedDate = formatter.string(from: Date())
      fetchRequest.predicate = NSPredicate(format: "date == %@", selectedDate!)
    } else {
      fetchRequest.predicate = NSPredicate(format: "date == %@", selectedDate!)
    }
    
    do {
      events = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
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
    selectedDate = formatter.string(from: date)
    
    loadNSData()
    
    eventsTableView.reloadData()
    print("called!")
    cell?.bounce()
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    configureCell(cell: cell, cellState: cellState)
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    setupCalendarView(dateSegment: visibleDates)
  }
}

extension CalendarView: UITableViewDataSource {
  func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let event = events[indexPath.row]
    let cell = eventsTableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
    cell.textLabel?.text = event.value(forKeyPath: "name") as? String
    cell.detailTextLabel?.text = event.value(forKeyPath: "time") as? String
    return cell
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



















