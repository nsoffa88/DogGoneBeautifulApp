//
//  AddDogViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 11/2/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import CloudKit

class AddDogViewController: UIViewController {
  @IBOutlet weak var dogNameTextField: UITextField!
  @IBOutlet weak var breedTextField: UITextField!
  @IBOutlet weak var ageTextField: UITextField!
  @IBOutlet weak var medsTextField: UITextField!
  @IBOutlet weak var vetInfoTextField: UITextField!
  @IBOutlet weak var personalityTextField: UITextField!
  @IBOutlet weak var groomTextField: UITextField!
  @IBOutlet weak var shampooTextField: UITextField!
  @IBOutlet weak var priceTextField: UITextField!
  @IBOutlet weak var procedureTextField: UITextField!
  
  var client: CKRecord?
  var dog: CKRecord?
  var dogRecords: [CKRecord]?
  var newDog: Bool?
  var clientsDogs: [CKRecord]?
  let database = CKContainer.default().privateCloudDatabase
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if dog != nil {
      dogNameTextField.text = dog?.value(forKey: "Name") as? String
      breedTextField.text = dog?.value(forKey: "Breed") as? String
      ageTextField.text = dog?.value(forKey: "Age") as? String
      medsTextField.text = dog?.value(forKey: "Meds") as? String
      vetInfoTextField.text = dog?.value(forKey: "Vet") as? String
      personalityTextField.text = dog?.value(forKey: "Personality") as? String
      groomTextField.text = dog?.value(forKey: "GroomInterval") as? String
      shampooTextField.text = dog?.value(forKey: "Shampoo") as? String
      priceTextField.text = dog?.value(forKey: "Price") as? String
      procedureTextField.text = dog?.value(forKey: "Procedure") as? String
    }
  }
  
  @IBAction func saveDogInfo(_ sender: Any) {
    if(dogNameTextField.text! != "" && breedTextField.text! != "") {
      let dogNameToSave =  dogNameTextField.text
      let breedToSave = breedTextField.text
      let ageToSave = ageTextField.text
      let medsToSave = medsTextField.text
      let vetInfoToSave = vetInfoTextField.text
      let personalityToSave = personalityTextField.text
      let groomToSave = groomTextField.text
      let shampooToSave = shampooTextField.text
      let priceToSave = priceTextField.text
      let procedureToSave = procedureTextField.text
      
      self.save(name: dogNameToSave!, breed: breedToSave!, age: ageToSave!, meds: medsToSave!, vetInfo: vetInfoToSave!, personality: personalityToSave!, groomInterval: groomToSave!, shampoo: shampooToSave!, price: priceToSave!, procedure: procedureToSave!)
    } else {
      let alert = UIAlertController(title: "Error",
                                    message: "Must include atleast a Name and Breed",
                                    preferredStyle: .alert)
      let endAlert = UIAlertAction(title: "Back",
                                   style: .default)
      alert.addAction(endAlert)
      present(alert, animated: true)
    }
  }
  
  func save(name: String, breed: String, age: String, meds: String, vetInfo: String, personality: String, groomInterval: String, shampoo: String, price: String, procedure: String) {
    var dogToSave: CKRecord
    
    if newDog == true {
      dogToSave = CKRecord(recordType: "Dog")
    } else {
      dogToSave = dog!
    }
    
    dogToSave.setValue(name, forKey: "Name")
    dogToSave.setValue(breed, forKey: "Breed")
    dogToSave.setValue(age, forKey: "Age")
    dogToSave.setValue(meds, forKey: "Meds")
    dogToSave.setValue(vetInfo, forKey: "Vet")
    dogToSave.setValue(personality, forKey: "Personality")
    dogToSave.setValue(groomInterval, forKey: "GroomInterval")
    dogToSave.setValue(shampoo, forKey: "Shampoo")
    dogToSave.setValue(price, forKey: "Price")
    dogToSave.setValue(procedure, forKey: "Procedure")
    
    //Saving Reference on Dog Record to Owner
    let ownerReference = CKReference(record: client!, action: CKReferenceAction.deleteSelf)
    dogToSave.setValue(ownerReference, forKey: "OwnerReference")
    
    database.save(dogToSave) { (record, error) in
      if error != nil {
        print(error)
      } else {
        if self.newDog == true {
          self.clientsDogs?.append(dogToSave)
          self.dogRecords?.append(dogToSave)
        }
        self.performSegue(withIdentifier: "doneSavingClient", sender: self)

      }
    }

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "doneSavingClient" {
      if let viewVC = segue.destination as? ClientInfoViewController {
        viewVC.clientsDogs = clientsDogs!
        viewVC.dogRecords = dogRecords
      }
      if let viewVC = segue.destination as? DogInfoViewController {
        viewVC.dog = dog
      }
    }
  }
  
}







