//
//  AddClientViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/27/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddClientViewController: UIViewController {
  @IBOutlet weak var saveClientInfoButton: UIBarButtonItem!
  @IBOutlet weak var clientNameTextField: UITextField!
  @IBOutlet weak var phoneNumberTextField: UITextField!
  @IBOutlet weak var addressTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var referredByTextField: UITextField!
  @IBOutlet weak var referralsTextField: UITextField!
  
  var client: CKRecord?
  var newClient: Bool?
  
  let database = CKContainer.default().privateCloudDatabase
  var clientRecords: [CKRecord]?
  
  override func viewDidLoad() {
      super.viewDidLoad()
    
    if client != nil {
      clientNameTextField.text = client?.value(forKey: "Name") as? String
      phoneNumberTextField.text = client?.value(forKey: "PhoneNumber") as? String
      addressTextField.text = client?.value(forKey: "Address") as? String
      emailTextField.text = client?.value(forKey: "Email") as? String
      referredByTextField.text = client?.value(forKey: "ReferredBy") as? String
      referralsTextField.text = client?.value(forKey: "Referrals") as? String
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "doneSavingClient" {
      if let clientVC = segue.destination as? ClientViewController {
        clientVC.clientRecords = clientRecords!
      }
    }
  }

  @IBAction func saveClientInfo(_ sender: Any) {
    if(clientNameTextField.text! != "" && addressTextField.text! != "") {
      let nameToSave =  clientNameTextField.text
      let phoneNumberToSave = phoneNumberTextField.text
      let addressToSave = addressTextField.text
      let emailToSave = emailTextField.text
      let referredByToSave = referredByTextField.text
      let referralsToSave = referralsTextField.text
      
      self.save(name: nameToSave!, phoneNumber: phoneNumberToSave!, address: addressToSave!, email: emailToSave!, referredBy: referredByToSave!, referrals: referralsToSave!)
    } else {
      let alert = UIAlertController(title: "Error",
                                    message: "Must include atleast a Client and Address",
                                    preferredStyle: .alert)
      let endAlert = UIAlertAction(title: "Back",
                                   style: .default)
      alert.addAction(endAlert)
      present(alert, animated: true)
    }
  }
  
  func save(name: String, phoneNumber: String, address: String, email: String, referredBy: String, referrals: String) {
    var clientToSave: CKRecord
    
    if newClient == true {
      clientToSave = CKRecord(recordType: "Client")
    } else {
      clientToSave = client!
    }
    
    clientToSave.setValue(name, forKey: "Name")
    clientToSave.setValue(phoneNumber, forKey: "PhoneNumber")
    clientToSave.setValue(address, forKey: "Address")
    clientToSave.setValue(email, forKey: "Email")
    clientToSave.setValue(referredBy, forKey: "ReferredBy")
    clientToSave.setValue(referrals, forKey: "Referrals")
    
    database.save(clientToSave) { (record, error) in
      guard record != nil else { return }
      if self.newClient == true {
        self.clientRecords?.append(clientToSave)
      }
      self.performSegue(withIdentifier: "doneSavingClient", sender: self)
    }
  }
}
