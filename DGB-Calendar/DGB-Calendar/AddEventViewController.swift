//
//  AddEventViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/17/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CoreData

class AddEventViewController: UIViewController {
  @IBOutlet weak var timeSelection: UITextField!
  @IBOutlet weak var clientTextField: UITextField!
  @IBOutlet weak var locationTextField: UITextField!
  @IBOutlet weak var notesTextField: UITextField!
  @IBOutlet weak var addEventButton: UIButton!
  @IBOutlet weak var cancelEventSave: UIButton!

  let picker = UIDatePicker()
//  var events: [NSManagedObject] = []
  var buttonInfoObject: String?
  var eventDate: String?
  var event: Event?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createTimePicker()
    
    //Setting title of EventButton
    if buttonInfoObject != nil {
      addEventButton.setTitle(buttonInfoObject, for: .normal)
    }
    
    if event != nil {
      clientTextField.text = event?.client
      timeSelection.text = event?.time
      locationTextField.text = event?.location
      notesTextField.text = event?.notes
    }
  }

  func createTimePicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    toolbar.setItems([done], animated: false)
    
    timeSelection.inputAccessoryView = toolbar
    timeSelection.inputView = picker
    
    picker.datePickerMode = .time
  }
  
  @objc func donePressed() {
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short
    let timeString = timeFormatter.string(from: picker.date)
    
    timeSelection.text = "\(timeString)"
    self.view.endEditing(true)
  }
  
  //Send this event's Date back to CalendarView for the UI to still be on correct Date
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "backToCalendarSegue" {
      if let calendarVC = segue.destination as? CalendarView {
        calendarVC.selectedDate = eventDate
//        calendarVC.events = events
      }
    }
  }
    
  @IBAction func cancelEvent(_ sender: Any) {
    self.performSegue(withIdentifier: "backToCalendarSegue", sender: self)
  }
  
  @IBAction func addEventToCalendar(_ sender: Any) {
    print(clientTextField.text!)
    print(timeSelection.text!)
    if(clientTextField.text! != "" && timeSelection.text! != "") {
      let clientToSave =  clientTextField.text
      let locationToSave = locationTextField.text
      let timeToSave = timeSelection.text
      let notesToSave = notesTextField.text
    
      self.save(client: clientToSave!, location: locationToSave!, time: timeToSave!, notes: notesToSave!, date: eventDate!)
      self.performSegue(withIdentifier: "backToCalendarSegue", sender: self)
    } else {
      let alert = UIAlertController(title: "Error",
                                    message: "Must include atleast a Client and Time",
                                    preferredStyle: .alert)
      let endAlert = UIAlertAction(title: "Back",
                                   style: .default)
      alert.addAction(endAlert)
      present(alert, animated: true)
    }
  }
  
  func save(client: String, location: String, time: String, notes: String, date: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
  
    let managedContext = appDelegate.persistentContainer.viewContext
    
    if buttonInfoObject == "Add Event" {
      let entity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)
    
      let event = NSManagedObject(entity: entity!, insertInto: managedContext)
    
      event.setValue(client, forKey: "client")
      event.setValue(location, forKey: "location")
      event.setValue(time, forKey: "time")
      event.setValue(notes, forKey: "notes")
      event.setValue(date, forKey: "date")
    
      do {
        try managedContext.save()
//        events.append(event)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    } else {
      let eventToChange = event as! NSManagedObject
      
      eventToChange.setValue(client, forKey: "client")
      eventToChange.setValue(location, forKey: "location")
      eventToChange.setValue(time, forKey: "time")
      eventToChange.setValue(notes, forKey: "notes")
      eventToChange.setValue(date, forKey: "date")
      
      do {
        try eventToChange.managedObjectContext?.save()
      } catch let error as NSError {
        print("Could not edit. \(error), \(error.userInfo)")
      }
    }
  }
}










