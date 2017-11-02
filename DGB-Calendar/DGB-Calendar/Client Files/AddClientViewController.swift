//
//  AddClientViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/27/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CoreData

class AddClientViewController: UIViewController {
  @IBOutlet weak var saveClientInfoButton: UIBarButtonItem!
  @IBOutlet weak var clientNameTextField: UITextField!
  @IBOutlet weak var phoneNumberTextField: UITextField!
  @IBOutlet weak var addressTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var referredByTextField: UITextField!
  @IBOutlet weak var referralsTextField: UITextField!
  
  var client: Client?
  var newClient: Bool?
  
  override func viewDidLoad() {
      super.viewDidLoad()
    
    if client != nil {
      clientNameTextField.text = client?.clientName
      phoneNumberTextField.text = client?.phoneNumber
      addressTextField.text = client?.address
      emailTextField.text = client?.email
      referredByTextField.text = client?.referredBy
      referralsTextField.text = client?.referrals
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
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    if newClient == true {
      let entity = NSEntityDescription.entity(forEntityName: "Client", in: managedContext)
      
      let client = NSManagedObject(entity: entity!, insertInto: managedContext)
      
      client.setValue(name, forKey: "clientName")
      client.setValue(phoneNumber, forKey: "phoneNumber")
      client.setValue(address, forKey: "address")
      client.setValue(email, forKey: "email")
      client.setValue(referredBy, forKey: "referredBy")
      client.setValue(referrals, forKey: "referrals")
      
      do {
        try managedContext.save()
        self.performSegue(withIdentifier: "doneSavingClient", sender: self)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    } else {
      let clientToChange = client! as NSManagedObject
      
      clientToChange.setValue(name, forKey: "clientName")
      clientToChange.setValue(phoneNumber, forKey: "phoneNumber")
      clientToChange.setValue(address, forKey: "address")
      clientToChange.setValue(email, forKey: "email")
      clientToChange.setValue(referredBy, forKey: "referrals")
      
      do {
        try clientToChange.managedObjectContext?.save()
        self.performSegue(withIdentifier: "doneSavingClient", sender: self)
      } catch let error as NSError {
        print("Could not edit. \(error), \(error.userInfo)")
      }
    }
  }
}
