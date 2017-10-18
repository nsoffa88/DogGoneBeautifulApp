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
  
  let picker = UIDatePicker()
  
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

}
