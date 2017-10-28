//
//  ViewInfoViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/26/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit

class ViewInfoViewController: UIViewController {
  
  @IBOutlet weak var eventInfoTableView: UITableView!
  @IBOutlet weak var backToCalendar: UIButton!
  @IBOutlet weak var editEvent: UIButton!
  
  var eventDate: String?
  var event: Event?

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "editEventSegue" {
      if let editVC = segue.destination as? AddEventViewController {
        editVC.buttonInfoObject = "Edit Event"
        editVC.eventDate = eventDate
        editVC.event = event
      }
    }
    if segue.identifier == "infoToCalendarSegue" {
      if let calendarVC = segue.destination as? CalendarView {
        calendarVC.selectedDate = eventDate
      }
    }
  }
}

extension ViewInfoViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell: ClientCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath) as! ClientCell
      cell.clientNameInfo.text = event?.client
      return cell
    } else if indexPath.row == 1 {
      let cell: LocationCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationCell
      cell.locationInfo.text = event?.location
      return cell
    } else if indexPath.row == 2 {
      let cell: TimeCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! TimeCell
      cell.timeInfo.text = event?.time
      return cell
    } else {
      let cell: NotesCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as! NotesCell
      cell.notesInfo.text = event!.notes
      return cell
    }
  }
}



















