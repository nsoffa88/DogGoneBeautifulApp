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
  @IBOutlet weak var dateSelection: UITextField!
  @IBOutlet weak var clientTextField: UITextField!
  @IBOutlet weak var LocationTextField: UITextField!
  @IBOutlet weak var notesTextField: UITextField!
  @IBOutlet weak var addEventButton: UIButton!
  @IBOutlet weak var cancelEventSave: UIButton!

  let picker = UIDatePicker()
  var events: [NSManagedObject] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createDatePicker()
  }

  func createDatePicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    toolbar.setItems([done], animated: false)
    
    dateSelection.inputAccessoryView = toolbar
    dateSelection.inputView = picker
    
    picker.datePickerMode = .time
  }
  
  @objc func donePressed() {
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short
    let timeString = timeFormatter.string(from: picker.date)
    
    dateSelection.text = "\(timeString)"
    self.view.endEditing(true)
  }
    
  @IBAction func cancelEvent(_ sender: Any) {
    self.performSegue(withIdentifier: "backToCalendarSegue", sender: self)
  }
  
  @IBAction func addEventToCalendar(_ sender: Any) {
    let nameToSave =  clientTextField.text
    let locationToSave = LocationTextField.text
    let timeToSave = dateSelection.text
    let notesToSave = notesTextField.text
    
    self.save(name: nameToSave!, location: locationToSave!, time: timeToSave!, notes: notesToSave!)
    self.performSegue(withIdentifier: "backToCalendarSegue", sender: self)
  }
  
  func save(name: String, location: String, time: String, notes: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let entity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)
    
    let event = NSManagedObject(entity: entity!, insertInto: managedContext)
    
    event.setValue(name, forKeyPath: "name")
    event.setValue(location, forKeyPath: "location")
    event.setValue(time, forKeyPath: "time")
    event.setValue(notes, forKeyPath: "notes")
    
    do {
      try managedContext.save()
      events.append(event)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
//    print("Testing Save?")
//    print(event.value(forKey: "name"))
//    print(event.value(forKey: "location"))
//    print(event.value(forKey: "time"))
//    print(event.value(forKey: "notes"))
//    print(events)
  }
}










