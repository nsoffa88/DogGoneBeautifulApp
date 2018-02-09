//
//  AddEventViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/17/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddEventViewController: UIViewController {
  @IBOutlet weak var timeSelection: UITextField!
  @IBOutlet weak var clientTextField: UITextField!
  @IBOutlet weak var dogTextField: UITextField!
  @IBOutlet weak var locationTextField: UITextField!
  @IBOutlet weak var notesTextField: UITextField!
  @IBOutlet weak var saveEventButton: UIBarButtonItem!
  
  let picker = UIDatePicker()
  var eventRecords: [CKRecord]?
  var todaysEventRecords: [CKRecord]?
  var newEvent: Bool?
  var eventDate: String?
  var eventRecord: CKRecord?
  
  var clientRecords = [CKRecord]()
  var clientRecord: CKRecord?
  var dogRecords = [CKRecord]()
  var clientsDogs = [CKRecord]()
  var dogRecord: CKRecord?
  
  let clientPicker = UIPickerView()
  let dogPicker = UIPickerView()
  
  let database = CKContainer.default().privateCloudDatabase
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    clientPicker.delegate = self
    clientPicker.dataSource = self
    dogPicker.delegate = self
    dogPicker.dataSource = self
    
    createTimePicker()
    createClientPicker()
    createDogPicker()
    
    if eventRecord != nil {
      clientTextField.text = clientRecord?.value(forKey: "Name") as! String
      dogTextField.text = dogRecord?.value(forKey: "Name") as! String
      timeSelection.text = eventRecord?.value(forKey: "Time") as? String
      locationTextField.text = eventRecord?.value(forKey: "Address") as? String
      notesTextField.text = eventRecord?.value(forKey: "Notes") as? String
    }
  }

  func createTimePicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(timeDonePressed))
    toolbar.setItems([done], animated: false)
    
    timeSelection.inputAccessoryView = toolbar
    timeSelection.inputView = picker
    
    picker.datePickerMode = .time
  }
  @objc func timeDonePressed() {
    let timeFormatter = DateFormatter()
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short
    let timeString = timeFormatter.string(from: picker.date)
    
    timeSelection.text = "\(timeString)"
    self.view.endEditing(true)
  }
  
  func createClientPicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(clientDonePressed))
    toolbar.setItems([done], animated: false)
    
    clientTextField.inputAccessoryView = toolbar
    clientTextField.inputView = clientPicker
  }
  
  @objc func clientDonePressed() {
    clientTextField.text = clientRecord?.value(forKey: "Name") as! String
    dogTextField.text = ""
    dogRecord = nil
    self.view.endEditing(true)
  }
  
  func createDogPicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dogDonePressed))
    toolbar.setItems([done], animated: false)
    
    dogTextField.inputAccessoryView = toolbar
    dogTextField.inputView = dogPicker
  }
  @objc func dogDonePressed() {
    if dogRecord != nil {
      dogTextField.text = dogRecord?.value(forKey: "Name") as! String
    } else {
      dogTextField.text = "No Dogs Found"
    }
    self.view.endEditing(true)
  }
  
  @IBAction func saveEvent(_ sender: Any) {
    if(clientRecord != nil && dogRecord != nil && timeSelection.text! != "") {
//      let clientToSave =  clientTextField.text
//      let dogToSave = dogTextField.text
      let locationToSave = locationTextField.text
      let timeToSave = timeSelection.text
      let notesToSave = notesTextField.text
      
      self.save(location: locationToSave!, time: timeToSave!, notes: notesToSave!, date: eventDate!)
    } else {
      let alert = UIAlertController(title: "Error",
                                    message: "Must include atleast a Client, Dog, and Time",
                                    preferredStyle: .alert)
      let endAlert = UIAlertAction(title: "Back",
                                   style: .default)
      alert.addAction(endAlert)
      present(alert, animated: true)
    }
  }
  
  func save(location: String, time: String, notes: String, date: String) {
    var eventToSave: CKRecord
    
    if newEvent == true {
      eventToSave = CKRecord(recordType: "Event")
    } else {
      eventToSave = eventRecord!
    }
    
    let clientReference = CKReference(record: clientRecord!, action: CKReferenceAction.none)
    eventToSave.setValue(clientReference, forKey: "ClientReference")
    let dogReference = CKReference(record: dogRecord!, action: CKReferenceAction.none)
    eventToSave.setValue(dogReference, forKey: "DogReference")
    
    eventToSave.setValue(location, forKey: "Address")
    eventToSave.setValue(time, forKey: "Time")
    eventToSave.setValue(notes, forKey: "Notes")
    eventToSave.setValue(date, forKey: "Date")
    
    database.save(eventToSave) { (record, error) in
      if error != nil {
        print(error)
      } else {
        if self.newEvent == true {
          self.eventRecords?.append(eventToSave)
        }
      }
      self.performSegue(withIdentifier: "doneSavingEvent", sender: self)
    }
  }
  
  func getDogs(client: CKRecord) -> [CKRecord] {
    var clientsDogs = [CKRecord]()
    for dogRecord in dogRecords {
      let dogOwnerReference = dogRecord.value(forKey: "OwnerReference") as! CKReference
      let dogOwnerID = dogOwnerReference.recordID.recordName
      if dogOwnerID == clientRecord?.recordID.recordName {
        clientsDogs.append(dogRecord)
      }
    }
    print("GOT DOGS")
    return clientsDogs
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "doneSavingEvent" {
      if let viewVC = segue.destination as? CalendarView {
        viewVC.eventRecords = eventRecords
        viewVC.clientRecord = clientRecord
      }
      if let viewVC = segue.destination as? ViewInfoViewController {
        viewVC.clientRecord = clientRecord
      }
    }
  }
}

extension AddEventViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == clientPicker {
      return clientRecords.count
    } else {
      if clientsDogs.count == 0 {
        return 1
      } else {
        return clientsDogs.count
      }
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView == clientPicker {
      print("CREATING CLIENT PICKER NAMES")
      return clientRecords[row].value(forKey: "Name") as! String
    } else if pickerView == dogPicker {
      print("CREATING DOG PICKER NAMES")
      clientsDogs = getDogs(client: clientRecord!)
      if clientsDogs.count == 0 {
        return "No Dogs Found"
      } else {
        return clientsDogs[row].value(forKey: "Name") as! String
      }
    }
    return "Error in creating Titles"
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView == clientPicker {
      clientRecord = clientRecords[row]
      print("Selected Client")
      clientsDogs = getDogs(client: clientRecord!)
      clientTextField.text = clientRecord?.value(forKey: "Name") as! String
    } else {
      print("Selected Dog Name")
      if clientsDogs.count == 0 {
        dogTextField.text = "No Dogs Found"
        dogRecord = nil
      } else {
        dogRecord = clientsDogs[row]
        dogTextField.text = clientsDogs[row].value(forKey: "Name") as! String
      }
    }
  }
}










